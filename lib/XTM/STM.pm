package XTM::STM;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw();
@EXPORT_OK = qw( stm2slideml );
$VERSION = '0.2';

my $debug = 0;

=pod

=head1 NAME

XTM::STM - Topic Map Slide (STM) to XML (SlideML) conversion

=head1 SYNOPSIS

  use XTM::STM (stm2slideml);
  $xml = stm2slideml ($stm_string, 'file:/base/url/of/maps/')
  

=head1 DESCRIPTION

This package hosts  routines to convert from STM (a ASCII based
Topic Map related slide definition language) to SlideML, an XML
based slide show definition.

=head1 INTERFACE

=over

=item C<stm2slideml>

Converts a STM stream into a slide XML presentation (SML) and returns that as string. Not very sophisticated yet.

=cut

use XTM;
use XTM::Virtual;
use Data::Dumper;

sub stm2slideml {
  my $stm    = shift;
  my $tmbase = shift;

  my $xml    = '';   # will hold the result
  my $tm;    # will hold the joined topic map
  my $slide; # will hold the current slide
# special variables
  my $name;
  my $continuetext;
# argh another state variable, flags whether the <?xml junk has been flushed or not
  my $header_flushed = undef;

  foreach my $l (split /\n/, $stm) {
    if ($l =~ /^\s*$/) {              # ignore
      $xml .= _xmlify_slide ($slide, $tm, $continuetext, \$header_flushed, $name) if $slide;  undef $slide;

sub _xmlify_header {
  my $rheader_flushed = shift;
  my $name            = shift;

  unless ($$rheader_flushed++) {
    my $xml;
    $xml .= qq|<?xml version="1.0" encoding="iso-8859-1"?>\n|;
    $xml .= qq|<slides name="$name" xmlns = "http://topicmaps.bond.edu.au/SlideML/">\n\n|;
    return $xml;
  }
  return '';
}

sub _xmlify_var {
  my ($var, $val, $rheader_flushed, $name) = @_;
  my $xml;

  $xml .= _xmlify_header ($rheader_flushed, $name);
  $xml .= qq|   <$var>$val</$var>\n\n|;
  return $xml;
}

sub _find_relevances {
  my $directives = shift;
  my %relevances = (inline     => [1,5], # defaults
		    types      => [1,5],
		    instances2 => [1,5],
		    );

  foreach my $d (@{$directives}) {
    my ($mod, $what, undef, $level, $range) = $d =~ /([-+=])([^\s]+)(\s+(\d))?(\s+\(.+\))?/;
    $level ||= 1;
    my ($lower, $upper) = $range =~ /\((\d+)-(\d*)\)/ if $range;
    $lower ||= 1;
    $upper ||= $lower + 4; # default are 5 items at most
  
    print STDERR "mod $mod what $what level $level range $range\n" if $debug > 2;

    if (! defined $what) {
      # OK, nothing
    } elsif ($what eq 'inline') {
      delete $relevances{inline};#                  	  if $mod eq '-';
      $relevances{inline} = [ $lower, $upper ]    	  if $mod eq '+';
      return (inline => [ $lower, $upper ])       	  if $mod eq '=';
    } elsif ($what eq 'types') {	    	    
      delete $relevances{types};#      		  	  if $mod eq '-';
      $relevances{types} = [ $lower, $upper ]     	  if $mod eq '+';
      return (types => [ $lower, $upper ])	  	  if $mod eq '=';
    } elsif ($what eq 'instances') {			
      delete $relevances{instances1};# 		  	  if $mod eq '-';
      delete $relevances{instances2};# 		  	  if $mod eq '-';
      $relevances{"instances$level"} = [ $lower, $upper ] if $mod eq '+';
      return ("instances$level" => [ $lower, $upper ])    if $mod eq '=';
    }
  }
print STDERR "relevances ", Dumper \%relevances if $debug > 2;
  return %relevances;
}

sub _xmlify_slide {
  my $slide            = shift;
  my $tm               = shift;
  my $continuetext     = shift;
  my $rheader_flushed  = shift;
  my $name             = shift;

  my $xml   = '';

  $xml .= _xmlify_header  ($rheader_flushed, $name);

#print STDERR Dumper $slide;
  my %relevances = _find_relevances ($slide->{directives});
#print STDERR "relevances:", Dumper \%relevances;
  eval {
    my $names = $tm->baseNames ([ $slide->{tid} ]);
    $xml .= qq|  <slide title=\"|.
            $names->{$slide->{tid}} .
            (grep (/^continue$/, @{$slide->{directives}}) ? $continuetext : '') .
            qq|\">\n|;

#print STDERR "relevances before loop ", $slide->{tid}, Dumper \%relevances;

    foreach my $r (qw ( types inline instances1 instances2)) {
      next unless $relevances{$r};
#print STDERR "relevances in loop $r ", $slide->{tid}, Dumper $relevances{$r};
      my ($lower, $upper) = @{$relevances{$r}};
      $lower--; $upper--; # counting starts at 0, you morons
#print STDERR "lower $lower upper $upper\n";
      if ($r eq 'inline' && $relevances{inline}) {
	my $t = $tm->induced_vortex ($slide->{tid}, {'topic'       => [ 'topic' ] }, [  ]); 
	foreach my $o (@{$t->{topic}->occurrences}) {
#	  print STDERR Dumper $o;
	  $xml .= qq|      <text>|.$o->resource->data.qq|</text>\n| if ref ($o->resource) eq 'XTM::resourceData';
	}
      } elsif ($r eq 'types' && $relevances{types}) {
	my $t = $tm->induced_vortex ($slide->{tid}, {'t_types'     => [ 't_types' ] }, [  ]); 
	my $names = $tm->baseNames ($t->{t_types});
	if (@{$t->{t_types}}) {
	  $xml .= qq|      <item>is some form of |;
	  $xml .= join (", ", map { $names->{$_} } @{$t->{t_types}} );
	  $xml .= qq|</item>\n|;
	}
      } elsif ($r eq 'instances1' && $relevances{instances1}) {
	my $t = $tm->induced_vortex ($slide->{tid}, {'t_instances'     => [ 't_instances' ] }, [  ]); 
	my $names = $tm->baseNames ($t->{t_instances});
	if (@{$t->{t_instances}}) {
	  $xml .= qq|      <item>|;
#print STDERR "before ", $lower, $upper, Dumper $t->{t_instances};
	  $xml .= join (", ", map { $names->{$_} } grep defined, @{$t->{t_instances}}[$lower..$upper] );
	  $xml .= qq|</item>\n|;
	}
      } elsif ($r eq 'instances2' && $relevances{instances2}) {
	my $t = $tm->induced_vortex ($slide->{tid}, {'t_instances'     => [ 't_instances' ] }, [  ]); 
	my $names = $tm->baseNames ($t->{t_instances});
#print STDERR "before ", $lower, $upper, Dumper $t->{t_instances};
	foreach my $instance (grep defined, @{$t->{t_instances}}[$lower..$upper]) {
	  $xml .= qq|    <item>|;
	  $xml .= $names->{$instance};
	  my $d = $tm->induced_vortex ($instance, {'topic'       => [ 'topic' ] }, [  ]); 
	  foreach my $o (@{$d->{topic}->occurrences}) {
	    $xml .= qq|      <description>|.$o->resource->data.qq|</description>\n| if ref ($o->resource) eq 'XTM::resourceData';
	  }
	  $xml .= qq|</item>\n|;
	}
      }
    }
    
    $xml .= qq|  </slide>

|;

  }; if ($@) {
    print STDERR "XTM::STM: No information for topic '$slide->{tid}' ($@), skipping...\n";
    undef $slide;
  }

  return $xml;
}


    } elsif ($l =~ /^%slide:\s*(.+)/) { # slide directive
      if ($1 =~ /(\w+)\s*=(.+)/) { # variable assignment
	my ($var,$val) = ($1, $2);
	if ($var eq 'map') { # special variable
	    print STDERR "tmbase: >>$tmbase<<\n" if $debug > 2;

          $XTM::Virtual::urlbase = $tmbase;
	  $tm = new XTM (tie => new XTM::Virtual (expr => $val));
	} elsif ($var eq 'name') { # special variable
	  $name = $val;
	} elsif ($var eq 'continuetext') { # special variable
	  $continuetext = $val;
	} else {             # generic passthrou
	  $val =~ s#\\\\#\n#g;
	  $xml .= _xmlify_var ($var, $val, \$header_flushed, $name);
	}
      } elsif ($1 =~ /end/) {
	last;
      } else {
	push @{$slide->{directives}}, $1 if $slide; # only add directives if there is something
      }
    } elsif ($l =~ /([^\s]+)/) {
      $slide->{tid} = $1;
    }
  }
  $xml .= _xmlify_slide ($slide, $tm, $continuetext, \$header_flushed, $name) if $slide;
  $xml .= qq|</slides>
|;
  return $xml;
}


=pod

=back

=head1 SEE ALSO

L<XTM:base>

=head1 AUTHOR INFORMATION

Copyright 2001, Robert Barta <rho@telecoma.net>, All rights reserved.
 
This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut

1;

__END__
