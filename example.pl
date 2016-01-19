#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use Cwd qw(abs_path);
use Data::Dumper;
use DateTime::Format::DateParse;
use File::Basename qw(dirname);
use YAML::XS qw(LoadFile);

use lib dirname( abs_path $0) . '/lib';
use WebService::Netatmo::WeatherStation;

my $yaml = LoadFile("settings.yaml");

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

my %stationdata = $netatmo->getstationsdata();

foreach my $station ( keys %stationdata ) {
    my $stationname = $stationdata{$station}{station_name};
    say $stationname;
    foreach my $module ( keys %{ $stationdata{$station}{submodules} } ) {
        my $modulename  = $stationdata{$station}{submodules}{$module}{module_name};
        my $temperature = $stationdata{$station}{submodules}{$module}{dashboard_data}->{Temperature};
        say "- $modulename: $temperature";
    }
}
