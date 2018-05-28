#!perl

use v5.24;
use warnings;

use Test::More;

BEGIN {
    use_ok('Ijsstokje::Loader::XML');
}

subtest '... testing page' => sub {

    my $p = Ijsstokje::Loader::XML->new->parse_file('root/app.xml');
	isa_ok($p, 'Ijsstokje::Page');

	subtest '... testing the store' => sub {
		my $s = $p->store;
		isa_ok($s, 'Ijsstokje::Page::Store');

		ok($s->has_provider_for('Foo'), '... we have a Foo provider');
		ok($s->has_provider_for('Baz'), '... we do not have a Baz provider');

		subtest '... testing the store provider' => sub {
			my $provider = $s->get_provider_for('Foo');
			isa_ok($provider, 'Ijsstokje::Page::Store::Provider');

			is($provider->name, 'Foo', '... got the name we expected');
			is($provider->type, 'perl', '... got the type we expected');
			is($provider->handler, 'Some::Class::Foo', '... got the handler we expected');
		};
	};

	subtest '... testing the server component' => sub {

		ok($p->has_server_components, '... we have some server components');

		my ($c) = $p->server_components;
		isa_ok($c, 'Ijsstokje::Page::Component');

		is($c->type, 'svelte', '... got the expected type');
		is($c->src, 'Foo-Card.js', '... got the expected src');
		is($c->env, 'server', '... got the expected env');
		is_deeply(
			$c->depends_on,
			[ map Vislijn::Reference->new( $_ ), 'store:Foo', 'store:Baz', 'config:card.defaults' ],
			'... got the expected depends_on'
		);
	};

	subtest '... testing the client component' => sub {
		ok($p->has_client_components, '... we have some client components');

		my ($c) = $p->client_components;
		isa_ok($c, 'Ijsstokje::Page::Component');

		is($c->type, 'svelte', '... got the expected type');
		is($c->src, 'Modal.js', '... got the expected src');
		is($c->env, 'client', '... got the expected env');
		is_deeply($c->depends_on, [ Vislijn::Reference->new( 'store:Baz' ) ],  '... got the expected depends_on');
	};

	subtest '... testing page body' => sub {
		my $b = $p->body;
		isa_ok($b, 'Ijsstokje::Page::Body');

		is($b->layout, 'extranet-two-column', '... got the expected layout');
		is($b->header, 'extranet-header', '... got the expected header');
		is($b->footer, 'extranet-footer', '... got the expected footer');
	};

};


done_testing;
