package Ijsstokje::Page;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _store => sub {},
    _comps => sub {},
    _body  => sub {},
);

sub BUILD ($self, $params) {
    # TODO
    # do some type-check-ing here
    $self->{_store} = $params->{store}      if exists $params->{store};
    $self->{_body}  = $params->{body}       if exists $params->{body};
    $self->{_comps} = $params->{components} if exists $params->{components};
}

sub has_store ($self) { defined $self->{_store} }
sub store     ($self) {         $self->{_store} }

sub has_server_components ($self) { !! scalar $self->server_components }
sub server_components     ($self) { grep $_->env eq 'server', $self->{_comps}->@* }

sub has_client_components ($self) { !! scalar $self->client_components }
sub client_components     ($self) { grep $_->env eq 'client', $self->{_comps}->@* }

sub has_body ($self) { defined $self->{_body} }
sub body     ($self) {         $self->{_body} }

__PACKAGE__;

__END__
