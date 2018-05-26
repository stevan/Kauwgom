package Kauwgom;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Path::Tiny   ();
use Carp         ();
use Scalar::Util ();
use Ref::Util    ();

use JavaScript::Duktape::XS;

use Kauwgom::Host;
use Kauwgom::Host::Channel;

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
    $args->{_app} = delete $args->{app} || die 'You must pass in an `app` to run';
    return $args;
}

sub BUILD ($self, $params) {
    ## setup duktape ...
    $self->{_duk} = JavaScript::Duktape::XS->new({ gather_stats => 1 });
}

sub to_app {
    my $self = shift;
    $self->prepare_app;
    return sub { $self->call(@_) };
}

sub prepare_app ($self) {

    my $app  = $self->{_app};
    my $duk  = $self->{_duk};
    my $host = $self->{_host};

    ## load the core JS library
    $duk->eval( Path::Tiny::path(__FILE__)->parent->child('Kauwgom/JS/Kauwgom.js')->slurp_utf8 );

    ## setup the host ...
    $duk->set('Kauwgom.Host.name',             $host->name);
    $duk->set('Kauwgom.Host.version',          $host->version);
    $duk->set('Kauwgom.Host.channels.INPUT',   sub ()      { return $host->input->read           });
    $duk->set('Kauwgom.Host.channels.OUTPUT',  sub ($resp) { $host->output->write($resp); return });

    ## give the app a chance to set up ...
    $app->prepare_app;
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
    if ( Ref::Util::is_hashref( $output->[1] ) ) {
        $output->[1] = [
            map {
                my $k = $_;
                my $v = $output->[1]->{ $_ };
                # if the value is an array
                Ref::Util::is_arrayref( $v )
                    ? (map { $k, $_ } @$v) # give us all the permutations
                    : ($k, $v);            # otherwise, just get the k/v pair
            } keys $output->[1]->%*
        ];
    }

    return $output;
}

__PACKAGE__;

__END__
