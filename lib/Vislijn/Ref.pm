package Vislijn::Ref;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _source => sub {},
    _param  => sub {},
);

sub BUILDARGS ($class, @args) {
    Carp::confess('Expected a single argument to `new`, not ' . scalar @args)
        unless scalar @args == 1 && not ref $args[0];

    my ($source, $param) = split /\:/ => $args[0];
    return { _source => $source, _param => $param };
}

sub source ($self) { $self->{_source} }

sub has_parameter ($self) { defined $self->{_param} }
sub get_parameter ($self) {         $self->{_param} }

sub to_string ($self) { join ':' => $self->{_source}, $self->{_param} // () }

__PACKAGE__;

__END__

=pod

=head1 SYNOPSIS

  my $context  = ...;
  my $resolver = ...;

  my $name_ref    = Vislijn::Ref->new( 'request.query:name' );
  my $page_id_ref = Vislijn::Ref->new( 'request.query:page_id' );

  my ($page_id, $name) = $resolver->resolve( $context, [ $page_id_ref, $name_ref ] )->@*;

=cut
