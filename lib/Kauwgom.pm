package Kauwgom;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Path::Tiny   ();
use Carp         ();
use Scalar::Util ();

use JavaScript::Duktape::XS;

use Kauwgom::Host;
use Kauwgom::Host::Channel;
use Kauwgom::Application;

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    # internal data ...
    _app  => sub {},
    _duk  => sub {},
	_host => sub { 
		Kauwgom::Host->new(
			input  => Kauwgom::Host::Channel->new,
			output => Kauwgom::Host::Channel->new,
		) 
	}
);

sub BUILDARGS ($class, @args) {
    my $args = $class->SUPER::BUILDARGS( @args );
    Carp::confess('You must provide an `application_path`')
        unless $args->{application_path};
    Carp::confess('You must provide an `tmpl_data_provider`')
        unless $args->{tmpl_data_provider};
    return $args;
}

sub BUILD ($self, $params) {
    # pull the app together ...
    $self->{_app} = Kauwgom::Application->new( $params->%{qw[ application_path tmpl_data_provider ]} );
    ## setup duktape ...
    $self->{_duk} = JavaScript::Duktape::XS->new({ gather_stats => 1 });          
}

sub to_app {
    my $self = shift;
    $self->prepare_app;
    return sub { $self->call(@_) };
}

sub prepare_app ($self) {

    my $duk  = $self->{_duk};
    my $host = $self->{_host};

	## load the core JS library 
	$duk->eval( Path::Tiny::path(__FILE__)->parent->child('Kauwgom/JS/Kauwgom.js')->slurp );

	## setup the host ...
	$duk->set('Kauwgom.Host.name',             $host->name);
	$duk->set('Kauwgom.Host.version',          $host->version);
	$duk->set('Kauwgom.Host.channels.INPUT',   sub ()      { return $host->input->read           });
	$duk->set('Kauwgom.Host.channels.OUTPUT',  sub ($resp) { $host->output->write($resp); return });
}

sub call ($self, $env) {

    my $app  = $self->{_app};
    my $duk  = $self->{_duk};
    my $host = $self->{_host};  

    ## setup the data
    my $tmpl_data = $app->construct_tmpl_data( $env );
    
    ## prepare the env
    my $prepared_env = { $env->%{ grep !/^psgi(x)?\./, keys $env->%* } };

    ## reset the channels and write new input ...
    $host->reset_channels;
    $host->input->write( { env => $prepared_env, tmpl_data => $tmpl_data } );

    ## eval the source and run the application 
    $duk->eval( $app->compile_source );

    ## then fetch the output 
    my $output = $host->output->read;

    # convert any header hashes into PSGI arrays
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