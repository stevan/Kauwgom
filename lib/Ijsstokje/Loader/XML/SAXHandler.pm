package Ijsstokje::Loader::XML::SAXHandler;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Vislijn::Ref;

use Ijsstokje::Parameter;
use Ijsstokje::Page;
use Ijsstokje::Page::Store;
use Ijsstokje::Page::Store::Provider;
use Ijsstokje::Page::Body;
use Ijsstokje::Page::Component;

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object', 'XML::SAX::Base';
use slots ( _stack  => sub { +[] } );

## extend a non UNIVESAL::Object class ...
sub REPR ($class, $proto) {
    return $class->XML::SAX::Base::new( %$proto );
}

## ...

sub start_document ($self, $) {
    my $d = { name => __PACKAGE__ };
    push $self->{_stack}->@* => $d;
}

sub start_element ($self, $element)  {
    my $e = { name => $element->{Name} };

    if ( exists $element->{Attributes} && scalar keys $element->{Attributes}->%* ) {
        $e->{attributes} = {
            map {
                $_->{Name} => $_->{Value}
            } values $element->{Attributes}->%*
        };
    }

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
    my $data = pop $self->{_stack}->@*;
    my $page = $self->_inflate_page( $data->{children}->[0] );
    #use Data::Dumper;
    #warn Dumper $page;
    return $page;
}

## ...

sub _inflate_page ($self, $data) {

    my ($store, @components, $body);
    foreach my $c ( $data->{children}->@* ) {
        if ( $c->{name} eq 'store' ) {

            my %providers;
            foreach my $provider ( $c->{children}->@* ) {

                my $name             = $provider->{attributes}->{'name'};
                my ($type, $handler) = split /\// => $provider->{attributes}->{'provider'};

                my @parameters;
                foreach my $param ( $provider->{children}->@* ) {
                    push @parameters => Ijsstokje::Parameter->new(
                        $param->{attributes}->{'name'},
                        Vislijn::Ref->new( $param->{attributes}->{'from'} )
                    );
                }

                $providers{ $name } = Ijsstokje::Page::Store::Provider->new(
                    type       => $type,
                    handler    => $handler,
                    name       => $name,
                    parameters => \@parameters,
                )
            }

            $store = Ijsstokje::Page::Store->new( \%providers );
        }
        elsif ( $c->{name} eq 'component' ) {
            push @components => Ijsstokje::Page::Component->new(
                $c->{attributes}->%{qw[ type src env ]},
                parameters => [
                    map {
                        Ijsstokje::Parameter->new(
                            $_->{attributes}->{'name'},
                            Vislijn::Ref->new( $_->{attributes}->{'from'} )
                        )
                    } $c->{children}->@*
                ]
            );
        }
        elsif ( $c->{name} eq 'body' ) {
            $body = Ijsstokje::Page::Body->new( $c->{attributes}->%{qw[ layout header footer ]} );
        }
        else {
            die "No idea what this is: " . Data::Dumper::Dumper( $c );
        }
    }

    return Ijsstokje::Page->new(
        store      => $store,
        components => \@components,
        body       => $body,
    );
}

__PACKAGE__;

__END__

=pod

=cut
