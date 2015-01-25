use strict;
use warnings;

package JSON::InPlace;

use Carp qw(croak);
use JSON;

use JSON::InPlace::ARRAY;
use JSON::InPlace::HASH;

sub new {
    my($class, $string) = @_;
    my $ref = \$_[1];

    my $data = _validate_string_ref($ref);
    return _construct_object($data, $ref);
}

sub _construct_object {
    my($data, $str_ref, $encoder) = @_;

    croak('Either string ref or encoder sub expected, not both') if ($str_ref and $encoder);

    return $data unless ref $data;

    $encoder = _create_encoder($data, $str_ref) unless $encoder;

    my $self;
    if (ref($data) eq 'ARRAY') {
        foreach my $elt ( @$data ) {
            $elt = _construct_object($elt, undef, $encoder);
        }
        $self = [];
        tie @$self, 'JSON::InPlace::ARRAY', data => $data, encoder => $encoder;
    } elsif (ref($data) eq 'HASH') {
        foreach my $key ( keys %$data ) {
            $data->{$key} = _construct_object($data->{$key}, undef, $encoder);
        }
        $self = {};
        tie %$self, 'JSON::InPlace::HASH', data => $data, encoder => $encoder;
    } else {
        croak('Cannot handle '.ref($data). ' reference');
    }

    return $self;
}

{
    my $codec = JSON->new->canonical;
    sub codec {
        shift;
        if (@_) {
            $codec = shift;
        }
        return $codec;
    }
}

sub _create_encoder {
    my($data, $str_ref) = @_;

    my $codec = codec;
    return sub {
        $$str_ref = $codec->encode($data);
    };
}

sub _validate_string_ref {
    my $ref = shift;

    unless (ref $ref eq 'SCALAR') {
        croak q(Expected plain string, but got reference);
    }
    unless (defined $$ref) {
        croak('Expected string, but got <undef>');
    }
    unless (length $$ref) {
        croak('Expected non-empty string');
    }
    my $error = do {
        local $@;
        eval { $$ref .= '' };
        $@;
    };
    if ($error) {
        croak('String is not writable');
    }

    my $data = codec()->decode($$ref);

    unless (ref($data) eq 'ARRAY' or ref($data) eq 'HASH') {
        croak('Expected JSON string to decode into ARRAY or HASH ref, but got ', ref($data));
    }
    return $data;
}

sub _description_of {
    my $val = shift;
    if (! defined $val) {
        return '<undef>';
    } elsif (! length $val) {
        return '<empty string>';
    } elsif (! ref $val) {
        return $val;
    } else {
        return(ref($val) . ' ref');
    }
}

1;
