package WebService::Netatmo::Common;
use Moo;
use v5.10;

use Data::Dumper;
use DateTime::Format::DateParse;
use JSON::MaybeXS;
use LWP::UserAgent;
use YAML::XS qw(LoadFile DumpFile);

our $API = 'https://api.netatmo.net';

has station       => ( is => 'ro' );
has client_id     => ( is => 'ro', required => 1 );
has client_secret => ( is => 'ro', required => 1 );
has username      => ( is => 'ro', required => 1 );
has password      => ( is => 'ro', required => 1 );
has tokenstore    => ( is => 'ro', required => 1 );
has debug         => ( is => 'ro' );
has access_token => (
    is      => 'rw',
    lazy    => 1,
    builder => sub { $_[0]->_get_or_refresh_token() }
);
has refresh_token      => ( is => 'rw' );
has token_expires      => ( is => 'rw' );
has token_last_updated => ( is => 'rw' );

sub _get_or_refresh_token {
    my $self       = shift;
    my $now        = DateTime->now();
    my $tokenstore = $self->tokenstore;
    my $haschanged = 0;
    my $store;

    if ( -e $tokenstore ) {
        _debug( $self, "Reading stored tokens from '$tokenstore.'" );
        $store = LoadFile("$tokenstore");
        my $lastupdate = DateTime::Format::DateParse->parse_datetime( $store->{token_last_updated} );
        my $diffsecs   = $now->epoch() - $lastupdate->epoch();
        _debug( $self, "Token is $diffsecs seconds old." );

        if ( $diffsecs > $store->{expires_in} ) {
            _debug( $self, 'Refreshing tokens.' );
            $self->refresh_token( $store->{refresh_token} );
            my $newstore = $self->__refresh_token();
            _debug( $self, "Old access token: $store->{access_token}" );
            _debug( $self, "New access token: $newstore->{access_token}" );
            $store->{access_token}       = $newstore->{access_token};
            $store->{refresh_token}      = $newstore->{refresh_token};
            $store->{token_last_updated} = $now->datetime();
            $haschanged                  = 1;
        }

    } else {
        _debug( $self, "Fetching new tokens." );
        $store                       = $self->__get_token();
        $store->{token_last_updated} = $now->datetime();
        $haschanged                  = 1;
    }

    $self->access_token( $store->{access_token} );
    $self->refresh_token( $store->{refresh_token} );
    $self->token_expires( $store->{expires_in} );
    $self->token_last_updated( $store->{token_last_updated} );

    if ( $haschanged == 1 ) {
        DumpFile( "$tokenstore", $store );
    }
    return $self->access_token;
}

sub __get_token {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    my $r    = $ua->post(
        "$API/oauth2/token",
        [
            grant_type    => 'password',
            client_id     => $self->client_id,
            client_secret => $self->client_secret,
            username      => $self->username,
            password      => $self->password,
            scope         => 'read_station',
        ]
    );

    unless ( $r->is_success ) {
        die $r->status_line;
    }

    my $content = decode_json( $r->decoded_content );
    return $content;
}

sub __refresh_token {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    my $r    = $ua->post(
        "$API/oauth2/token",
        [
            grant_type    => 'refresh_token',
            client_id     => $self->client_id,
            client_secret => $self->client_secret,
            refresh_token => $self->refresh_token,
        ]
    );

    unless ( $r->is_success ) {
        die $r->status_line;
    }

    my $content = decode_json( $r->decoded_content );
    return $content;
}

sub _debug {
    my ( $self, $message ) = @_;
    if ( $self->debug ) {
        my $now = DateTime->now();
        say "[$now] $message";
    }
}

1;
