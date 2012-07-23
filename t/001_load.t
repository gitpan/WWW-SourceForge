# -*- perl -*-

# t/001_load.t - check module loading

use Test::More tests => 2;

BEGIN { use_ok( 'WWW::SourceForge::API' ); }

my $object = WWW::SourceForge::API->new ();
isa_ok ($object, 'WWW::SourceForge::API', 'WWW::SourceForge::API interface loads ok');


