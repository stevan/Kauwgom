#!perl

use v5.24;
use warnings;
use experimental 'signatures';
use FindBin;

use Kauwgom::Application;

Kauwgom::Application->new(
    "$FindBin::Bin/app.js",
    sub ($env) {
        return +{
            hello => [ grep $_, split /\// => $env->{PATH_INFO} ]
        }
    }
)->to_app;
