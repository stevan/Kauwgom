package Ijsstokje::Page::Component;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Scalar::Util     ();
use Path::Tiny       ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    type       => sub {},
    src        => sub {},
    env        => sub {},
    parameters => sub { +[] }
);

sub BUILD ($self, $) {

    # upgrade src to Path::Tiny objects
    $self->{src} = Path::Tiny::path( $self->{src} )
        unless Scalar::Util::blessed( $self->{src} )
            && $self->{src}->isa('Path::Tiny');
}

sub type ($self) { $self->{type} }
sub src  ($self) { $self->{src}  }
sub env  ($self) { $self->{env}  }

sub parameters ($self) { $self->{parameters}->@* }

__PACKAGE__;

__END__
