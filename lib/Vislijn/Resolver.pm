package Vislijn::Resolver;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _resolvers => sub { +{} }
);

sub BUILDARGS ($class, @args) {
    my $resolvers = $class->SUPER::BUILDARGS( @args );
    return { _resolvers => $resolvers };
}

sub get_resolver ($self, $name)     {        $self->{_resolvers}->{$name}      }
sub add_resolver ($self, $name, $r) {        $self->{_resolvers}->{$name} = $r }
sub has_resolver ($self, $name)     { exists $self->{_resolvers}->{$name}      }

sub list_available_resolvers ($self) { sort keys $self->{_resolvers}->%* }

sub resolve ($self, $ctx, $refs) {

    my $resolvers = $self->{_resolvers};

    my @results;
    foreach my $ref ( $refs->@* ) {
        push @results => $resolvers->{ $ref->name }->(
            $ctx,
            $ref->args->@*
        );
    }

    return \@results;
}

__PACKAGE__

__END__

=pod

=head1 SYNOPSIS

  my $context  = ...;
  my $resolver = Vislijn::Resolver->new(
      'request
  );

  my $name_ref    = Vislijn::Ref->new( 'request.query:name' );
  my $page_id_ref = Vislijn::Ref->new( 'request.query:page_id' );

  my ($page_id, $name) = $resolver->resolve( $context, [ $page_id_ref, $name_ref ] )->@*;

=cut
