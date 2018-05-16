package Kauwgom::Host;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
	_input  => sub {},
	_output => sub {},
);

sub BUILDARGS ($class, @args) {
	my $args = $class->SUPER::BUILDARGS( @args );
	$args->{_input}  = delete $args->{input}  || die 'You must supply an input channel';
	$args->{_output} = delete $args->{output} || die 'You must supply an output channel';
	return $args;
}

sub name    { 'perl/Kauwgom' }
sub version { join '/' => $^V, $VERSION }

sub input  ($self) { $self->{_input}  }
sub output ($self) { $self->{_output} }

sub reset_channels ($self) {
	$self->input->reset;
	$self->output->reset;
}

1;

__END__