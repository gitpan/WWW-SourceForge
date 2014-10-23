package WWW::SourceForge;
use strict;
use LWP::Simple;
use JSON::Parse;
use XML::Feed;

our $VERSION = '0.40'; # This is the overall version for the entire
# package, so should probably be updated even when the other modules are
# touched.

=head2 new

 Usage     : my $sfapi = new WWW::SourceForge;
 Returns   : WWW::SourceForge object

Optionally pass an 'api' argument to select one of the other APIs.

    my $download_api = WWW::SourceForge->new( api => 'download' );

See https://sourceforge.net/p/forge/documentation/Download%20Stats%20API/

=cut

sub new {
    my ( $class, %parameters ) = @_;

    my $api = $parameters{api} || 'data';
    my $api_url;
    if ( $api eq 'download' ) {
        $api_url = 'https://sourceforge.net/projects';
    } else {
        $api_url = 'https://sourceforge.net/api';
    }

    my $self = bless(
        {
            api_url => $api_url,
            api     => $api,
        },
        ref($class) || $class
    );

    return $self;
}

=head2 call

 Usage : my $json = $sfapi->call( 
                method => whatever, 
                arg1   => 'value', 
                arg2   => 'another value',
                format => 'rss',
                );
 Returns : Hashref, containing a bunch of data. Format defaults to
     'json', but in some cases, you'll want to force rss because that's
     how the return is available. Will try to make this smarter
     eventually.

Calls a particular method in the SourceForge API. Other args are passed
as args to that call.

=cut

sub call {
    my $self = shift;
    my %args = @_;

    my $r = {};
    my $url;
    my $format;

    # Download API, documented at
    # https://sourceforge.net/p/forge/documentation/Download%20Stats%20API/
    if ( $self->{api} eq 'download' ) {


        # TODO: Default start date, end date (last 7 days, perhaps?)

        # TODO: API allows specification of subdirs of the files
        # hierarchy, and we don't allow that yet here.

        $url =
            $self->{api_url} . '/'
          . $args{project}
          . '/files/stats/json?start_date=' . $args{start_date}
          . '&end_date=' . $args{end_date};

        $format = 'json';

    # Data API, documented at
    # https://sourceforge.net/p/forge/documentation/API/
    } else {

        my $method = $args{method} || return $r;
        delete( $args{method} );

        $format = $args{format} || 'json';
        delete( $args{format} );

        $url = $self->{api_url} . '/' . $method;
        foreach my $a ( keys %args ) {
            $url .= '/' . $a . '/' . $args{$a};
        }

        # Format defaults to 'json'
        $url .= '/' . $format;
    }

    if ( $format eq 'rss' ) {
        $r = { entries => [] };

        my $feed = XML::Feed->parse( URI->new($url) ) or return $r;
        for my $entry ( $feed->entries ) {
            push @{ $r->{entries} }, $entry;
        }
    } else {
        my $json = get($url);
        $r = JSON::Parse::json_to_perl($json);
    }
    return $r;
}

=head1 NAME

WWW::SourceForge - Interface to SourceForge's APIs - http://sourceforge.net/p/forge/documentation/API/ and https://sourceforge.net/p/forge/documentation/Download%20Stats%20API/

=head1 SYNOPSIS

Usually you'll use this via WWW::SourceForge::Project and
WWW::SourceForge::User rather than using this directly.

=head1 DESCRIPTION

Implements a Perl interface to the SourceForge API, documented here:
http://sourceforge.net/p/forge/documentation/API/ and here:
https://sourceforge.net/p/forge/documentation/Download%20Stats%20API/

=head1 USAGE

    use WWW::SourceForge;
    my $sfapi = new WWW::SourceForge;

See WWW::SourceForge::User and WWW::SourceForge::Project for details.

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

