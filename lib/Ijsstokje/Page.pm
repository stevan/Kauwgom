package Ijsstokje::Page;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    store      => sub {},
    components => sub {},
    body       => sub {},
);

sub has_store ($self) { defined $self->{store} }
sub store     ($self) {         $self->{store} }

sub has_server_components ($self) { !! scalar $self->server_components }
sub server_components     ($self) { grep $_->env eq 'server', $self->{components}->@* }

sub has_client_components ($self) { !! scalar $self->client_components }
sub client_components     ($self) { grep $_->env eq 'client', $self->{components}->@* }

sub has_body ($self) { defined $self->{body} }
sub body     ($self) {         $self->{body} }

__PACKAGE__;

__END__
