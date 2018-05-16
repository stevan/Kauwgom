#!perl

use v5.24;
use warnings;

use Kauwgom;

Kauwgom->new( app => './app.js' )->to_app;
