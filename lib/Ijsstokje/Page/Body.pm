package Ijsstokje::Page::Body;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    layout => sub {},
    header => sub {},
    footer => sub {},
);

## add Type checking here

sub layout ($self) { $self->{layout} }
sub header ($self) { $self->{header} }
sub footer ($self) { $self->{footer} }

__PACKAGE__;

__END__
