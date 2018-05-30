package Ijsstokje::Loader::XML;

use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use XML::SAX::Expat ();

use Ijsstokje::Loader::XML::SAXHandler;

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _sax => sub {}
);

sub BUILD ($self, $params) {
    $self->{_sax} = XML::SAX::Expat->new(
        Handler => Ijsstokje::Loader::XML::SAXHandler->new,
        %$params
    );
}

sub parse_file   ($self, $path)   { $self->{_sax}->parse_file( $path )     }
sub parse_string ($self, $string) { $self->{_sax}->parse_string( $string ) }

__PACKAGE__;

__END__

=pod

=head1 METHODS

=head2 C<new( %params )>

The C<new> method will accept C<%params> and will pass them onto
the L<XML::SAX::Expat> constructor. This can be used for passing
additional parameters to L<XML::SAX::Expat> as well as to override
the default C<Handler> (L<Ijsstokje::Loader::XML::SAXHandler>) that
we provide.

=cut
