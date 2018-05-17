package Kauwgom;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Path::Tiny   ();
use Carp         ();
use Scalar::Util ();

use Kauwgom::Host;
use Kauwgom::Host::Channel;

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
	wire    => sub { die 'You must supply some `wire` to use' },
    duktape => sub { die 'You must supply some `duktape` to use' },
	# internal slots
	_host => sub { 
		Kauwgom::Host->new(
			input  => Kauwgom::Host::Channel->new,
			output => Kauwgom::Host::Channel->new,
		) 
	}
);

sub BUILD ($self, $) {
    Carp::confess('The `wire` supplied must be an instance of Wire::Bale')
        unless Scalar::Util::blessed( $self->{wire} ) 
            && $self->{wire}->isa('Balen::Draad');

    Carp::confess('The `duktape` supplied must be an instance of Javascript::Duktape::XS')
        unless Scalar::Util::blessed( $self->{duktape} ) 
            && $self->{duktape}->isa('JavaScript::Duktape::XS');              
}

sub to_app {
    my $self = shift;
    $self->prepare_app;
    return sub { $self->call(@_) };
}

sub prepare_app ($self) {

    my $duk  = $self->{duktape};
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

    my $wire = $self->{wire};
    my $duk  = $self->{duktape};
    my $host = $self->{_host};  

    ## setup the data
    my $tmpl_data = $wire->construct_tmpl_data( $env );
    
    ## prepare the env
    my $prepared_env = { $env->%{ grep !/^psgi(x)?\./, keys $env->%* } };

    ## reset the channels and write new input ...
    $host->reset_channels;
    $host->input->write( { env => $prepared_env, tmpl_data => $tmpl_data } );

    ## eval the source and run the application 
    $duk->eval( $wire->compile_source );

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