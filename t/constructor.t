use strict;
use warnings;

use Test::More tests => 4;
use Test::Exception;

use JSON::InPlace;

sub expected_error {
    my $expected = shift;

    my(undef, $file, $line) = caller();
    $line--;
    my $expected_error = quotemeta(sprintf('%s at %s line %s.',
                                    $expected, $file, $line));
    return qr(^$expected_error$);
}

subtest 'from string' => sub {
    plan tests => 2;

    my $string = '[1]';
    my $obj = JSON::InPlace->new(\$string);
    ok($obj, 'new');

    $obj->[0] = 2;
    is($string, '[2]', 'changed value');
};

subtest 'from array elt' => sub {
    my $array = ['[1]'];
    my $obj = JSON::InPlace->new(\$array->[0]);
    ok($obj, 'new');

    $obj->[0] = 2;
    is_deeply($array,
            ['[2]'],
            'changed value');
};

subtest 'from hash value' => sub {
    my $hash = { key => '[1]' };
    my $obj = JSON::InPlace->new(\$hash->{key});
    ok($obj, 'new');

    $obj->[0] = 2;
    is_deeply($hash,
            { key => '[2]' },
            'changed value');
};

subtest 'errors' => sub {
    plan tests => 6;

    throws_ok { JSON::InPlace->new() }
        expected_error 'Expected SCALAR ref, but got <undef>',
        'no args';

    throws_ok { JSON::InPlace->new('') }
        expected_error 'Expected SCALAR ref, but got <empty string>',
        'empty string';

    throws_ok { JSON::InPlace->new('hi') }
        expected_error 'Expected SCALAR ref, but got hi',
        'non-reference';

    throws_ok { JSON::InPlace->new(\q(["1"])) }
        expected_error 'SCALAR ref is not writable',
        'non-writable reference';

    my $json_string = q(["1"]);
    throws_ok { JSON::InPlace->new($json_string) }
        expected_error "Expected SCALAR ref, but got $json_string",
        'valid json, non-reference';

    throws_ok { my $str = 'bad json'; JSON::InPlace->new(\$str) }
        qr(malformed JSON string),
        'bad json';
};
