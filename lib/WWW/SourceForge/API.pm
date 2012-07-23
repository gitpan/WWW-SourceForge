package WWW::SourceForge::API;
use strict;
use LWP::Simple;
use JSON::Parse;

our $VERSION = '0.30'; # This is the overall version for the entire
# package, so should probably be updated even when the other modules are
# touched.

=head2 new

 Usage     : my $sfapi = new WWW::SourceForge::API;
 Returns   : WWW::SourceForge::API object

=cut

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless( { api_url => 'https://sourceforge.net/api/', },
        ref($class) || $class );

    return $self;
}

=head2 call

 Usage : my $json = $sfapi->call( 
                method => whatever, 
                arg1   => 'value', 
                arg2   => 'another value' 
                );
 Returns : JSON string of the response. I think. Not sure yet. It might
           return a json_to_perl thingy. We'll see. Stay tuned.

Calls a particular method in the SourceForge API. Other args are passed
as args to that call.

=cut

sub call {
    my $self = shift;
    my %args = @_;

    my $r = {};

    my $method = $args{method} || return $r;

    delete( $args{method} );

    my $url = $self->{api_url} . '/' . $method;
    foreach my $a ( keys %args ) {
        $url .= '/' . $a . '/' . $args{$a};
    }
    $url .= '/json';
    my $json = get($url);

    $r = JSON::Parse::json_to_perl($json);
    return $r;
}

=head1 NAME

WWW::SourceForge::API - Interface to SourceForge's APIs - http://sourceforge.net/p/forge/documentation/API/

=head1 SYNOPSIS

  use WWW::SourceForge::API;
  blah blah blah


=head1 DESCRIPTION

Implements a Perl interface to the SourceForge API, documented here:
http://sourceforge.net/p/forge/documentation/API/

=head1 USAGE

    use WWW::SourceForge::API;
    my $sfapi = new WWW::SourceForge::API;

    my $user_details = $sfapi->user_details( 'rbowen' );

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

