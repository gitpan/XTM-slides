#!/usr/bin/perl

use strict;
use vars qw ($VERSION);
$VERSION = "0.2";

use Data::Dumper;

=pod

=head1 NAME

stm2sml.pl - A Topic Map based slides generator

=head1 SYNOPSIS

  cat myshow.stm | stm2sml.pl > myshow.sml

=head1 DESCRIPTION

This filter reads a file, interprets it as I<slide Topic Map> format and will
generate an slide XML document. See

   http://topicmaps.bond.edu.au/astma/

for format details and a tutorial of SlideML.

This SlideML document can then be postprocessed into LaTeX, HTML via XSLT.

=head1 OPTIONS

Following command line switches are understood by the program:

=over

=item B<tmbase> (default: C<file:.>)

controls where the Topic Maps can be found (Sorry, only one directory at the moment)

=cut

my $tmbase = 'file:.';

=pod

=item B<help>

=item B<about> (default: no)

=cut

my $about = 0;

=back

=head1 AUTHOR INFORMATION

Copyright 2001, Robert Barta <rho@telecoma.net>, All rights reserved.
 
This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut

use Getopt::Long;
use Pod::Usage;
 
my $help;
if (!GetOptions ('help|?|man'    => \$help,
		 'tmbase=s'      => \$tmbase,
                 'about!'        => \$about,
                ) || $help) {
  pod2usage(-exitstatus => 0, -verbose => 2);
} 

if ($about) {
  use XTM;
  print STDOUT "STM Topic Map Slides Converter ($VERSION)
XTM ($XTM::VERSION)
";
  exit;
}

undef $/;

use XTM::STM ('stm2slideml');
print stm2slideml (<STDIN>, $tmbase); # feed whole string

# maybe later...?
#use XTM::STM::SlideML::LaTeXProsper;
#xml2latex ($xml);

 
__END__

