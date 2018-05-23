package Ijsstokje::Page::Store;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _provider_map => sub { +{} }
);

sub BUILD ($self, $params) {
    # TODO
    # type checks and such ...
    # - SL

    my $providers = $params->{providers};

    foreach my $provider ( $providers->@* ) {
        $self->{_provider_map}->{ $provider->name } = $provider;
    }
}

sub has_provider_for ($self, $name) { exists $self->{_provider_map}->{ $name } }
sub get_provider_for ($self, $name) {        $self->{_provider_map}->{ $name } }

__PACKAGE__;

__END__
