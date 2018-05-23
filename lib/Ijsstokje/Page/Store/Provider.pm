package Ijsstokje::Page::Store::Provider;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use List::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    type         => sub {},
    name         => sub {},
    handler      => sub {},
    available_on => sub { +[ 'server' ] },
    parameters   => sub { +{} },
);

sub type    ($self) { $self->{type}    }
sub name    ($self) { $self->{name}    }
sub handler ($self) { $self->{handler} }

sub available_on ($self) { $self->{available_on}->@* }
sub is_available_on ($self, $env) {
    !! List::Util::any { $env eq $_ } $self->{available_on}->@*
}

sub parameters ($self) { $self->{parameters}->%* }

__PACKAGE__;

__END__
