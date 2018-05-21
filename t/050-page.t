#!perl

use v5.24;
use warnings;

use Test::More;

BEGIN {
    use_ok('Kauwgom::Page');
    use_ok('Kauwgom::Page::Store');
    use_ok('Kauwgom::Page::Store::Provider');
    use_ok('Kauwgom::Page::Component');
    use_ok('Kauwgom::Page::Body');
}

subtest '... testing a simple page' => sub {

    my $p = Kauwgom::Page->new(
        store => Kauwgom::Page::Store->new(
            providers => [
                Kauwgom::Page::Store::Provider->new(
                    type         => 'perl',
                    name         => 'Foo',
                    handler      => 'Some::Class::Foo',
                    available_on => [ 'server', 'client' ],
                    parameters   => {
                        'request.query:foo'               => 'bar',
                        'request.query:bar'               => 'foo',
                        'request.header:Content-Type'     => 'return_type',
                        'session:user.name'               => 'user',
                        'config:is.allowed'               => 'is_allowed',
                        'experiment:test_show_extra_data' => 'show_extra_data',
                    }
                ),
                Kauwgom::Page::Store::Provider->new(
                    type         => 'perl',
                    name         => 'Bar',
                    handler      => 'Some::Class::Bar',
                    available_on => [ 'server' ],
                    parameters   => {
                        'session:user.name' => 'user',
                    }
                )
            ]
        ),
        server_components => [
            Kauwgom::Page::Component->new( type => 'svelte', name => 'Foo-Card.js' ),
            Kauwgom::Page::Component->new( type => 'svelte', name => 'UI-Button.js' ),
        ],
        client_components => [
            Kauwgom::Page::Component->new( type => 'svelte', name => 'Modal.js' ),
        ],
        body => Kauwgom::Page::Body->new(
            layout => 'two-column',
            header => 'extranet-header',
            footer => 'extranet-footer',
        )
    );

    isa_ok($p, 'Kauwgom::Page');
    isa_ok($p->body, 'Kauwgom::Page::Body');
    isa_ok($p->store, 'Kauwgom::Page::Store');

};

done_testing;
