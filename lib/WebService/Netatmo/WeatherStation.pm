package WebService::Netatmo::WeatherStation;

use v5.10;
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

    my $content     = decode_json( $r->decoded_content );
    my %stationdata = __post_process_station_data($content);
    return %stationdata;
}

sub __post_process_station_data {
    my %stationdata;
    my $content = shift;

    foreach my $station ( @{ $content->{body}->{devices} } ) {
        my $stationid = $station->{_id};

        $stationdata{$stationid}{place}        = $station->{place};
        $stationdata{$stationid}{station_name} = $station->{station_name};

        foreach my $key ( keys %{$station} ) {
            next if $key eq 'place';
            next if $key eq 'modules';
            next if $key eq 'station_name';
            $stationdata{$stationid}{submodules}{$stationid}{$key} = $station->{$key};
        }

        foreach my $module ( @{ $station->{'modules'} } ) {
            my $moduleid = $module->{_id};
            foreach my $key ( keys %{$module} ) {
                $stationdata{$stationid}{submodules}{$moduleid}{$key} = $module->{$key};
            }
        }
        return %stationdata;
    }
}

sub BUILD {
    my $self = shift;
    $self->_get_or_refresh_token();
}

1;
