use strict;
use warnings;

package JSON::InPlace::BaseHandler;

use Carp qw(croak);
use Sub::Exporter -setup => {
    exports => [
        '_reencode',
        'constructor' => \&build_constructor,
    ]
};

sub build_constructor {
    my($class, $name, $args) = @_;

    my $type = $args->{type};
    my $validator = sub {
        my $params = shift;

        unless ($params->{data} and ref($params->{data}) eq $type) {
            croak(qq(Expected $type ref for param 'data', but got ).ref($params->{data}));
        }
        unless ($params->{inplace_obj}) {
            croak('inplace_obj is a required param');
        }
    };

    return sub {
        my($class, %params) = @_;

        $validator->(\%params);
        return bless \%params, $class;
    };
}

sub _reencode { shift->{inplace_obj}->encode }

1;
