#!perl

use v5.24;
use warnings;
use experimental 'signatures';
use FindBin;

use Kauwgom;

Kauwgom->new(
    application_path   => "$FindBin::Bin/app.js",
    tmpl_data_provider => sub ($env) {
        return +{
            hello => $env->{PATH_INFO}
        }
    }
)->to_app;
