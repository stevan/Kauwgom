#!perl

use v5.24;
use warnings;

use Test::More;

BEGIN {
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
                        'request.query:foo'               => 'bar',
                        'request.query:bar'               => 'foo',
                        'request.header:Content-Type'     => 'return_type',
                        'session:user.name'               => 'user',
                        'config:is.allowed'               => 'is_allowed',
                        'experiment:test_show_extra_data' => 'show_extra_data',
                    }
                ),
                Ijsstokje::Page::Store::Provider->new(
                    type       => 'perl',
                    name       => 'Bar',
                    handler    => 'Some::Class::Bar',
                    parameters => {
                        'session:user.name' => 'user',
                    }
                )
            ]
        ),
        server_components => [
            Ijsstokje::Page::Component->new( type => 'svelte', name => 'Foo-Card.js' ),
            Ijsstokje::Page::Component->new( type => 'svelte', name => 'UI-Button.js' ),
        ],
        client_components => [
            Ijsstokje::Page::Component->new( type => 'svelte', name => 'Modal.js' ),
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
