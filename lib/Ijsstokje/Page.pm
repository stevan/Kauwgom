package Ijsstokje::Page;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _store        => sub {},
    _server_comps => sub {},
    _client_comps => sub {},
    _body         => sub {},
);

sub BUILD ($self, $params) {
    # TODO
    # do some type-check-ing here
    $self->{_store} = $params->{store} if exists $params->{store};
    $self->{_body}  = $params->{body}  if exists $params->{body};

    $self->{_server_comps}  = $params->{server_components}
        if exists $params->{server_components};

    $self->{_client_comps}  = $params->{client_components}
        if exists $params->{client_components};
}

sub has_store ($self) { defined $self->{_store} }
sub store     ($self) {         $self->{_store} }

sub has_server_components ($self) { defined $self->{_server_comps} }
sub server_components     ($self) {         $self->{_server_comps} }

sub has_client_components ($self) { defined $self->{_client_comps} }
sub client_components     ($self) {         $self->{_client_comps} }

sub has_body ($self) { defined $self->{_body} }
sub body     ($self) {         $self->{_body} }

__PACKAGE__;

__END__
