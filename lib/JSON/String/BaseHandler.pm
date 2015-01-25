use strict;
use warnings;

package JSON::String::BaseHandler;

use Carp qw(croak);
use Sub::Exporter -setup => {
    exports => [
        '_reencode',
        '_recurse_wrap_value',
        'constructor' => \&build_constructor,
    ]
};

require JSON::String;

sub build_constructor {
    my($class, $name, $args) = @_;

    my $type = $args->{type};
    my $validator = sub {
        my $params = shift;

        unless ($params->{data} and ref($params->{data}) eq $type) {
            croak(qq(Expected $type ref for param 'data', but got ).ref($params->{data}));
        }
        unless ($params->{encoder}) {
            croak('encoder is a required param');
        }
    };

    return sub {
        my($class, %params) = @_;

        $validator->(\%params);
        return bless \%params, $class;
    };
}

sub encoder { shift->{encoder} }

sub _reencode { encoder(shift)->() }

sub _recurse_wrap_value {
    my($self, $val) = @_;
    return JSON::String::_construct_object($val, undef, encoder($self));
}

1;
