package WebService::Netatmo::WeatherStation;

use v5.10;
use Moo;
use Data::Dumper;
use JSON::MaybeXS;

extends 'WebService::Netatmo::Common';

our $API   = 'https://api.netatmo.net/api';
our $cache = '';

sub getstationsdata {
    my $self = shift;

    if ( $cache eq '' ) {
        my $ua = LWP::UserAgent->new;
        my $r  = $ua->post(
            "$API/getstationsdata",
            [
                access_token => $self->access_token,
            ]
        );

        unless ( $r->is_success ) {
            die $r->status_line;
        }

        $cache = decode_json( $r->decoded_content );
    }

    my %stationdata = __post_process_station_data($cache);
    return %stationdata;
}

sub temperatures {
    my $self = shift;
    my %temperatures;
    my %stationdata = $self->getstationsdata();
    my %glyphmap    = (
        0 => "\x{2103}",
        1 => "\x{2109}",
    );

    foreach my $station ( keys %stationdata ) {
        my $stationname  = $stationdata{$station}{station_name};
        my $unit         = $stationdata{$station}{administrative}{unit};
        my $windunit     = $stationdata{$station}{administrative}{windunit};
        my $pressureunit = $stationdata{$station}{administrative}{pressureunit};

        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasTemperature} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $temperature   = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{Temperature};
                if ( $unit == 1 ) {
                    $temperature = sprintf( "%.1f", $temperature * 1.8 + 32 );
                    $temperature += 0;
                }
                $temperatures{$stationname}{$submodulename}{raw}    = $temperature;
                $temperatures{$stationname}{$submodulename}{pretty} = $temperature . $glyphmap{$unit};
            }
        }
        return %temperatures;
    }
}

sub pressures {
    my $self = shift;
    my %pressures;
    my %stationdata = $self->getstationsdata();
    my %glyphmap    = (
        0 => 'mbar',
        1 => 'inHg',
        2 => 'mmHg'
    );

    foreach my $station ( keys %stationdata ) {
        my $stationname = $stationdata{$station}{station_name};
        my $unit        = $stationdata{$station}{administrative}{pressureunit};
        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasPressure} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $pressure      = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{Pressure};

                if ( $unit == 1 ) {
                    $pressure = sprintf( "%.1f", $pressure * 0.0295301 );
                }
                if ( $unit == 2 ) {
                    $pressure = sprintf( "%.1f", $pressure * 0.75006375541921 );
                }

                $pressure += 0;
                $pressures{$stationname}{$submodulename}{raw}    = $pressure;
                $pressures{$stationname}{$submodulename}{pretty} = $pressure . $glyphmap{$unit};
            }
        }
    }
    return %pressures;
}

sub humidities {
    my $self = shift;
    my %humidities;
    my %stationdata = $self->getstationsdata();

    foreach my $station ( keys %stationdata ) {
        my $stationname = $stationdata{$station}{station_name};
        my $unit        = $stationdata{$station}{administrative}{pressureunit};
        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasHumidity} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $humidity      = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{Humidity};
                $humidities{$stationname}{$submodulename}{raw}    = $humidity;
                $humidities{$stationname}{$submodulename}{pretty} = "$humidity%";
            }
        }
    }
    return %humidities;
}

sub __post_process_station_data {
    my %stationdata;
    my $content = shift;

    foreach my $station ( @{ $content->{body}->{devices} } ) {
        my $stationid = $station->{_id};

        $stationdata{$stationid}{administrative} = $content->{body}->{user}->{administrative};
        $stationdata{$stationid}{place}          = $station->{place};
        $stationdata{$stationid}{station_name}   = $station->{station_name};
        $stationdata{$stationid}{status}         = $station->{status};
        $stationdata{$stationid}{time_exec}      = $station->{time_exec};
        $stationdata{$stationid}{time_server}    = $station->{time_server};

        foreach my $key ( keys %{$station} ) {
            $stationdata{$stationid}{submodules}{$stationid}{$key} = $station->{$key};
        }

        foreach my $module ( @{ $station->{'modules'} } ) {
            my $moduleid = $module->{_id};

            foreach my $key ( keys %{$module} ) {
                $stationdata{$stationid}{submodules}{$moduleid}{$key} = $module->{$key};
            }
        }

        foreach my $submodule ( keys %{ $stationdata{$stationid}{submodules} } ) {
            foreach my $metric ( @{ $stationdata{$stationid}{submodules}{$submodule}->{data_type} } ) {
                $stationdata{$stationid}{submodules}{$submodule}{"has$metric"} = 1;
            }
        }
    }
    return %stationdata;
}

1;
