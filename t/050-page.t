#!perl

use v5.24;
use warnings;

use Test::More;

BEGIN {
    use_ok('Vislijn::Reference');

    use_ok('Ijsstokje::Page');
    use_ok('Ijsstokje::Page::Store');
    use_ok('Ijsstokje::Page::Store::Provider');
    use_ok('Ijsstokje::Page::Component');
    use_ok('Ijsstokje::Page::Body');
}

subtest '... testing a simple page' => sub {

    my $p = Ijsstokje::Page->new(
        store => Ijsstokje::Page::Store->new(
            providers => [
                Ijsstokje::Page::Store::Provider->new(
                    type       => 'perl',
                    name       => 'Foo',
                    handler    => 'Some::Class::Foo',
                    parameters => {
                        'bar'             => Vislijn::Reference->new( name => 'request.query',  args => [ 'foo' ] ),
                        'foo'             => Vislijn::Reference->new( name => 'request.query',  args => [ 'bar' ] ),
                        'return_type'     => Vislijn::Reference->new( name => 'request.header', args => [ 'Content-Type' ] ),
                        'user'            => Vislijn::Reference->new( name => 'session',        args => [ 'user.name' ] ),
                        'is_allowed'      => Vislijn::Reference->new( name => 'config',         args => [ 'is.allowed' ] ),
                        'show_extra_data' => Vislijn::Reference->new( name => 'experiment',     args => [ 'test_show_extra_data' ] ),
                    }
                ),
                Ijsstokje::Page::Store::Provider->new(
                    type       => 'perl',
                    name       => 'Bar',
                    handler    => 'Some::Class::Bar',
                    parameters => {
                        'user' => Vislijn::Reference->new( name => 'session', args => [ 'user.name' ] ),
                    }
                )
            ]
        ),
        components => [
            Ijsstokje::Page::Component->new(
                type       => 'svelte',
                name       => 'Foo-Card.js',
                env        => 'server',
                depends_on => [
                    Vislijn::Reference->new( name => 'store',  args => [ 'Foo' ] ),
                    Vislijn::Reference->new( name => 'store',  args => [ 'Baz' ] ),
                    Vislijn::Reference->new( name => 'config', args => [ 'card.defaults' ] ),
                ]
            ),
            Ijsstokje::Page::Component->new(
                type       => 'svelte',
                name       => 'Modal.js',
                env        => 'client',
                depends_on => [
                    Vislijn::Reference->new( name => 'store',  args => [ 'Baz' ] ),
                ]
            ),
        ],
        body => Ijsstokje::Page::Body->new(
            layout => 'two-column',
            header => 'extranet-header',
            footer => 'extranet-footer',
        )
    );

    isa_ok($p, 'Ijsstokje::Page');
    isa_ok($p->body, 'Ijsstokje::Page::Body');
    isa_ok($p->store, 'Ijsstokje::Page::Store');

};

done_testing;
