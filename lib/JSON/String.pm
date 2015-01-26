use strict;
use warnings;

package JSON::String;

use Carp qw(croak);
our @CARP_NOT = qw(JSON::String::BaseHandler JSON::String::HASH JSON::String::ARRAY);
use JSON;

use JSON::String::ARRAY;
use JSON::String::HASH;

sub tie {
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
        CORE::tie @$self, 'JSON::String::ARRAY', data => $data, encoder => $encoder;
    } elsif (ref($data) eq 'HASH') {
        foreach my $key ( keys %$data ) {
            $data->{$key} = _construct_object($data->{$key}, undef, $encoder);
        }
        $self = {};
        CORE::tie %$self, 'JSON::String::HASH', data => $data, encoder => $encoder;
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
        my $val;
        my $error = do {
            local $@;
            $val = eval { $$str_ref = $codec->encode($data) };
            $@;
        };
        croak("Error encoding data structure: $error") if $error;
        return $val;
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

    my $data = codec()->decode($$ref);

    unless (ref($data) eq 'ARRAY' or ref($data) eq 'HASH') {
        croak('Cannot handle '.ref($data).' reference');
    }
    return $data;
}

1;
