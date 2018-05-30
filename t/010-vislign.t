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
    Vislijn::Ref->new( 'at:foo' ),
    Vislijn::Ref->new( 'at:bar' ),
    Vislijn::Ref->new( 'keys' ),
    Vislijn::Ref->new( 'at:baz' ),
    Vislijn::Ref->new( 'values' ),
);

my $resolver = Vislijn::Resolver->new(
    keys   => sub ($ctx)        { [ sort   keys $ctx->%* ] },
    values => sub ($ctx)        { [ sort values $ctx->%* ] },
    at     => sub ($ctx, $name) {          $ctx->{ $name } },
);

my ($foo, $bar, $keys, $baz, $values) = $resolver->resolve( $ctx, \@refs )->@*;
is($foo, 10, '... got the right value for my foo Ref');
is($bar, 20, '... got the right value for my bar Ref');
is($baz, undef, '... got the right (lack of) value for my bar Ref');
is_deeply($keys, [qw[ bar foo ]], '... got the right keys');
is_deeply($values, [10, 20], '... got the right keys');

is_deeply(
    [ map $_->to_string, @refs ],
    [qw[ at:foo at:bar keys at:baz values ]],
    '... got the right stringification for the refs'
);

done_testing;
