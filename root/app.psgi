#!perl

use v5.24;
use warnings;
use experimental 'signatures';

use Plack::Request;

use Kauwgom;
use Balen::Draad;
use JavaScript::Duktape::XS;

Kauwgom->new( 
	duktape => JavaScript::Duktape::XS->new({ gather_stats => 1 }),	
	wire    => Balen::Draad->new( 
		path    => './app.js',
		data_cb => sub ($env) {
			return +{
				hello => $env->{PATH_INFO}
			}
		}
	),
)->to_app;
