package Ijsstokje::Parameter;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp         ();
use Scalar::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _name => sub {},
    _ref  => sub {},
);

sub BUILDARGS ($class, @args) {
    Carp::confess('Expected two arguments, a name and a ref')
        unless scalar @args == 2;

    Carp::confess('The ref argument must be an instance of Vislijn::Ref')
        unless Scalar::Util::blessed( $args[1] )
            && $args[1]->isa('Vislijn::Ref');

    return { _name => $args[0], _ref => $args[1] };
}

sub name ($self) { $self->{_name} }
sub ref  ($self) { $self->{_ref}  }

__PACKAGE__;

__END__
