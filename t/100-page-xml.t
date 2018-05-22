#!perl

use v5.24;
use warnings;

use Test::More;

use XML::SAX::Expat;
use Kauwgom::XML::SAX::Handler;

my $x = XML::SAX::Expat->new( Handler => Kauwgom::XML::SAX::Handler->new );
my $p = $x->parse_file('root/app.xml');

isa_ok($p, 'Kauwgom::Page');
isa_ok($p->body, 'Kauwgom::Page::Body');
isa_ok($p->store, 'Kauwgom::Page::Store');

#use Data::Dumper;
#warn Dumper $p;

done_testing;
