#!/usr/bin/env perl -w

use strict;
use Test::More tests => 12;
#use Test::More 'no_plan';
use Plack::Test;
use URI;

BEGIN { use_ok 'Plack::Middleware::TunnelMethod' or die; }

my $base_app = sub {
    my $env = shift;
    return [
        200,
        ['Content-Type' => 'text/plain'],
        [ "$env->{REQUEST_METHOD} ($env->{'plack.original_request_method'})" ]
    ];
};
ok my $app = Plack::Middleware::TunnelMethod->wrap($base_app),
    'Create TunnelMethod app with no args';

my $uri = URI->new('/');

test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(GET => $uri));
    is $res->content, 'GET (GET)', 'GET should be GET';
};

test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(PUT => $uri));
    is $res->content, 'PUT (PUT)', 'PUT should be PUT';
};

test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(POST => $uri));
    is $res->content, 'POST (POST)', 'POST should be POST';
};

# Tunnel over POST.
$uri->query_form('x-tunneled-method' => 'PUT');
test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(POST => $uri));
    is $res->content, 'PUT (POST)', 'Should tunnel PUT over POST';
};

test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(GET => $uri));
    is $res->content, 'GET (GET)', 'Should not tunnel PUT over GET';
};

# Try to confuse the parser.
$uri->query_form('foo' => 'x-tunneled-method', name => 'Scott');
test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(POST => $uri));
    is $res->content, 'POST (POST)', 'POST should be POST with no tunnel';
};

# Tunnel DELETE
$uri->query_form('x-tunneled-method' => 'DELETE', PUT => 'x-tunneled-method');
test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(POST => $uri));
    is $res->content, 'DELETE (POST)', 'Should tunnel DELETE over POST';
};

##############################################################################
# Now try with a header.
my $head =  ['x-http-method-override' => 'PUT'];
test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(POST => '/', $head));
    is $res->content, 'PUT (POST)', 'Should tunnel PUT over POST via header';
};

test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(GET => '/', $head));
    is $res->content, 'GET (GET)', 'Should not tunnel PUT over GET via header';
};

# Try a different method.
$head->[1] = 'OPTIONS';
test_psgi $app, sub {
    my $res = shift->(HTTP::Request->new(POST => '/', $head));
    is $res->content, 'OPTIONS (POST)', 'Should tunnel OPTIONS over POST via header';
};

