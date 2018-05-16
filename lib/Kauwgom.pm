package Kauwgom;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use JavaScript::Duktape::XS;

use Path::Tiny   ();
use Scalar::Util ();

use Kauwgom::Host;
use Kauwgom::Host::Channel;

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
	app   => sub { die 'You must supply an `app` to run' },
	# internal slots
	_src  => sub {},
	_duk  => sub { JavaScript::Duktape::XS->new({ gather_stats => 1 }) },
	_host => sub { 
		Kauwgom::Host->new(
			input  => Kauwgom::Host::Channel->new,
			output => Kauwgom::Host::Channel->new,
		) 
	}
);

sub BUILD ($self, $) {
	$self->{_src} = Path::Tiny::path( $self->{app} )->slurp;
}

sub to_app ($self) {
    $self->prepare_app;
    return sub { $self->call(@_) };
}

sub prepare_app ($self) {
	## load the core JS library 
	$self->{_duk}->eval(
		Path::Tiny::path(__FILE__)->parent->child('Kauwgom/JS/Kauwgom.js')->slurp
	);
	## setup the host now ...
	$self->{_duk}->set('Kauwgom.Host.name',             $self->{_host}->name);
	$self->{_duk}->set('Kauwgom.Host.version',          $self->{_host}->version);
	$self->{_duk}->set('Kauwgom.Host.channels.INPUT',   sub ()      { return $self->{_host}->input->read           });
	$self->{_duk}->set('Kauwgom.Host.channels.OUTPUT',  sub ($resp) { $self->{_host}->output->write($resp); return });
}

sub call ($self, $env) {

    $self->{_host}->reset_channels;
    $self->{_host}->input->write( { $env->%{ grep !/^psgi(x)?\./, keys $env->%* } } );

    $self->{_duk}->eval( $self->{_src} );

    my $output = $self->{_host}->output->read;
    #warn Dumper $output;
    #warn Dumper $k->host->output;

    if ( ref $output->[1] eq 'HASH' ) {
        $output->[1] = [
            map {
                my $k = $_;
                my $v = $output->[1]->{ $_ };
                # if the value is an array
                ref $v eq 'ARRAY'
                    ? (map { $k, $_ } @$v) # give us all the permutations
                    : ($k, $v);            # otherwise, just get the k/v pair
            } keys $output->[1]->%*
        ];
    }

    return $output;
}

__PACKAGE__;

__END__