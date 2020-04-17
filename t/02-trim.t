#!/usr/bin/env raku
use Test;
use BitEnum;

plan 10;

my enum MyBits (
    LONG_PREFIX_A => 0x01,
    LONG_PREFIX_B => 0x02,
    LONG_PREFIX_C => 0x04,
    LONG_PREFIX_D => 0x08,
);

does-ok my $x = BitEnum[MyBits, prefix => 'LONG_PREFIX_', :lc].new(6),
    BitEnum, 'create';

is $x.gist, '6 = c b'|'6 = b c', 'gist';

is ~$x, 'b c'|'c b', 'Str';

lives-ok { $x.set(LONG_PREFIX_A, LONG_PREFIX_B) }, 'set A,B';

is +$x, 7, 'A is set';

lives-ok { $x.clear(LONG_PREFIX_B) }, 'clear B';

is +$x, 5, 'A and C are set';

lives-ok { $x.toggle(LONG_PREFIX_A, LONG_PREFIX_D) }, 'toggle A,D';

is +$x, 12, 'C and D are set';

is ~$x, 'c d'|'d c', 'Str';

done-testing;
