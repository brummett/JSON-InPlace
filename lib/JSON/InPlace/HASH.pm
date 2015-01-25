use strict;
use warnings;

package JSON::InPlace::HASH;

use JSON::InPlace::BaseHandler
    '_reencode',
    '_recurse_wrap_value',
    'constructor' => { type => 'HASH', -as => 'constructor'};

BEGIN {
    *TIEHASH = \&constructor;
}

sub FETCH {
    my($self, $key) = @_;
    return $self->{data}->{$key};
}

sub STORE {
    my($self, $key, $val) = @_;
    $self->{data}->{$key} = $self->_recurse_wrap_value($val);
    $self->_reencode;
    return $val;
}

sub DELETE {
    my($self, $key) = @_;
    my $val = delete $self->{data}->{$key};
    $self->_reencode;
    return $val;
}

sub CLEAR {
    my $self = shift;
    %{$self->{data}} = ();
    $self->_reencode;
}

sub EXISTS {
    my($self, $key) = @_;
    return exists $self->{data}->{$key};
}

sub FIRSTKEY {
    my $self = shift;
    keys(%{$self->{data}}); # reset the iterator
    each %{$self->{data}};
}

sub NEXTKEY { each %{shift->{data}} }
sub SCALAR  { scalar( %{ shift->{data} } ) }

1;
