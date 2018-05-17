package Balen::Draad;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Path::Tiny   ();
use Carp         ();
use Scalar::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object';
use slots (
	path    => sub { die 'You must supply a `path`' },
	data_cb => sub { sub { +{ hello => 'world' } }  },
);

sub BUILD ($self, $) {
	$self->{path} = Path::Tiny::path( $self->{path} )
		unless Scalar::Util::blessed( $self->{path} )
			&& $self->{path}->isa('Path::Tiny');
}

sub construct_tmpl_data ($self, $env) { $self->{data_cb}->( $env ) }

sub compile_source ($self) { $self->{path}->slurp }

__PACKAGE__;

__END__