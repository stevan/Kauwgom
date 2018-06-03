package Ijsstokje::Page::Component;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    type       => sub {},
    src        => sub {},
    env        => sub {},
    parameters => sub { +[] }
);

## add Type checking here

sub type       ($self) { $self->{type}       }
sub src        ($self) { $self->{src}        }
sub env        ($self) { $self->{env}        }

sub parameters ($self) { $self->{parameters}->@* }

__PACKAGE__;

__END__
