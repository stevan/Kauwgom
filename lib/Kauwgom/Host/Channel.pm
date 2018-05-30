package Kauwgom::Host::Channel;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object';
use slots ( _state  => sub {} );

sub BUILDARGS ($class, @args) {
    Carp::confess('Expected no arguments to `new`, got '.scalar @args)
        if @args;
}

sub read  ($self)         { return $self->{_state} }
sub write ($self, $value) { $self->{_state} = $value; return }
sub reset ($self)         { $self->{_state} = undef;  return }

__PACKAGE__;

__END__
