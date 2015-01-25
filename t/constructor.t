use strict;
use warnings;

use Test::More tests => 1;
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
