package WebService::Netatmo::WeatherStation;

use Moo;
use Data::Dumper;
use JSON::XS;

use parent 'WebService::Netatmo::Common';

our $API = 'https://api.netatmo.net/api';

sub getstationsdata {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    my $r    = $ua->post(
        "$API/getstationsdata",
        [
            access_token => $self->access_token,
        ]
    );

    unless ( $r->is_success ) {
        print Dumper $r;
                die $r->status_line;
    }

    my $content = decode_json( $r->decoded_content );
    return $content;
}

sub BUILD {
    my $self = shift;
    $self->_get_or_refresh_token();
}

1;
