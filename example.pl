#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use utf8;

use Cwd qw(abs_path);
use Data::Dumper;
use File::Basename qw(dirname);
use Getopt::Long::Descriptive;
use YAML::XS qw(LoadFile);

use lib dirname( abs_path $0) . '/lib';
use WebService::Netatmo::WeatherStation;

binmode STDOUT, ':utf8';

my ( $opt, $usage ) = describe_options(
    "%c %o",

    ['Metrics:'],
    [
        'metric|m=s' => hidden => {
            one_of => [
                [ 'co2|c'         => 'Report CO2 readings.' ],
                [ 'humidity|h'    => 'Report humidity readings.' ],
                [ 'temperature|t' => 'Report temperature readings.' ],
                [ 'noise|n'       => 'Report noise readings.' ],
                [ 'pressure|p'    => 'Report pressure readings.' ],

            ]
        }
    ],
    [],
);

my $yaml = LoadFile("settings.yaml");

my $client_id     = $yaml->{client_id};
my $client_secret = $yaml->{client_secret};
my $username      = $yaml->{username};
my $password      = $yaml->{password};
my $tokenstore    = './tokenstore.yaml';
my $debug         = 0;

my $metric = $opt->metric // 'temperature';

my $netatmo = WebService::Netatmo::WeatherStation->new(
    client_id     => $client_id,
    client_secret => $client_secret,
    username      => $username,
    password      => $password,
    tokenstore    => $tokenstore,
    debug         => $debug,
);

my %stations     = $netatmo->getstationsdata;
my %temperatures = $netatmo->temperatures;
my %pressures    = $netatmo->pressures;
my %humidities   = $netatmo->humidities;
my %noise        = $netatmo->noise;
my %co2          = $netatmo->co2;

foreach my $station ( sort keys %stations ) {
    my $stationname = $stations{$station}{station_name};
    foreach my $module ( sort keys %{ $stations{$station}{submodules} } ) {
        my $modulename = $stations{$station}{submodules}{$module}{module_name};
        my $sensor;
        my $temperature = $temperatures{$stationname}{$modulename}{pretty} // '-';
        my $pressure    = $pressures{$stationname}{$modulename}{pretty}    // '-';
        my $humidity    = $humidities{$stationname}{$modulename}{pretty}   // '-';
        my $noiselevel  = $noise{$stationname}{$modulename}{pretty}        // '-';
        my $co2level    = $co2{$stationname}{$modulename}{pretty}          // '-';
        say "$modulename: $temperature, $pressure, $humidity, $noiselevel, $co2level";
    }
}

