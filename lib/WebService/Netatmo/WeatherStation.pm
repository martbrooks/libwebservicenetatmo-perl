package WebService::Netatmo::WeatherStation;

use v5.10;
use Moo;
use Data::Dumper;
use JSON::MaybeXS;

extends 'WebService::Netatmo::Common';

our $API   = 'https://api.netatmo.net';
our $cache = '';

sub getstationsdata {
    my $self = shift;

    if ( $cache eq '' ) {
        my $ua = LWP::UserAgent->new;
        my $r  = $ua->post(
            "$API/api/getstationsdata",
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
        my $stationname = $stationdata{$station}{station_name};
        my $unit        = $stationdata{$station}{administrative}{unit};
        next if ( $self->station ne '' && $stationname ne $self->station );

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
    }
    return %temperatures;
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

sub noise {
    my $self = shift;
    my %noise;
    my %stationdata = $self->getstationsdata();

    foreach my $station ( keys %stationdata ) {
        my $stationname = $stationdata{$station}{station_name};
        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasNoise} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $noiselevel    = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{Noise};
                $noise{$stationname}{$submodulename}{raw}    = $noiselevel;
                $noise{$stationname}{$submodulename}{pretty} = $noiselevel . "dB";
            }
        }
    }
    return %noise;
}

sub co2 {
    my $self = shift;
    my %co2;
    my %stationdata = $self->getstationsdata();

    foreach my $station ( keys %stationdata ) {
        my $stationname = $stationdata{$station}{station_name};
        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasCO2} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $co2level = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{CO2} // '<No reading>';
                $co2{$stationname}{$submodulename}{raw}    = $co2level;
                $co2{$stationname}{$submodulename}{pretty} = $co2level . "ppm";
            }
        }
    }
    return %co2;
}

sub rain {
    my $self = shift;
    my %rain;
    my %stationdata = $self->getstationsdata();

    foreach my $station ( keys %stationdata ) {
        my $stationname = $stationdata{$station}{station_name};
        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasRain} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $rainlast      = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{Rain};
                my $rainhour      = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{sum_rain_1};
                my $raintoday     = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{sum_rain_24};

                $rain{$stationname}{$submodulename}{RainLast}{raw}        = $rainlast;
                $rain{$stationname}{$submodulename}{RainLastHour}{raw}    = $rainhour;
                $rain{$stationname}{$submodulename}{RainToday}{raw}       = $raintoday;
                $rain{$stationname}{$submodulename}{RainLast}{pretty}     = $rainlast . 'mm';
                $rain{$stationname}{$submodulename}{RainLastHour}{pretty} = $rainhour . 'mm';
                $rain{$stationname}{$submodulename}{RainToday}{pretty}    = $raintoday . 'mm';
            }
        }
    }
    return %rain;
}

sub wind {
    my $self = shift;
    my %wind;
    my %stationdata = $self->getstationsdata();

    foreach my $station ( keys %stationdata ) {
        my $stationname = $stationdata{$station}{station_name};
        my $unit        = $stationdata{$station}{administrative}{windunit};
        foreach my $submodule ( keys %{ $stationdata{$station}{submodules} } ) {
            if ( $stationdata{$station}{submodules}{$submodule}{hasWind} ) {
                my $submodulename = $stationdata{$station}{submodules}{$submodule}{module_name};
                my $strength      = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{WindStrength} // '<No reading>';
                my $angle         = $stationdata{$station}{submodules}{$submodule}{dashboard_data}->{WindAngle} // '<No reading>';
                $wind{$stationname}{$submodulename}{WindStrength}{raw} = $strength;
                if ( $unit == 0 ) {
                    $strength .= 'kph';
                }
                if ( $unit == 1 ) {
                    $strength = sprintf( "%.1f", $strength * 0.621371 );
                    $strength += 0;
                    $strength .= 'mph';
                }
                if ( $unit == 2 ) {
                    $strength = sprintf( "%.1f", $strength * 0.277778 );
                    $strength += 0;
                    $strength .= 'm/s';
                }
                if ( $unit == 3 ) {
                    $strength = __kphtobeaufort($strength);
                    $strength = "Wind force $strength";
                }
                if ( $unit == 4 ) {
                    $strength = sprintf( "%.1f", $strength * 0.539957 );
                    $strength += 0;
                    $strength .= ' knots';
                }
                $wind{$stationname}{$submodulename}{WindStrength}{pretty} = $strength;
                $wind{$stationname}{$submodulename}{WindAngle}{raw}       = $angle;
                $wind{$stationname}{$submodulename}{WindAngle}{pretty}    = "$angle\x{00B0}";
            }
        }
    }
    return %wind;
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

sub __kphtobeaufort {
    my $kph = shift;

    # The Beaufort scale seems a little arbitrary.
    # These numbers taken from http://www.windfinder.com/wind/windspeed.htm

    if ( $kph <= 1 ) {
        return 0;
    }
    if ( $kph <= 6 ) {
        return 1;
    }
    if ( $kph <= 12 ) {
        return 2;
    }
    if ( $kph <= 20 ) {
        return 3;
    }
    if ( $kph <= 29 ) {
        return 4;
    }
    if ( $kph <= 39 ) {
        return 5;
    }
    if ( $kph <= 50 ) {
        return 6;
    }
    if ( $kph <= 62 ) {
        return 7;
    }
    if ( $kph <= 75 ) {
        return 8;
    }
    if ( $kph <= 89 ) {
        return 9;
    }
    if ( $kph <= 103 ) {
        return 10;
    }
    if ( $kph <= 118 ) {
        return 11;
    }

    return 12;
}

1;
