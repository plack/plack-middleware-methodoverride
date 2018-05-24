# NAME

Plack::Middleware::MethodOverride - Override REST methods to Plack apps via POST

# SYNOPSIS

In your Plack app:

    use Plack::Builder;
    builder {
        enable MethodOverride;
        $app;
    };

PUT via a query parameter in your POST forms:

    <form method="POST" action="/foo?x-tunneled-method=PUT">
      <!-- ... -->
    </form>

Or override it via the `X-HTTP-Method-Override` header in a request:

    my $req = HTTP::Request->new(POST => '/foo', [
        'X-HTTP-Method-Override' => 'PUT'
    ]);

# DESCRIPTION

Writing
[REST](http://en.wikipedia.org/wiki/Representational_State_Transfer)ful apps
is a good thing, but if you're also trying to support web browsers, it would
be nice not to be reduced to `GET` and `POST` for everything.

This middleware allows for `POST` requests that pretend to be something else:
by adding either a header named `X-HTTP-Method-Override` to the request, or
a query parameter named `x-tunneled-method` to the URI, the client can say
what method it actually meant. That is, as long as it meant one of these:

- GET
- POST
- HEAD
- PUT
- DELETE
- OPTIONS
- TRACE
- CONNECT
- PATCH

If so, then the `REQUEST_METHOD` in the PSGI environment will be replaced
with the client's desired value. The original request method is always stored
under the `plack.original_request_method` key.

# Configuration

These are the named arguments you can pass to `new`. Or, more likely, on the
`enable` line in your `builder` block, as in

    enable 'MethodOverride', header => 'X-HTTP-Method', param => 'my_method';

## `header`

Specifies the HTTP header name which specifies the overriding HTTP method.

Defaults to `X-HTTP-Method-Override`, as used by Google for its APIs.

## `param`

Specifies the query parameter name to specify the overriding HTTP method.

Defaults to `x-tunneled-method`.

# AUTHOR

Tatsuhiko Miyagawa

David E. Wheeler

Aristotle Pagaltzis

# COPYRIGHT

2015- Tatsuhiko Miyagawa, David E. Wheeler, Aristotle Pagaltzis

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# Acknowledgements

This module gleefully steals from
[Catalyst::TraitFor::Request::REST::ForBrowsers](https://metacpan.org/pod/Catalyst::TraitFor::Request::REST::ForBrowsers) by Dave Rolsky and the
original version by Tatsuhiko Miyagawa (which in turn stole from
[HTTP::Engine::Middleware::MethodOverride](https://metacpan.org/pod/HTTP::Engine::Middleware::MethodOverride)). Thanks to [Aristotle
Pagaltzis](http://plasmasturm.org/) for the shove in this direction, to [Matt
S Trout](http://www.trout.me.uk/) for suggesting that it be implemented as
middleware, and to [Hans Dieter Pearcey](http://www.weftsoar.net/) for
convincing me not to parse body parameters.
