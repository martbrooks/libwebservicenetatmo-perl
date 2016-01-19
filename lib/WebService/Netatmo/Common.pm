package WebService::Netatmo::Common;
use Moo;
use v5.10;

use Data::Dumper;
use DateTime::Format::DateParse;
use Exporter qw(import);
use JSON::XS;
use LWP::UserAgent;
use YAML::XS qw(LoadFile DumpFile);

has client_id          => ( is => 'ro' );
has client_secret      => ( is => 'ro' );
has username           => ( is => 'ro' );
has password           => ( is => 'ro' );
has tokenstore         => ( is => 'ro' );
has debug              => ( is => 'ro' );
has access_token       => ( is => 'rw' );
has refresh_token      => ( is => 'rw' );
has token_expires      => ( is => 'rw' );
has token_last_updated => ( is => 'rw' );

sub _get_or_refresh_token {
    my $self       = shift;
    my $now        = DateTime->now();
    my $tokenstore = $self->tokenstore;
    my $store;

    if ( -e $tokenstore ) {
        _debug( $self, "Reading stored tokens from '$tokenstore.'" );
        $store = LoadFile("$tokenstore");
        my $lastupdate = DateTime::Format::DateParse->parse_datetime( $store->{token_last_updated} );
        my $diffsecs   = $now->epoch() - $lastupdate->epoch();
        _debug( $self, "Token is $diffsecs seconds old." );
    } else {
        _debug( $self, "Fetching new tokens." );
        $store = __get_token($self);
        $store->{token_last_updated} = $now->datetime();
    }

    $self->access_token( $store->{access_token} );
    $self->refresh_token( $store->{refresh_token} );
    $self->token_expires( $store->{expires_in} );
    $self->token_last_updated( $store->{token_last_updated} );

    DumpFile( "$tokenstore", $store );
}

sub __get_token {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    my $r    = $ua->post(
        'https://api.netatmo.net/oauth2/token',
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

sub _debug {
    my ( $self, $message ) = @_;
    if ( $self->debug ) {
        my $now = DateTime->now();
        say "[$now] $message";
    }
}
1;
