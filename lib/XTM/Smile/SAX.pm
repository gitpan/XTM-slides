package ParseError;
use base qw(XML::SAX::Exception);

sub new {
  my $class   = shift;
  my $message = shift;
  return  bless {
                 Message => $message,
                 Exception => undef,
                }, $class;
}
 
1;

package XTM::Smile::SAX;

use strict;
use vars qw($VERSION);
use base qw(XML::SAX::Base);

$VERSION = '0.1';

require Exporter;
require AutoLoader;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use XTM;
use XTM::Virtual;
use XTM::Namespaces;

my $tmns    = $XTM::Namespaces::topicmaps_ns;
my $xlinkns = $XTM::Namespaces::xlink_ns;
my $astmans = $XTM::Namespaces::astma_ns;

my $prefix = 'smile';
my %namespaces = ($prefix => 'http://topicmaps.bond.edu.au/smile/1.0/',
		  'xml'   => 'http://www.w3.org/XML/1998/namespace',
		  'xmlns' => 'http://www.w3.org/2000/xmlns/',
		  'xlink' => 'http://www.w3.org/1999/xlink');


my $tmbase = 'file:.';
my $default_format = "%ti %ty %rd %ins %res";


=pod

=head1 NAME

  XTM::Smile::SAX - AsTMa tag expansion

=head1 SYNOPSIS

  use XTM::Smile::SAX;
  my $expander = new XTM::Smile::SAX   (tmbase => 'file:/where/are/the/maps/');
  my $parser  = find a SAX parser here (Handler => $expander);
  $parser->parse_string($XML);

=head1 DESCRIPTION

This package scans the SAX event stream for tags in the namespace

   http://topicmaps.bond.edu.au/astma/1.0/

and expands them into tags of the namespace

   http://topicmaps.bond.edu.au/smile/1.0/

according to the description below.

Example:

  <?xml ....
  <some_document>
     ...
     <astma:default astma:tau_expr="file:w3o.atm"/>
     <astma:slide astma:tid="w3c-user-interface"/>
     ...
  </some_document>

  will consult the man I<file:w3o.atm> and will return

  <?xml ....
  <some_document>
     ...
     <smile:slide smile:tid='w3c-user-interface'>
        <smile:title>User Interface Activity</smile:title>
        <smile:types><smile:type>W3C Activity</smile:type></smile:types>
        <smile:inlines><smile:inline>HTML, CSS1/2, XSL-FO/XSLT, WAI, SVG, I18N</smile:inline></smile:inlines>
        <smile:instances>test1, test2, test3</smile:instances>
        <smile:references>
           <smile:reference href='http://www.w3c.org/' type='simple' />
           <smile:reference href='http://www.w3c2.org/' type='simple' />
           <smile:reference href='http://www.w3c3.org/' type='simple' />
        </smile:references>
     </smile:slide>
     ...
  </some_document>


Following incoming tags are detected:

=over

=item C<slide>: 

This signals the begin of a slide. 

=over 

=item 

The mandatory attribute is C<tid>, which must contain a topic id. 
If this particular topic does not exist in the current topic map, an error is
flagged. 

=item 

Optionally, the attribute C<format> can be used to control the content of
this slide.

=back

=item C<default>: 

With this tag, default values can be set via attributes which apply to
all slides which may follow this tag:

=over

=item C<map>: 

The value of this attribute will be interpreted as tau expression according to XTM::Virtual.

=item C<format>: 

This format will be used to control B<what> every slide will contain from the topic.
This format can be overridden for every individual slide. Formats are described below.

=back

=back

=head2 Formats

A format string describes B<what> exactly should be included in the generated slide.
The default format is

  "%ti %ty %rd %ins %res"

and takes care that a C<title>, C<types>, C<inlines>, C<instances> and C<references>
are included on a slide in this particular order.

One format specifier is introduced with a '%' character, several such specifiers are
separated bu one or more blanks. Following specifiers are honored:

=over

=item C<ti>:

Include a C<title> tag containing the title of the slide. This is generated from the baseName of the topic.
(Sorry, no scoping yet)

=item C<ty> and C<tys>:

