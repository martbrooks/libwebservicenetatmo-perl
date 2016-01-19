package WebService::Netatmo::WeatherStation;

use Moo;
use Data::Dumper;
use parent 'WebService::Netatmo::Common';

sub BUILD {
    my $self = shift;
    $self->_get_or_refresh_token();
}

1;
