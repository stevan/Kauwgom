package Vislijn::Ref;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _referent  => sub {},
    _parameter => sub {},
);

sub BUILDARGS ($class, @args) {
    Carp::confess('Expected a single argument to `new`, not ' . scalar @args)
        unless scalar @args == 1 && not ref $args[0];

    my ($referent, $param) = split /\:/ => $args[0];
    return { _referent => $referent, _parameter => $param };
}

sub referent ($self) { $self->{_referent} }

sub has_parameter ($self) { defined $self->{_parameter} }
sub get_parameter ($self) {         $self->{_parameter} }

sub to_string ($self) { join ':' => $self->{_referent}, $self->{_parameter} // () }

__PACKAGE__;

__END__

=pod

=head1 SYNOPSIS

  my $context  = ...;
  my $resolver = ...;

  my $name_ref    = Vislijn::Ref->new( 'request.query:name' );
  my $page_id_ref = Vislijn::Ref->new( 'request.query:page_id' );

  my ($page_id, $name) = $resolver->resolve( $context, $page_id_ref, $name_ref );

=cut
