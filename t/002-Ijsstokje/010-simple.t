#!perl

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Test::More;

use Path::Tiny ();
use Plack::Request;

BEGIN {
    use_ok('Ijsstokje::Loader::XML');
    use_ok('Vislijn::Resolver');
}


my $dir = Path::Tiny::path(__FILE__)
            ->parent # /t/002-Ijstokje
            ->parent # /t
            ->parent # /
            ->child('examples/Ijsstokje/HelloWorld');

## ...

my $page = Ijsstokje::Page->new(
    components => [
        Ijsstokje::Page::Component->new(
            src        => $dir->child('comp/app.js'),
            env        => 'server',
            parameters => [
                Ijsstokje::Parameter->new( place => Vislijn::Ref->new( 'request.query:place' ) ),
            ]
        )
    ],
    body => Ijsstokje::Page::Body->new(
        layout => $dir->child('root/layout.tmpl'),
    )
);
isa_ok($page, 'Ijsstokje::Page');

## ...

my $resolver = Vislijn::Resolver->new(
    'request.query' => sub ($r, $param) {
        return $r->query_parameters->get( $param )
    }
);
isa_ok($resolver, 'Vislijn::Resolver');

my $r = Plack::Request->new({
    REQUEST_METHOD  =>  "GET",
    QUERY_STRING    =>  "name=foo",
    PATH_INFO       =>  "/",
});

my $name = $resolver->resolve( $r, Vislijn::Ref->new('request.query:name') );

is($name, 'foo', '... got the right value from request.query:name');

## ..

my $body = $page->body;
isa_ok($body, 'Ijsstokje::Page::Body');

is(
    $body->render({ title => 'Foo', content => 'Bar' }),
    q|<html>
<head>
    <title>Foo</title>
</head>
<body>
    Bar
</body>
</html>
|, '... page rendered as expected'
);


done_testing;