This includes the types (instanceOf, to be exact) of the topic enclosed by a C<types> tag. In case
of C<ty>, every instanceOf is embedded with its own C<type> tag. In case of C<tys> all these instanceOfs
are concatenated to one string separated by ','.

=item C<rd> and C<rds>:

This includes the resourceData occurrences enclosed by the tag C<inlines>. In case of C<rd>,
every such occurrence is wrapped into its own tag, C<inline>. In case of C<rds>, all strings
are concatenated into one character string (again, separated by ',').

=item C<in>, C<ins> and C<inrds>:

This includes the instances of this topic using the tag C<instances>. In case of C<in>, the
individual instances are wrapped into separate C<instance> tags. In case of C<ins>, they
are concatenated via ',' into one string. C<inrds> behaves like C<in> except that for every
individual instance also its resourceData is included via nested C<description> tags.

=item C<res>

This includes the resourceRef occurrences via a C<references> tag. Every
individual occurrence is included via a C<reference> tag. This tag is empty,
but contains an C<xlink:href> attribute containing the reference link.




=back

=head1 INTERFACE

=head2 Constructor

Following fields can be passed:

=over

=item C<urlbase>: 

This controls the base URL which will be used to derive an absolute
URL for the Topic Map to be loaded, in case the provided URL was relative.

=item C<tmbase>: 

The same for Topic Maps in the tm: space.

=item C<tau_expr>: 

An Topic Map expression as described in L<XTM::Virtual>. The resulting
map will be used as a default unless another map is provided via a astma:map attribute (see below)

=item C<default_format>:

This format string will serve as default if (a) either no slide-wide format has been specified
or (b) no slide-specific format can be found.

=back

=cut

sub new {
  my $class  = shift;
  my %options = @_;
  my $self = bless \%options, $class;

  if ($options{'tau_expr'}) {
    $XTM::Virtual::urlbase = $self->{urlbase} || 'file:.';
    $XTM::Virtual::tmbase  = $self->{tmbase};
    $self->{tm}  = new XTM (tie => new XTM::Virtual (expr => $options{'tau_expr'}));
  }
  $self->{default_format} ||= $default_format;
  return $self;
}

=pod

=head2 Methods

This filter captures following SAX events and propagates them to the next filter:

=over

=item start_element

=item characters

=item end_element

=back

=cut

#sub xml_decl {
#  my $self = shift;
#  my $data = shift;
#
##?????print "xml_decl", Dumper $data;
##????exit;
#  $self->SUPER::xml_decl($data);
###  $self->SUPER::document_start({Version => '1.0'});
#}

sub propagate_start {
  my $self  = shift;
  my $tag   = shift;
  my $attrs = shift;

  my $Attrs;
  foreach my $a (keys (%$attrs)) {
    my ($p, $b) = $a =~ /:/ ? split (/:/, $a) : ($prefix, $a);
    $Attrs->{"{".$namespaces{$p}."}$a"} = {
				    'LocalName'    => $b,
				    'NamespaceURI' => $namespaces{$p},
				    'Value'        => $attrs->{$a},
				    'Prefix'       => $p,
				    'Name'         => "$p:$b"
				   };
  }

  $self->SUPER::start_element ({
				'LocalName'    => $tag,
				'Attributes'   => $Attrs,
				'NamespaceURI' => $namespaces{$prefix},
				'Prefix'       => $prefix,
				'Name'         => "$prefix:$tag"
			       });
}

sub propagate_chars {
  my $self  = shift;
  my $chars = shift;
  $self->SUPER::characters ({Data => $chars});
}

sub propagate_end {
  my $self  = shift;
  my $tag   = shift;

  $self->SUPER::end_element ({
			      'LocalName'    => $tag,
			      'NamespaceURI' => $namespaces{$prefix},
			      'Prefix'       => $prefix,
			      'Name'         => "$prefix:$tag"
			     });
}

