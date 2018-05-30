#!perl

use v5.24;
use warnings;

use Test::More;

BEGIN {
    use_ok('Vislijn::Ref');

    use_ok('Ijsstokje::Page');
    use_ok('Ijsstokje::Page::Store');
    use_ok('Ijsstokje::Page::Store::Provider');
    use_ok('Ijsstokje::Page::Component');
    use_ok('Ijsstokje::Page::Body');

	use_ok('Ijsstokje::Loader::XML');
}

sub _load_from_xml {
	my $XML = do { local $/; <DATA> };
	Ijsstokje::Loader::XML->new->parse_string( $XML );
}

sub _load_from_perl {
	Ijsstokje::Page->new(
        store => Ijsstokje::Page::Store->new(
            Foo => Ijsstokje::Page::Store::Provider->new(
                type       => 'perl',
                handler    => 'Some::Class::Foo',
                parameters => {
                    bar             => Vislijn::Ref->new( 'request.query:foo' ),
                    foo             => Vislijn::Ref->new( 'request.query:bar' ),
                    return_type     => Vislijn::Ref->new( 'request.header:Content-Type' ),
                    user            => Vislijn::Ref->new( 'session:user.name' ),
                    is_allowed      => Vislijn::Ref->new( 'config:is.allowed' ),
                    show_extra_data => Vislijn::Ref->new( 'experiment:test_show_extra_data' ),
                }
            ),
            Baz => Ijsstokje::Page::Store::Provider->new(
                type       => 'perl',
                handler    => 'Some::Class::Baz',
                parameters => {
                    user => Vislijn::Ref->new( 'session:user.name' ),
                }
            )
        ),
        components => [
            Ijsstokje::Page::Component->new(
                type       => 'svelte',
                src        => 'Foo-Card.js',
                env        => 'server',
                depends_on => [
                    Vislijn::Ref->new( 'store:Foo' ),
                    Vislijn::Ref->new( 'store:Baz' ),
                    Vislijn::Ref->new( 'config:card.defaults' ),
                ]
            ),
            Ijsstokje::Page::Component->new(
                type       => 'svelte',
                src        => 'Modal.js',
                env        => 'client',
                depends_on => [
                    Vislijn::Ref->new( 'store:Baz' ),
                ]
            ),
        ],
        body => Ijsstokje::Page::Body->new(
            layout => 'extranet-two-column',
            header => 'extranet-header',
            footer => 'extranet-footer',
        )
    );
}

foreach my $p ( _load_from_xml(), _load_from_perl() ) {
	subtest '... testing page' => sub {

		isa_ok($p, 'Ijsstokje::Page');

		subtest '... testing the store' => sub {
			my $s = $p->store;
			isa_ok($s, 'Ijsstokje::Page::Store');

			ok($s->has_provider_for('Foo'), '... we have a Foo provider');
			ok($s->has_provider_for('Baz'), '... we do not have a Baz provider');

			subtest '... testing the store provider' => sub {
				my $provider = $s->get_provider_for('Foo');
				isa_ok($provider, 'Ijsstokje::Page::Store::Provider');

				is($provider->type, 'perl', '... got the type we expected');
				is($provider->handler, 'Some::Class::Foo', '... got the handler we expected');
			};
		};

		subtest '... testing the server component' => sub {

			ok($p->has_server_components, '... we have some server components');

			my ($c) = $p->server_components;
			isa_ok($c, 'Ijsstokje::Page::Component');

            #use Data::Dumper; warn Dumper $c;

			is($c->type, 'svelte', '... got the expected type');
			is($c->src, 'Foo-Card.js', '... got the expected src');
			is($c->env, 'server', '... got the expected env');
			is_deeply(
				$c->depends_on,
				[ map Vislijn::Ref->new( $_ ), 'store:Foo', 'store:Baz', 'config:card.defaults' ],
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
			is_deeply($c->depends_on, [ Vislijn::Ref->new( 'store:Baz' ) ],  '... got the expected depends_on');
		};

		subtest '... testing page body' => sub {
			my $b = $p->body;
			isa_ok($b, 'Ijsstokje::Page::Body');

			is($b->layout, 'extranet-two-column', '... got the expected layout');
			is($b->header, 'extranet-header', '... got the expected header');
			is($b->footer, 'extranet-footer', '... got the expected footer');
		};

	};
}

done_testing;

__DATA__
<page>

	<store>
		<tmpl-data name="Foo" provider="perl/Some::Class::Foo">
			<param from="request.query:foo"               to="bar" />
			<param from="request.query:bar"               to="foo" />
			<param from="request.header:Content-Type"     to="return_type" />
			<param from="session:user.name"               to="user" />
			<param from="config:is.allowed"               to="is_allowed" />
			<param from="experiment:test_show_extra_data" to="show_extra_data" />
		</tmpl-data>
		<tmpl-data name="Baz" provider="perl/Some::Class::Baz">
			<param from="session:user.name" to="user" />
		</tmpl-data>
	</store>

	<component type="svelte" src="Foo-Card.js" env="server">
		<depends on="store:Foo" />
		<depends on="store:Baz" />
		<depends on="config:card.defaults" />
	</component>

	<component type="svelte" src="Modal.js" env="client">
		<depends on="store:Baz" />
	</component>

	<body
        layout="extranet-two-column"
		header="extranet-header"
		footer="extranet-footer" />

</page>




