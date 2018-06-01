#!perl

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Path::Tiny    ();
use Plack::Util   ();
use Plack::Test   ();
use JSON::MaybeXS ();

use Test::More;
use HTTP::Request::Common;

BEGIN {
    use_ok('Kauwgom::Application');
}

my $dir = Path::Tiny::path(__FILE__)
            ->parent # /t/001-Kauwgom
            ->parent # /t
            ->parent # /
            ->child('examples/Basic');

my $app  = Plack::Util::load_psgi( $dir->child('app.psgi')->stringify );
my $test = Plack::Test->create( $app );

subtest '... simple GET' => sub {
    my $res = $test->request(GET "/");

    is($res->code, 200, '... status is 200');
    ok($res->headers->header('Content-Length'), '... got an expected content length');
    is($res->headers->header('X-Duktape'), '20200', '... got the expeced Duktape version');
    is($res->headers->header('X-Kauwgom-Host'), 'v5.24.3/0.01', '... got the expected Kauwgom Host version');
    is($res->headers->header('Content-Type'), 'application/json', '... got the expected Content-Type');
    is($res->headers->header('X-Kauwgom'),  '0.0.0', '... got the expected Kauwgom version');

    my $data = JSON::MaybeXS->new->decode( $res->content );
    eval { delete $data->{ENV}->{REMOTE_PORT} }; # Plack::Test randomizes this ..
    is_deeply(
        $data,
        {
            ENV => {
                SCRIPT_NAME     =>  "",
                CONTENT_LENGTH  =>  0,
                REQUEST_METHOD  =>  "GET",
                SERVER_PROTOCOL =>  "HTTP/1.1",
                REMOTE_HOST     =>  "localhost",
                SERVER_PORT     =>  80,
                REMOTE_ADDR     =>  "127.0.0.1",
                SERVER_NAME     =>  "localhost",
                QUERY_STRING    =>  "",
                REQUEST_URI     =>  "/",
                PATH_INFO       =>  "/",
                HTTP_HOST       =>  "localhost"
            },
            TMPL_DATA => { hello => [] },
            'Test-Data' => [ 11, 12, 13 ]
        },
        '.. got the expected data'
    );
};

subtest '... simple GET with PATH_INFO' => sub {
    my $res = $test->request(GET "/world");

    is($res->code, 200, '... status is 200');

    my $data = JSON::MaybeXS->new->decode( $res->content );

    #use Data::Dumper;
    #warn Dumper $data;

    is_deeply( $data->{TMPL_DATA}->{hello}, ['world'], '.. got the expected data' );
};

subtest '... simple GET with (more) PATH_INFO' => sub {
    my $res = $test->request(GET "/foo/bar/baz/gorch");

    is($res->code, 200, '... status is 200');

    my $data = JSON::MaybeXS->new->decode( $res->content );

    #use Data::Dumper;
    #warn Dumper $data;

    is_deeply( $data->{TMPL_DATA}->{hello}, ['foo', 'bar', 'baz', 'gorch'], '.. got the expected data' );
};

subtest '... non-GET error condition' => sub {
    my $res = $test->request(POST "/");

    is($res->code, 405, '... status is 405');
    is($res->content, "Method POST not allowed\n", '... got the expected error message');
};

done_testing;
