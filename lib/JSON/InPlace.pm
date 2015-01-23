use strict;
use warnings;

package JSON::InPlace;

use Carp qw(croak);
use JSON;
use Symbol;
use overload '@{}' => '_arrayref',
             'bool' => sub { 1 };

use JSON::InPlace::ARRAY;

sub new {
    my($class, $ref) = @_;

    my $data = _validate_string_ref($ref);
    my $self = bless(Symbol::gensym(), $class);

    if (ref($data) eq 'ARRAY') {
        *{$self} = [];
        tie @{*{$self}{ARRAY}}, 'JSON::InPlace::ARRAY', data => $data, inplace_obj => $self;
    } else {
        %$self = $data;
    }

    *$self = $ref;
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

sub encode {
    my $self = shift;

    my $it = @$self
            ? *{$self}{ARRAY}
            : *{$self}{HASH};

    my $encoded = $self->codec->encode($it);
    my $ref = *{$self}{SCALAR};
    $$ref = $encoded;
}

sub _validate_string_ref {
    my $ref = shift;

    unless (ref($ref) eq 'SCALAR') {
        croak('Expected SCALAR ref, but got ',ref($ref));
    }
    unless (length $$ref) {
        croak('SCALAR ref must point to a non-empty string');
    }
    my $data = codec()->decode($$ref);

    unless (ref($data) eq 'ARRAY' or ref($data) eq 'HASH') {
        croak('Expected JSON string to decode into ARRAY or HASH ref, but got ', ref($data));
    }
    return $data;
}

sub _arrayref {
    my $self = shift;
    return *{$self}{ARRAY};
}

1;
