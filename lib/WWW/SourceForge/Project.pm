package WWW::SourceForge::Project;
use strict;
use WWW::SourceForge;
use WWW::SourceForge::User;
use Data::Dumper;

our $VERSION = '0.12';

=head2 new

 Usage: 
 
    my $proj = new WWW::SourceForge::Project( id => 1234 );
    my $proj2 = new WWW::SourceForge::Project( name => 'flightics' );

    my @admins = $proj->admins(); # WWW::SourceForge::User objects
    my @developers = $proj->developers(); # Ditto

 Returns: WWW::SourceForge::Project object;

=cut

sub new {

    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );

    my $api = new WWW::SourceForge;
    $self->{api} = $api;

    my $json;
    if ( $parameters{id} ) {
        $json = $api->call(
            method => 'project',
            id     => $parameters{id}
        );
    } elsif ( $parameters{name} ) {
        $json = $api->call(
            method   => 'project',
            name => $parameters{name}
        );
    } else {
        warn('You must provide an id or name. Bad monkey.');
        return 0;
    }

    $self->{data} = $json->{Project};
    return $self;
}

=head2 admins

  @admins = $project->admins();

Returns a list of WWW::SourceForge::User objects which are the admins on this
project.

=cut

sub admins { 
    my $self = shift;
    return @{ $self->{data}->{_admins} } if ref( $self->{data}->{_admins} );

    my @admins;

    my $a_ref = $self->{data}->{maintainers};
    foreach my $u_ref ( @$a_ref ) {
        my $user = new WWW::SourceForge::User( username => $u_ref->{name} );
        push @admins, $user;
    }

    $self->{data}->{_admins} = \@admins;
    return @admins;
}

=head2 developers

  @devs = $project->devs();

Returns a list of WWW::SourceForge::User objects which are the developers on
the project. This does not include the admins.

=cut

sub developers { # not admins
    my $self = shift;
    return @{ $self->{data}->{_developers} } if ref( $self->{data}->{_developers} );

    my @devs;

    my $a_ref = $self->{data}->{developers};
    foreach my $u_ref ( @$a_ref ) {
        my $user = new WWW::SourceForge::User( username => $u_ref->{name} );
        push @devs, $user;
    }

    $self->{data}->{_developers} = \@devs;
    return @devs;
}

=head2 users

All project users - admins and non-admins.

=cut

sub users {
    my $self = shift;

    my @users = ( $self->admins(), $self->developers() );
    return @users;
}

=head2 files

List of recent released files

=cut

sub files {
    my $self = shift;

    return @{ $self->{data}->{releases} } if $self->{data}->{releases};
    my %args = @_;
    
    my $api = new WWW::SourceForge;
# http://sourceforge.net/api/release/index/project-id/156708/mtime/desc/rss

    my @files = $self->{api}->call(
        method             => 'release',
        "index/project-id" => $self->id(),
        mtime              => 'desc',
        format             => 'rss',
    );

    $self->{data}->{releases} = \@files;
}

=head2 latest_release 

Date of the latest released file

=cut

sub latest_release {
    my $self = shift;
    my @files = $self->files();
    return $files[0]->pubDate();
}

=head2 downloads

Download counts for the specified date range. If no date range is
supplied, assume the 7 days leading up to today.

WARNING: This API is subject to change any moment. The downloads API
gives us a LOT more information than just a count, and it may be that we
want to expose all of it later one. Right now I just want a count.

    my $dl_count = $project->downloads( 
        start_date => '2012-07-01',
        end_date -> '2012-07-25' 
    );

=cut

# https://sourceforge.net/projects/xbmc/files/stats/json?start_date=2010-05-01&end_date=2010-05-11
sub downloads {
    my $self = shift;
    my %args = @_;

    my $data_api = $self->{data_api} || WWW::SourceForge->new( api => 'download' );
    $self->{data_api} = $data_api;

    my $json = $data_api->call( %args, project => $self->shortdesc() );

    return $json->{summaries}->{time}->{downloads};
}

=head2 Data access AUTOLOADER

Handles most of the data access for the Project object. Some parts of
the data require special treatment.

=cut

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    my $sub = $AUTOLOAD;
    $sub =~ s/^.*:://;
    ( my $method = $sub ) =~ s/.*:://;
    return $self->{data}->{$sub};
}

=head1 NAME

WWW::SourceForge::Project - SourceForge project objects

=head1 SYNOPSIS

Uses the SourceForge API to load project details. This is a work in
progress, and the interface will change. Mostly I'm just poking about to
see what this needs to support. Please feel free to play along.

http://sf.net/projects/sfprojecttools/

=head1 DESCRIPTION

Implements a Perl interface to SourceForge projects. See http://sourceforge.net/p/forge/documentation/API/

=head1 USAGE

  use WWW::SourceForge::Project;
  my $project = WWW::SourceForge::Project->new( name => 'moodle' );
  print $project->id();
  print $project->type();
  print $project->status();

=head1 BUGS

None

=head1 SUPPORT

http://sourceforge.net/p/sfprojecttools/tickets/

=head1 AUTHOR

    Rich Bowen
    CPAN ID: RBOW
    SourceForge
    rbowen@sourceforge.net
    http://sf.net

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################

1;
