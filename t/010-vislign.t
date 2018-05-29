#!perl

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Test::More;

BEGIN {
    use_ok('Vislijn::Ref');
    use_ok('Vislijn::Resolver');
}

my $ctx = { foo => 10, bar => 20 };

my @refs = (
    Vislijn::Ref->new( 'hash:foo' ),
    Vislijn::Ref->new( 'hash:bar' ),
    Vislijn::Ref->new( 'hash:baz' ),
);

my $resolver = Vislijn::Resolver->new(
    hash => sub ($ctx, $name) { $ctx->{ $name } }
);

my ($foo, $bar, $baz) = $resolver->resolve( $ctx, \@refs )->@*;
is($foo, 10, '... got the right value for my foo Ref');
is($bar, 20, '... got the right value for my bar Ref');
is($baz, undef, '... got the right (lack of) value for my bar Ref');

done_testing;