sub format_topic {
  my $self     = shift;
  my $tid      = shift;
  my $format   = shift;
  my $continue = shift;

  my $names = $self->{tm}->baseNames ([ $tid ]);

  $self->propagate_start ('slide', { 'tid' => $tid,
				     $format =~ /%ti/ ? () : ('title' => $names->{$tid}),
				     $continue eq 'yes' ? ('continue' => $continue) : (),
				   });

  foreach my $f (split (/\s+/, $format)) {
    unless ($f =~ /^\%(\w+)(\[(\d+)?\-(\d+)?\])?$/) {
      warn "XTM::SAX::AsTMa: invalid format '$f'";
      next;
    }
    my ($what, $lower, $upper) = ($1, $3, $4);
    $lower ||= 1;
    $upper ||= $lower + 4; # default are 5 items at most
    $lower--; $upper--;    # counting starts at 0, you moron
    
    my ($outer_tag, $inner_tag, $innerst_tag); # ???? have to be encoded into a format later, TODO
#    $self->propagate_chars ($what);
    
    if ($what =~ /^tys?$/) {
      my $t = $self->{tm}->induced_vortex ($tid, {'t_types'     => [ 't_types' ] }, [  ]);
      my $names = $self->{tm}->baseNames ($t->{t_types});
      if (@{$t->{t_types}}) {
	$self->propagate_start ($outer_tag ||= 'types');
	if ($what eq 'tys') {
	  $self->propagate_chars (join (", ", map { $names->{$_} } grep (defined, @{$t->{t_types}}[$lower..$upper]) ));
	} else {
	  my $i = 0;
	  foreach my $ty (@{$t->{t_types}}) {
	    ($i++, next) if $i < $lower; last unless $i++ <= $upper;
	    $self->propagate_start ($inner_tag ||= 'type');
	    $self->propagate_chars ($names->{$ty});
	    $self->propagate_end   ($inner_tag);
	  }
	}
	$self->propagate_end ($outer_tag);
      }
    } elsif ($what =~ /^rds?$/) {
      my $t = $self->{tm}->induced_vortex ($tid, {'topic'       => [ 'topic' ] }, [  ]);
      if (@{$t->{topic}->occurrences}) {
	$self->propagate_start ($outer_tag ||= 'inlines');
	if ($what eq 'rds') {
	  $self->propagate_chars (join (", ", map {$_->resource->data}
					grep (defined,
					      (grep (ref ($_->resource) eq 'XTM::resourceData',
						     @{$t->{topic}->occurrences}))[$lower..$upper])));
	} else {
	  my $i = 0;
	  foreach my $o (@{$t->{topic}->occurrences}) {
	    if (ref ($o->resource) eq 'XTM::resourceData') {
	      ($i++, next) if $i < $lower; last unless $i++ <= $upper;
	      $self->propagate_start ($inner_tag ||= 'inline');
	      $self->propagate_chars ($o->resource->data);
	      $self->propagate_end   ($inner_tag);
	    }
	  }
	}
	$self->propagate_end ($outer_tag);
      }
    } elsif ($what =~ /^in(s|(rds))?$/) {
      my $t = $self->{tm}->induced_vortex ($tid, {'t_instances'     => [ 't_instances' ] }, [  ]);
      my $names = $self->{tm}->baseNames ($t->{t_instances});
      if (@{$t->{t_instances}}) {
	$self->propagate_start ($outer_tag ||= 'instances');
	if ($what eq 'ins') {
	  $self->propagate_chars (join (", ", map { $names->{$_} } grep (defined, @{$t->{t_instances}}[$lower..$upper]) ));
	} else {
	  my $i = 0;
	  foreach my $in (@{$t->{t_instances}}) {
	    ($i++, next) if $i < $lower; last unless $i++ <= $upper;
	    $self->propagate_start ($inner_tag ||= 'instance');
	    $self->propagate_chars ($names->{$in});
	    if ($what eq 'inrds') {
	      my $d = $self->{tm}->induced_vortex ($in, {'topic'       => [ 'topic' ] }, [  ]);
	      foreach my $o (@{$d->{topic}->occurrences}) {
		$self->propagate_start ($innerst_tag ||= 'description');
		$self->propagate_chars ($o->resource->data) if ref ($o->resource) eq 'XTM::resourceData';
		$self->propagate_end   ($innerst_tag);
	      }
	    }
	    $self->propagate_end   ($inner_tag);
	  }
	}
	$self->propagate_end ($outer_tag);
      }
    } elsif ($what eq 'ti') {
      $self->propagate_start ($outer_tag ||= 'title');
      $self->propagate_chars ($names->{$tid});
      $self->propagate_end   ($outer_tag);
    } elsif ($what eq 'res') {
      my $t = $self->{tm}->induced_vortex ($tid, {'topic'       => [ 'topic' ] }, [  ]);
      if (@{$t->{topic}->occurrences}) {
	$self->propagate_start ($outer_tag ||= 'references');
	my $i = 0;
	foreach my $o (@{$t->{topic}->occurrences}) {
	  if (ref ($o->resource) eq 'XTM::resourceRef') {
	  ($i++, next) if $i < $lower; last unless $i++ <= $upper;
	    $self->propagate_start ($inner_tag ||= 'reference', { 'xlink:href' => $o->resource->href,
								  'xlink:type' => 'simple' } );
	    $self->propagate_end   ($inner_tag);
	  }
	}
	$self->propagate_end ($outer_tag);
      }
    } else {
      warn "XTM::SAX::AsTMa: unknown format identifier '$what', ignored";
    }
  };
  $self->propagate_end ('slide');
}


