package Kauwgom::XML::SAX::Handler;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object', 'XML::SAX::Base';
use slots (
    _stack  => sub { +[] },
);

sub REPR ($class, $proto) {
    return $class->XML::SAX::Base::new( %$proto );
}

sub start_document ($self, $) {
    my $d = { name => __PACKAGE__ };
    push $self->{_stack}->@* => $d;
}

sub start_element ($self, $element)  {
    my $e = { name => $element->{Name} };

    if ( $self->{_stack}->@* ) {
        $self->{_stack}->[-1]->{children} ||= [];
        push $self->{_stack}->[-1]->{children}->@* => $e;
    }

    push $self->{_stack}->@* => $e;
}

sub end_element ($self, $)  {
    pop $self->{_stack}->@*;
}

sub end_document ($self, $) {
    pop $self->{_stack}->@*;
}

__PACKAGE__;

__END__

=pod

=cut
