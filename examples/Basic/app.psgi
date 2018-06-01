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
            env => $env
        }
    }
)->to_app;
