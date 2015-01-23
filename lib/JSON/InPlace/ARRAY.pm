use strict;
use warnings;

package JSON::InPlace::ARRAY;

use Carp qw(croak);

sub TIEARRAY {
    my($class, %params) = @_;

    my $self = bless \%params, $class;
    _validate_constructor_params($self);
    return $self;
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

sub FETCH {
    my($self, $idx) = @_;
    return $self->{data}->[$idx];
}

sub STORE {
    my($self, $idx, $val) = @_;
    $self->{data}->[$idx] = $val;
    $self->_reencode;
    return $val;
}

sub FETCHSIZE {
    return scalar @{shift->{data}};
}

sub STORESIZE {
    my($self, $len) = @_;
    $#{$self->{data}} = $len - 1;
    $self->_reencode;
    return $len;
}

sub EXTEND { goto &STORESIZE }

sub EXISTS {
    my($self, $idx) = @_;
    return($self->FETCHSIZE < $idx);
}

sub DELETE {
    my($self, $idx) = @_;
    my $val = $self->{data}->[$idx];
    $self->{data}->[$idx] = undef;
    return $val;
}

sub CLEAR {
    shift->{data} = [];
}

sub PUSH {
    my $self = shift;
    return push @{$self->{data}}, @_;
}

sub POP {
    return pop @{shift->{data}};
}

sub SHIFT {
    return shift @{shift->{data}};
}

sub UNSHIFT {
    my $self = shift;
    return unshift @{$self->{data}}, @_;
}

sub SPLICE {
    my $self = shift;
    return splice @{$self}, @_;
}

1;    
