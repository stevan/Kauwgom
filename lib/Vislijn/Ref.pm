package Vislijn::Ref;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    name => sub { die 'You must specify a `name`' },
    args => sub { die 'You must specify `args`' },
);

sub BUILDARGS ($class, @args) {
    if ( scalar @args == 1 && not ref $args[0] ) {
        my ($name, $arg) = split /\:/ => $args[0];
        return { name => $name, args => [ $arg ] };
    }
    return $class->SUPER::BUILDARGS( @args );
}

sub name ($self) { $self->{name} }
sub args ($self) { $self->{args} }

sub to_string ($self) { join ':' => $self->%{qw[ name args ]} }

__PACKAGE__;

__END__

=pod

=head1 SYNOPSIS

  my $context  = ...;
  my $resolver = ...;

  my $name_ref    = Vislijn::Ref->new( 'request.query:name' );
  my $page_id_ref = Vislijn::Ref->new( 'request.query:page_id' );

  my ($page_id, $name) = $resolver->resolve( $context, ( $page_id_ref, $name_ref ) );

=cut