sub start_element {
  my $self = shift;
  my $data = shift;

#  print "start_element $data->{LocalName}", "\n",Dumper ($self, $data);

  if ($data->{NamespaceURI} eq $astmans) {
    if ($data->{LocalName} eq 'slide') {
#      print "slide", Dumper $data;
      my $tid = $data->{Attributes}->{"{$astmans}tid"}->{Value};
      unless ($tid) {
	warn "XTM::SAX::AsTMa: no topic id";
	next;
      }
      unless ( $self->{tm}->is_topic ($tid)) {
	warn "XTM::SAX::AsTMa: topic '$tid' not found";
	next;
      }
      my $format   = $data->{Attributes}->{"{$astmans}format"}->{Value}   || $self->{default_format};
      my $continue = $data->{Attributes}->{"{$astmans}continue"}->{Value} || 'no';
      $self->format_topic ($tid, $format, $continue);
#    } elsif ($data->{LocalName} eq 'query') {
#      $self->{query} = "";
    } elsif ($data->{LocalName} eq 'default') {
#      print "start_element $data->{LocalName}", "\n",Dumper ($self, $data);
      if ($data->{Attributes}->{"{$astmans}tau_expr"}) {
	$XTM::Virtual::urlbase = $self->{urlbase} || 'file:.';
	$XTM::Virtual::tmbase  = $self->{tmbase};
	eval {
	  my $tm  = new XTM (tie => 
			     new XTM::Virtual (expr => 
					       $data->{Attributes}->{"{$astmans}tau_expr"}->{Value}));
	  $self->{tm} = $tm; # two steps, so that the original is not undef in case of an exception
	}; if ($@) {
	  my $exception = new ParseError ($@);
#	  $self->fatal_error($exception);
	  $exception->throw;
	}
      };
      if ($data->{Attributes}->{"{$astmans}format"}) {
	$self->{default_format} = $data->{Attributes}->{"{$astmans}format"}->{Value};
      };
    }
#  } elsif (defined $self->{query}) { # I'm in collection mode
#    $self->{query} .= "<".$data->{Name}.">";
  } else {
    $self->SUPER::start_element ($data);
  }
}

sub characters {
  my $self = shift;
  my $data = shift;

#  print "found data", Dumper $data;
#  if (defined $self->{query}) { # I'm in collection mode
#    $self->{query} .= $data->{Data};
#  } else {
    $self->SUPER::characters ($data);
#  }
}

sub end_element {
  my $self = shift;
  my $data = shift;

#  print "end_element $data->{LocalName}", "\n",Dumper ($self, $data);


  if ($data->{NamespaceURI} eq $astmans) {
    if ($data->{LocalName} eq 'query') {
      undef $self->{query};
    } elsif ($data->{LocalName} eq 'slide') {
      # ignore
    }
  } elsif (defined $self->{query}) { # I'm in collection mode
    $self->{query} .= "</".$data->{Name}.">";
  } else {
    $self->SUPER::end_element ($data);
  }
}

=pod

=head1 AUTHOR INFORMATION

Copyright 2002, Robert Barta <rho@telecoma.net>, All rights reserved.

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself. See

  http://www.perl.com/perl/misc/Artistic.html

=cut

1;

__END__
