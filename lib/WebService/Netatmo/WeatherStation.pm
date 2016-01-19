package WebService::Netatmo::WeatherStation;
use Moo;

use Cwd qw(abs_path);
use Data::Dumper;
use DateTime::Format::DateParse;
use File::Basename qw(dirname);
use JSON::XS;
use LWP::UserAgent;
use YAML::XS qw(LoadFile DumpFile);

use parent 'WebService::Netatmo::Common';

sub BUILD {
    my $self = shift;
    $self->_get_or_refresh_token();
}

1;
