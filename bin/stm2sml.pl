#!/usr/bin/perl

use strict;
use vars qw ($VERSION);
$VERSION = "0.3";

use Data::Dumper;

=pod

=head1 NAME

stm2sml.pl - A Topic Map based slides generator

=head1 SYNOPSIS

  cat myshow.stm | stm2sml.pl > myshow.sml

=head1 DESCRIPTION

This filter reads an XML file, interprets it as I<slide> Topic Map format 
(see L<XTM::Smile::SAX>) and will
generate a slide XML document.

This SlideML document can then be postprocessed via XSLT into LaTeX, HTML, et.al.

=head1 OPTIONS

Following command line switches are understood by the program:

=over

=item B<tmbase> (default: C<file:.>)

controls where the Topic Maps can be found (Sorry, only one directory at the moment)

=cut

my $tmbase;

=pod

=item B<urlbase> (default: C<file:.>)

controls where the Topic Maps can be found (Sorry, only one directory at the moment)

=cut

my $urlbase;

=pod

=item B<help>

=item B<about> (default: no)

=cut

my $about = 0;

=back

=head1 AUTHOR INFORMATION

Copyright 2001, 2002, Robert Barta <rho@telecoma.net>, All rights reserved.
 
This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself. See

  http://www.perl.com/perl/misc/Artistic.html


=cut

use Getopt::Long;
use Pod::Usage;
 
my $help;
if (!GetOptions ('help|?|man'    => \$help,
		 'tmbase=s'      => \$tmbase,
		 'urlbase=s'     => \$urlbase,
                 'about!'        => \$about,
                ) || $help) {
  pod2usage(-exitstatus => 0, -verbose => 2);
} 

if ($about) {
  use XTM;
  print STDOUT "STM Topic Map Slides Converter ($VERSION)
XTM ($XTM::VERSION)
XTM::Smile::SAX ($XTM::Smile::SAX::Version)
";
  exit;
}

use XML::SAX::Writer;
my $writer   = new XML::SAX::Writer          ();
use URI::file;
use XTM::Smile::SAX;
my $expander = new XTM::Smile::SAX           (Handler          => $writer,
					      urlbase          => $urlbase ? $urlbase : URI::file->cwd . "maps/",
					      tmbase           => $tmbase  ? $tmbase : undef,
					      default_format   => "%ti %ty %rd %ins %res",
					      );
use XML::SAX::ParserFactory;
my $parser  = XML::SAX::ParserFactory->parser(Handler          => $expander,
					      RequiredFeatures => {
								   'http://xml.org/sax/features/validation' => 1,
								  }
					     );

use IO::Handle;
my $io = new IO::Handle;
$io->fdopen(fileno(STDIN),"r");
$parser->parse_file ($io);


__END__

undef $/;

use XTM::STM ('stm2slideml');
print stm2slideml (<STDIN>, $tmbase); # feed whole string





# maybe later...
?
#use XTM::STM::SlideML::LaTeXProsper;
#xml2latex ($xml);

 
__END__

