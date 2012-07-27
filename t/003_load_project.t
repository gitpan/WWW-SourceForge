# -*- perl -*-

# t/003_load_project.t - check project module loading

use Test::More;
use Data::Dumper;
my $t = 0;

BEGIN { use_ok( 'WWW::SourceForge::Project' ); }

my $object = WWW::SourceForge::Project->new( name => 'flightics' );
isa_ok( $object, 'WWW::SourceForge::Project',
    'WWW::SourceForge::Project interface loads ok' );
$t += 2;

is( $object->type(), 10,           'Allura project' );
is( $object->name(), 'Flight ICS', 'Project name' );
is( $object->id(),   '631079',     'Project id' );
$t += 3;


my $object2 = WWW::SourceForge::Project->new( id => '631079' );
isa_ok( $object2, 'WWW::SourceForge::Project' );
is( $object2->name(), 'Flight ICS' );
$t += 2;

my $proj3 = WWW::SourceForge::Project->new( name => 'reefknot' );
my @admins = $proj3->admins();

my $admin1 = $admins[0];
is( $admin1->username(), 'rbowen' );

my $admin2 = $admins[1];
is( $admin2->username(), 'srl' );

is( scalar( $proj3->admins() ), 3 ); # Should get it from the cache this time

is( scalar( $proj3->developers() ), 9 );

is( scalar( $proj3->users() ), 12 ); # This should be really fast
$t += 5;

# If I do that another ten times, it shouldn't take any time at all
for (1..10) {
    is( scalar( $proj3->users() ), 12 ); 
    $t++;
}

# TODO
# my @files = $proj3->files();

done_testing( $t );

