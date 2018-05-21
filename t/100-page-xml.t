#!perl

use v5.24;
use warnings;

use Test::More;

use XML::SAX::Expat;
use Kauwgom::XML::SAX::Handler;

my $h = Kauwgom::XML::SAX::Handler->new;
my $p = XML::SAX::Expat->new( Handler => $h );
my $r = $p->parse_file('root/app.xml');

use Data::Dumper;
warn Dumper $r;

done_testing;
