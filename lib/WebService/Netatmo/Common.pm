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
    my $tokenstore = $self->tokenstore;
    my $store;

    if ( -e $tokenstore ) {
        $store = LoadFile("$tokenstore");
        say "LOADED";
    } else {
        say "FETCHING";
        $store = __get_token($self);
    }

    my $now = DateTime->now();
    $store->{token_last_updated} = $now->datetime();

    $self->access_token( $store->{access_token} );
    $self->refresh_token( $store->{refresh_token} );
    $self->token_expires( $store->{expires_in} );
    $self->token_last_updated( $store->{token_last_updated} );

    # DumpFile( "$tokenstore", $store );
}

sub __get_token {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    my $now  = DateTime->now;
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

1;
