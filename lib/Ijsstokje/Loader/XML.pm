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

sub BUILD ($self, $) {
    $self->{_sax} = XML::SAX::Expat->new(
        Handler => Ijsstokje::Loader::XML::SAXHandler->new
    );
}

sub parse_file   ($self, $path) { $self->{_sax}->parse_file( $path ) }
sub parse_string ($self, $path) { $self->{_sax}->parse_string( $path ) }

__PACKAGE__;

__END__
