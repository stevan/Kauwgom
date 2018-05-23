#!perl

use v5.24;
use warnings;

use Test::More;

use XML::SAX::Expat;
use Ijsstokje::XML::SAX::Handler;

my $x = XML::SAX::Expat->new( Handler => Ijsstokje::XML::SAX::Handler->new );
my $p = $x->parse_file('root/app.xml');

isa_ok($p, 'Ijsstokje::Page');
isa_ok($p->body, 'Ijsstokje::Page::Body');
isa_ok($p->store, 'Ijsstokje::Page::Store');

#use Data::Dumper;
#warn Dumper $p;

done_testing;
