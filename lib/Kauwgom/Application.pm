package Kauwgom::Application;

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
    _src     => sub {},
    _data_cb => sub {},
    _duk     => sub {},
    _host    => sub {
        Kauwgom::Host->new(
            input  => Kauwgom::Host::Channel->new,
            output => Kauwgom::Host::Channel->new,
        )
    }
);

sub BUILDARGS ($class, @args) {
    Carp::confess('Expected a path and tmpl_data callback, not ['.(join ', ' => @args).']')
        unless scalar @args == 2 && Ref::Util::is_coderef( $args[1] );

    $args[0] = Path::Tiny::path( $args[0] )
        unless Scalar::Util::blessed( $args[0] )
            && $args[0]->isa('Path::Tiny');

    return { _src => $args[0], _data_cb => $args[1] };
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

    my $src  = $self->{_src};
    my $duk  = $self->{_duk};
    my $host = $self->{_host};

    ## load the core JS library
    $duk->eval( Path::Tiny::path(__FILE__)->parent->child('JS/Kauwgom.js')->slurp_utf8 );

    ## setup the host ...
    $duk->set('Kauwgom.Host.name',             $host->name);
    $duk->set('Kauwgom.Host.version',          $host->version);
    $duk->set('Kauwgom.Host.channels.INPUT',   sub ()      { return $host->input->read           });
    $duk->set('Kauwgom.Host.channels.OUTPUT',  sub ($resp) { $host->output->write($resp); return });

    ## eval the source
    $duk->eval( $src->slurp_utf8 );

    Carp::confess(
        'Upon eval-ing the source we expected to find a `main` function '.
        'in the root Javascript namespace, it does not appear to be present.'
    ) unless $duk->exists('main');
}

sub call ($self, $env) {

    my $duk  = $self->{_duk};
    my $host = $self->{_host};

    my $tmpl_data = $self->{_data_cb}->( $env );

    ## prepare the env
    my $prepared_env = { $env->%{ grep !/^psgi(x)?\./, keys $env->%* } };

    ## reset the channels and write new input ...
    $host->reset_channels;
    $host->input->write( { env => $prepared_env, tmpl_data => $tmpl_data } );

    if ( $ENV{PLACK_ENV} eq 'development' ) {
        # TODO:
        # check the mod-time on the file,
        # no need to reload unless actually
        # changed.
        # - SL

        $duk->set('main', undef);
        $duk->eval( $self->{_src}->slurp_utf8 );
        Carp::confess(
            'Upon eval-ing the source we expected to find a `main` function '.
            'in the root Javascript namespace, it does not appear to be present.'
        ) unless $duk->exists('main');
    }

    ## run the application we eval-ed previously
    $duk->eval( 'Kauwgom.__RUN_MAIN__()' );

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
