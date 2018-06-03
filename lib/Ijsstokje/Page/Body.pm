package Ijsstokje::Page::Body;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Scalar::Util ();
use Path::Tiny   ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    layout      => sub { die 'You must specify a `layout`' },
    header      => sub {},
    footer      => sub {},
);

sub BUILD ($self, $) {

    # upgrade them to Path::Tiny objects
    foreach my $slot (qw[ layout header footer ]) {
        next unless defined $self->{ $slot };
        $self->{ $slot } = Path::Tiny::path( $self->{ $slot } )
            unless Scalar::Util::blessed( $self->{ $slot } )
                && $self->{ $slot }->isa('Path::Tiny');
    }
}

sub layout ($self) { $self->{layout} }
sub header ($self) { $self->{header} }
sub footer ($self) { $self->{footer} }

__PACKAGE__;

__END__
