package Kauwgom::XML::SAX::Handler;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Kauwgom::Page;
use Kauwgom::Page::Store;
use Kauwgom::Page::Store::Provider;
use Kauwgom::Page::Body;
use Kauwgom::Page::Component;

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

    my ($store, $server_comps, $client_comps, $body);
    foreach my $c ( $data->{children}->@* ) {
        if ( $c->{name} eq 'store' ) {

            my @providers;
            foreach my $provider ( $c->{children}->@* ) {

                my $name             = $provider->{attributes}->{'name'};
                my @available_on     = split /\,/ => $provider->{attributes}->{'available-on'};
                my ($type, $handler) = split /\// => $provider->{attributes}->{'provider'};


                my %parameters;
                foreach my $param ( $provider->{children}->@* ) {
                    $parameters{ $param->{attributes}->{'from'} } = $param->{attributes}->{'to'};
                }

                push @providers => Kauwgom::Page::Store::Provider->new(
                    type         => $type,
                    handler      => $handler,
                    name         => $name,
                    available_on => \@available_on,
                    parameters   => \%parameters,
                )
            }

            $store = Kauwgom::Page::Store->new( providers => \@providers );
        }
        elsif ( $c->{name} eq 'server-components' ) {
            $server_comps = [
                map
                Kauwgom::Page::Component->new( $_->{attributes}->%{qw[ type name ]} ),
                $c->{children}->@*
            ];
        }
        elsif ( $c->{name} eq 'client-components' ) {
            $client_comps = [
                map
                Kauwgom::Page::Component->new( $_->{attributes}->%{qw[ type name ]} ),
                $c->{children}->@*
            ];
        }
        elsif ( $c->{name} eq 'body' ) {
            $body = Kauwgom::Page::Body->new( $c->{attributes}->%{qw[ layout header footer ]} );
        }
        else {
            die "No idea what this is: " . Data::Dumper::Dumper( $c );
        }
    }

    return Kauwgom::Page->new(
        store             => $store,
        server_components => $server_comps,
        client_components => $client_comps,
        body              => $body,
    );
}

__PACKAGE__;

__END__

=pod

=cut
