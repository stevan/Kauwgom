package Kauwgom::Page::Component;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    type => sub {},
    name => sub {},
);

sub type ($self) { $self->{type} }
sub name ($self) { $self->{name} }

__PACKAGE__;

__END__
