package Vislijn::Resolver;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Carp      ();
use Ref::Util ();

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _resolvers => sub { +{} }
);

sub BUILDARGS ($class, @args) {
    my $resolvers = $class->SUPER::BUILDARGS( @args );

    foreach my $c ( values $resolvers->%* ) {
        Carp::confess('Resolvers must be CODE references, not ['.ref($c).']')
            unless Ref::Util::is_coderef( $c );
    }

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
        push @results => $resolvers->{ $ref->source }->(
            $ctx,
            $ref->has_parameter ? $ref->get_parameter : ()
        );
    }

    return \@results;
}

__PACKAGE__

__END__

=pod

=head1 SYNOPSIS

  my $resolver = Vislijn::Resolver->new(
      hash => sub ($ctx, $key) { $ctx->{ $key } },
  );

  my ($foo, $bar) = $resolver->resolve(
      { foo => 10, bar => 20 },
      [
          Vislijn::Ref->new( 'hash:foo' ),
          Vislijn::Ref->new( 'hash:bar' ),
      ]
  )->@*;

=cut
