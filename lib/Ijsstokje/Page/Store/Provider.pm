package Ijsstokje::Page::Store::Provider;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    type         => sub {},
    handler      => sub {},
    parameters   => sub { +[] },
);

## add Type checking here

sub type    ($self) { $self->{type}    }
sub handler ($self) { $self->{handler} }

sub parameters ($self) { $self->{parameters}->@* }

__PACKAGE__;

__END__
