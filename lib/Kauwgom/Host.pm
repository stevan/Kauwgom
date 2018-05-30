package Kauwgom::Host;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp         ();
use Scalar::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _input  => sub {},
    _output => sub {},
);

sub BUILDARGS ($class, @args) {
    my $args   = $class->SUPER::BUILDARGS( @args );

    my $input  = delete $args->{input}  || Carp::confess('You must supply an input channel');
    my $output = delete $args->{output} || Carp::confess('You must supply an output channel');

    Carp::confess('Supplied input channel must be `Kauwgom::Host::Channel`')
        unless Scalar::Util::blessed( $input )
            && $input->isa('Kauwgom::Host::Channel');

    Carp::confess('Supplied output channel must be `Kauwgom::Host::Channel`')
        unless Scalar::Util::blessed( $output )
            && $output->isa('Kauwgom::Host::Channel');

    return { _input => $input, _output => $output };
}

sub name    { 'perl/Kauwgom' }
sub version { join '/' => $^V, $VERSION }

sub input  ($self) { $self->{_input}  }
sub output ($self) { $self->{_output} }

sub reset_channels ($self) {
    $self->input->reset;
    $self->output->reset;
}

__PACKAGE__;

__END__
