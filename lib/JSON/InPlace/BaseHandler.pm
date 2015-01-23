use strict;
use warnings;

package JSON::InPlace::BaseHandler;

use Carp qw(croak);
use Exporter qw(import);

our @EXPORT = qw(_basic_constructor _reencode);

sub _basic_constructor {
    my($class, %params) = @_;

    _validate_constructor_params(\%params);
    return bless \%params, $class;
}

sub _validate_constructor_params {
    my $params = shift;

    unless ($params->{data} and ref($params->{data}) eq 'ARRAY') {
        croak(q(Expected ARRAY ref for param 'data', but got ).ref($params->{data}));
    }
    unless ($params->{inplace_obj}) {
        croak('inplace_obj is a required param');
    }
}

sub _reencode { shift->{inplace_obj}->encode }

1;
