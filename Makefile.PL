use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'          => 'XTM::slides',
    'VERSION_FROM'  => 'lib/XTM/STM.pm', # finds $VERSION
    'AUTHOR'        => 'rho@telecoma.net',
    'INSTALLSCRIPT' => '/usr/local/bin',
    'EXE_FILES'     => [ 'bin/stm2sml.pl' ],
    'NOECHO'        => '@',
    'PREREQ_PM'     => { 'Data::Dumper'         => 2.101,
			 'File::Slurp'          => 96.042202,
			 'XTM'                  => 0.23,
			 'Test::Simple'         => 0.19,
			 'Pod::Usage'           => 1.14,
		       }

);
