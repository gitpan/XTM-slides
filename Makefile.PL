use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'          => 'XTM::slides',
    'VERSION_FROM'  => 'lib/XTM/Smile.pm', # finds $VERSION
    'AUTHOR'        => 'rho@telecoma.net',
    'INSTALLSCRIPT' => '/usr/local/bin',
    'EXE_FILES'     => [ 'bin/stm2sml.pl' ],
    'NOECHO'        => '@',
    'PREREQ_PM'     => { 
	'Data::Dumper' => 2.102,
	'Getopt::Long' => 2.25,
	'Pod::Usage' => 1.14,
	'Test::More' => 0.40,
	'URI::file' => 0,
	'XML::SAX::ParserFactory' => 1.00,
	'XML::SAX::Writer' => 0.39,
	'XML::XPath' => 1.12,
	'XML::XPath::XMLParser' => 0,
	'File::Slurp'          => 96.042202,
	'XTM::base'            => 0.29,
    }

);
