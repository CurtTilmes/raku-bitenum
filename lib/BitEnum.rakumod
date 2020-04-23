role BitEnum[::EnumBits, Str:D :$prefix = '', Bool :$lc]
{
    has Int $.value handles <Numeric Int> = 0;
    has Str $.prefix = $prefix;
    has Int $.length = $prefix ?? $prefix.chars !! 0;
    has Bool $.lc = $lc;

    multi method new(*@bits)
    {
        my $self = self.bless();
        $self.set(@bits) if @bits;
        $self
    }

    multi method new(Int:D $value) { self.bless(:$value) }

    sub lookup(Str:D $str is copy)
    {
        $str .= uc if $lc;
        EnumBits::{"$prefix$str"} // die "Bad value: $str"
    }

    method set(*@bits is copy --> Nil)
    {
        for @bits
        {
            $_ = lookup($_) when Str;
            $!value +|= .value
        }
    }

    method clear(*@bits is copy --> Nil)
    {
        for @bits
        {
            $_ = lookup($_) when Str;
            $!value +&= +^ .value
        }
    }

    method isset(*@bits is copy --> Bool:D)
    {
        for @bits
        {
            $_ = lookup($_) when Str;
            return False unless .value +& $!value == .value;
        }
        True
    }

    method toggle(*@bits is copy --> Nil)
    {
        for @bits
        {
            $_ = lookup($_) when Str;
            $!value +^= .value
        }
    }

    method list()         { EnumBits.enums.grep({ $.isset($_) }) }

    method Str()
    {
        join(' ',
             do for $.list().list
             {
                 my $str = .key;
                 $str .= substr($!length) if $!length;
                 $str .= lc if $!lc;
                 $str
             }
            )
    }

    method gist()         { "$!value = $.Str()" }
}

=begin pod

=head1 NAME

BitEnum -- Wrapper for Bitfields stored in an integer

=head1 SYNOPSIS

  use BitEnum;

  my enum MyBits (
    A => 0x01,
    B => 0x02,
    C => 0x04,
    D => 0x08,
  );

  my $x = BitEnum[MyBits].new(6);      # Pass in an integer
                                       # or
  my $x = BitEnum[MyBits].new(B,C);    # flags to set
                                       # or
  my $x = BitEnum[MyBits].new;         # nothing defaults to 0

  put $x;                              # Stringify to list of keys
  # B C                                # could also get "C B"

  put +$x;                             # Numify to value
  # 6

  say $x;                              # gistify to value and list
  6 = B C                              # or '6 = C B'

  $x.set(A,B);                         # Set bits

  $x.clear(B);                         # Clear bits

  say $x.isset(A,B);                   # Check if all listed bits are set
  # False

  $x.toggle(C);                        # Flip bits

  .key.say for @$x;                    # listify

=head1 DESCRIPTION

Especially when interfacing with Nativecall libraries, various flags
are often packed into an integer.  Helpful library developers
thoughfully provide various SET(), CLEAR(), ISSET(), etc. macros to
perform the bit manipulations for C programmers.  This module makes it
easy to wrap an Enumeration of bit field values with a parameterized
role that make it easy to perform the bit manipulations and human
display for such values from Perl 6.

Printing as a string or gist make it easy to see which bits are set,
and numifying and Int-ifying make it easy to pass in to routines that
just want the value.

=head2 COMBO keys

Sometimes libraries have convenience values that have multiple bits
set.  Those will work fine too.  You can handle them in one of two
ways.

Just put them into the enumeration like normal:

    my enum MyBits (
        A => 0x01,
        B => 0x02,
        C => 0x04,
        D => 0x08,
        AB => 0x03,
        BC => 0x06,
    );

    my $x = BitEnum[MyBits].new(6);

    say $x;

    # 6 = B C BC

    $x.set(AB, C);

    say $x;

    # 7 = AB BC A B C

or

Put them in their own, separate enumeration.  They won't show up in
the stringification, but you can still use them to
set/clear/etc. combinations of bits.

    my enum MyBits (
        A => 0x01,
        B => 0x02,
        C => 0x04,
        D => 0x08,
    );

    my enum Combos (
        AB => 0x03,
        BC => 0x06,
    );

    my $x = BitEnum[MyBits].new(6);

    say $x;

    # 6 = B C

    $x.set(AB, C);

    say $x;

    # 7 = A B C

=head2 Trimming prefixes

Sometimes the enumerated symbols have a common prefix that is nice to
remove for printing.  Pass an optional named parameter I<:prefix> with
a String and the number of characters in that string will be removed
from each key when stringifying.  Optionally lowercase them as well by
passing in I<:lc>.  You can also set/clear/toggle bits by substring
without the prefix.

    my enum MyBits (
        LONG_PREFIX_A => 0x01,
        LONG_PREFIX_B => 0x02,
        LONG_PREFIX_C => 0x04,
        LONG_PREFIX_D => 0x08,
    );

    my $x = BitEnum[MyBits, prefix => 'LONG_PREFIX_', :lc].new(6);

    put $x; # 'b c' or 'c b'

    $x.set(<a b>);
    $x.clear(<c>);

    put $x; # 'a b' or 'b a'

=head1 COPYRIGHT and LICENSE

Copyright 2019 Curt Tilmes

This module is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
