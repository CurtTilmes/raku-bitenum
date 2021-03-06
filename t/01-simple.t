#!/usr/bin/env raku
use Test;
use BitEnum;

plan 10;

my enum MyBits (
    A => 0x01,
    B => 0x02,
    C => 0x04,
    D => 0x08,
);

does-ok my $x = BitEnum[MyBits].new(6), BitEnum[MyBits], 'create';

is $x.gist, '6 = C B'|'6 = B C', 'gist';

is ~$x, 'B C'|'C B', 'Str';

is +$x, 6, 'Numify';

lives-ok { $x.set(A,B) }, 'set A,B';

is +$x, 7, 'A is set';

lives-ok { $x.clear(B) }, 'clear B';

is +$x, 5, 'A and C are set';

lives-ok { $x.toggle(A,D) }, 'toggle A,D';

is +$x, 12, 'C and D are set';

done-testing;
