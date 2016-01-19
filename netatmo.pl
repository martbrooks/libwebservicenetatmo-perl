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
my $tokenstore     = './tokenstore.yaml';
my $debug = 1;

my $netatmo=WebService::Netatmo::WeatherStation->new(
        client_id     => $client_id,
        client_secret => $client_secret,
        username      => $username,
        password      => $password,
        tokenstore    => $tokenstore,
        debug         => $debug,
);

print Dumper $netatmo;