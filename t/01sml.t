use strict;

my $tmbase   = URI::file->cwd .'maps/';
my $stm      = 'maps/test.stm';
my $sml_good = 'maps/test.sml';

use Test::Simple tests => 2; 

use XTM::STM ('stm2slideml');
ok(1, 'loading');

use File::Slurp;
my $sml_test = stm2slideml (scalar read_file($stm), $tmbase);
#print $sml_test;

ok((scalar read_file ($sml_good)) eq $sml_test, 'comparing');
