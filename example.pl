#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
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
my $debug         = 1;

my $metric = $opt->metric // 'temperature';

my $netatmo = WebService::Netatmo::WeatherStation->new(
    client_id     => $client_id,
    client_secret => $client_secret,
    username      => $username,
    password      => $password,
    tokenstore    => $tokenstore,
    debug         => $debug,
);

my %temperatures = $netatmo->temperatures;
foreach my $station ( sort keys %temperatures ) {
    say "$station:";
    foreach my $sensor ( sort keys %{ $temperatures{$station} } ) {
        say "- $sensor: $temperatures{$station}{$sensor}{pretty}";
    }
}

my %pressures = $netatmo->pressures;
foreach my $station ( sort keys %pressures ) {
    say "$station:";
    foreach my $sensor ( sort keys %{ $pressures{$station} } ) {
        say "- $sensor: $pressures{$station}{$sensor}{pretty}";
    }
}

my %humidities = $netatmo->humidities;
foreach my $station ( sort keys %humidities ) {
    say "$station:";
    foreach my $sensor ( sort keys %{ $humidities{$station} } ) {
        say "- $sensor: $humidities{$station}{$sensor}{pretty}";
    }
}

my %noise = $netatmo->noise;
foreach my $station ( sort keys %noise ) {
    say "$station:";
    foreach my $sensor ( sort keys %{ $noise{$station} } ) {
        say "- $sensor: $noise{$station}{$sensor}{pretty}";
    }
}

my %co2 = $netatmo->co2;
foreach my $station ( sort keys %co2 ) {
    say "$station:";
    foreach my $sensor ( sort keys %{ $co2{$station} } ) {
        say "- $sensor: $co2{$station}{$sensor}{pretty}";
    }
}

