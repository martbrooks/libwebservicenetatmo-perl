#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use utf8;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use YAML::XS qw(LoadFile);

use lib dirname( abs_path $0) . '/lib';
use WebService::Netatmo::WeatherStation;

binmode STDOUT, ':utf8';

my $yaml          = LoadFile("settings.yaml");
my $client_id     = $yaml->{client_id};
my $client_secret = $yaml->{client_secret};
my $username      = $yaml->{username};
my $password      = $yaml->{password};
my $tokenstore    = './tokenstore.yaml';
my $debug         = 0;

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
my %wind         = $netatmo->wind;
my %rain         = $netatmo->rain;

foreach my $station ( sort keys %stations ) {
    my $stationname = $stations{$station}{station_name};
    say "- $stationname";
    foreach my $module ( sort keys %{ $stations{$station}{submodules} } ) {
        my $modulename = $stations{$station}{submodules}{$module}{module_name};
        my $sensor;
        my $temperature  = $temperatures{$stationname}{$modulename}{pretty}       // '';
        my $pressure     = $pressures{$stationname}{$modulename}{pretty}          // '';
        my $humidity     = $humidities{$stationname}{$modulename}{pretty}         // '';
        my $noiselevel   = $noise{$stationname}{$modulename}{pretty}              // '';
        my $co2level     = $co2{$stationname}{$modulename}{pretty}                // '';
        my $windstrength = $wind{$stationname}{$modulename}{WindStrength}{pretty} // '';
        my $windangle    = $wind{$stationname}{$modulename}{WindAngle}{pretty}    // '?';
        my $rainlast     = $rain{$stationname}{$modulename}{RainLast}{pretty}     // '';
        my $raintoday    = $rain{$stationname}{$modulename}{RainToday}{pretty}    // '';

        my $output = "-- $modulename: ";
        $output .= "$temperature, "                if $temperature ne '';
        $output .= "$pressure, "                   if $pressure ne '';
        $output .= "$humidity, "                   if $humidity ne '';
        $output .= "$noiselevel, "                 if $noiselevel ne '';
        $output .= "$co2level, "                   if $co2level ne '';
        $output .= "$windstrength @ $windangle, "  if $windstrength ne '';
        $output .= "$rainlast ($raintoday today) " if $rainlast ne '';

        $output =~ s/\s+$//g;
        $output =~ s/,$//g;

        say "$output.";
    }
    print "\n";
}
