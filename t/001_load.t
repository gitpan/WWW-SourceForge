# -*- perl -*-

# t/001_load.t - check module loading

use Test::More tests => 2;

BEGIN { use_ok( 'WWW::SourceForge' ); }

my $object = WWW::SourceForge->new ();
isa_ok ($object, 'WWW::SourceForge', 'WWW::SourceForge interface loads ok');


