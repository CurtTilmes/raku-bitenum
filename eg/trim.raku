#!/usr/bin/env raku

use BitEnum;

my enum MyBits (
    LONG_PREFIX_A => 0x01,
    LONG_PREFIX_B => 0x02,
    LONG_PREFIX_C => 0x04,
    LONG_PREFIX_D => 0x08,
);

my $x = BitEnum[MyBits, prefix => 'LONG_PREFIX_', :lc].new(6);

put $x;
