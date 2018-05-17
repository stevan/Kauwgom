package Kauwgom::Application;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Path::Tiny   ();
use Carp         ();
use Scalar::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object';
use slots (
    application_path   => sub { die 'You must supply an `application_path`' },
    tmpl_data_provider => sub { sub { +{ hello => 'world' } } },
);

sub BUILD ($self, $) {
    $self->{application_path} = Path::Tiny::path( $self->{application_path} )
        unless Scalar::Util::blessed( $self->{application_path} )
            && $self->{application_path}->isa('Path::Tiny');
}

sub construct_tmpl_data ($self, $env) { $self->{tmpl_data_provider}->( $env ) }

sub compile_source ($self) { $self->{application_path}->slurp_utf8 }

__PACKAGE__;

__END__
