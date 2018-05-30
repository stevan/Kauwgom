package Ijsstokje::Page::Store;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp         ();
use Scalar::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _providers => sub { +{} }
);

sub BUILDARGS ($class, @args) {
    my $providers = $class->SUPER::BUILDARGS( @args );

    foreach my $p ( values $providers->%* ) {
        Carp::confess('providers must be CODE references, not ['.ref($p).']')
            unless Scalar::Util::blessed( $p )
                && $p->isa('Ijsstokje::Page::Store::Provider');
    }

    return { _providers => $providers };
}

sub has_provider_for ($self, $name) { exists $self->{_providers}->{ $name } }
sub get_provider_for ($self, $name) {        $self->{_providers}->{ $name } }

__PACKAGE__;

__END__
