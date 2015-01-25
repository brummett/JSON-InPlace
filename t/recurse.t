use strict;
use warnings;

use Test::More tests => 2;

use JSON::String;
use JSON;

my $codec = JSON->new->canonical;

subtest 'hash of arrays' => sub {
    plan tests => 10;

    my $orig = { a => "1", b => ['1', '2'], c => ['a', 'b'] };
    my $string = $codec->encode($orig);

    my $obj = JSON::String->tie($string);
    is_deeply($obj,
              $orig,
              'object hashifies');
    is(scalar(%$obj), scalar(%$orig), 'hash as scalar');
    foreach my $key ( qw( a b c )) {
        is_deeply($obj->{$key}, $orig->{$key}, "key $key");
    }

    $obj->{a} = $orig->{a} = 'hi';
    is($string,
        $codec->encode($orig),
        'changed string value');

    $obj->{b}->[0] = $orig->{b}->[0] = 'there';
    is($string,
        $codec->encode($orig),
        'changed sub-array value');

    $obj->{b} = $orig->{b} = ['3', '4'];
    is($string,
        $codec->encode($orig),
        'changed whole sub-array');

    $obj->{b}->[0] = $orig->{b}->[0] = 'changed';
    is($string,
        $codec->encode($orig),
        'changed a newly added array value');

    $obj->{b}->[2] = $orig->{b}->[2] = { key => 'value' };
    is($string,
        $codec->encode($orig),
        'add new hashref to array');
};

subtest 'array of hashes' => sub {
    plan tests => 4;

    my $orig = [ 0, 1, { a => 1, b => 2 } ];
    my $string = $codec->encode($orig);

    my $obj = JSON::String->tie($string);
    is_deeply($obj,
                $orig,
                'object arrayifies');

    $obj->[2]->{a} = $orig->[2]->{a} = 'changed';
    is($string,
        $codec->encode($orig),
        'change nested hash value');

    $obj->[0] = $orig->[0] = { new => 'hash' };
    is($string,
        $codec->encode($orig),
        'change string value in array to hashref');

    $obj->[0]->{new} = $orig->[0]->{new} = 'changed hash value';
    is($string,
        $codec->encode($orig),
        'change newly added hash value');
};
