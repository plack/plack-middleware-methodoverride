package Plack::Middleware::MethodOverride;

use strict;
use 5.8.1;
use parent qw(Plack::Middleware);
use URI;

our $VERSION = '0.10';

sub call {
    my ($self, $env) = @_;
    my $meth = $env->{'plack.original_request_method'} = $env->{REQUEST_METHOD};

    if ($meth && uc $meth eq 'POST') {
        if (my $override = $env->{HTTP_X_HTTP_METHOD_OVERRIDE}) {
            # Google does this.
            $env->{REQUEST_METHOD} = $override;
        } elsif (my $q = $env->{QUERY_STRING}) {
            # Parse the query string.
            my $uri = URI->new('/');
            $uri->query($q);
            my %form = $uri->query_form;
            if (my $override = $form{'x-tunneled-method'}) {
                $env->{REQUEST_METHOD} = $override;
            }
        }
    }
    $self->app->($env);
}

1;
__END__

=head1 Name

Plack::Middleware::MethodOverride - Override REST methods to Plack apps via POST

=head1 Synopsis

In your Plack App:

  use Plack::Builder;
  builder {
      enable MethodOverride;
      $app;
  };

PUT via a query parameter in your POST forms:

  <form method="POST" action="/foo?x-tunneled-method=PUT">
    <!-- ... -->
  </form>

Or override it via the C<x-http-method-override> header in a request:

  my $req = HTTP::Request->new(POST => '/foo', [
      'x-http-method-override' => 'PUT'
  ]);

=head1 Description

Writing
L<REST|http://en.wikipedia.org/wiki/Representational_State_Transfer>ful apps
is a good thing, but if you're also trying to support web browsers, you're
probably going to need some hackish workarounds. This module provides those
workarounds for your Plack application.

Specifically, you can add a parameter named C<x-tunneled-method> to your form
action's query, which can override the POST request method. This I<only> works
for a POST, not a GET.

You can also use a header named C<x-http-method-override> instead (Google uses
this header for its APIs). This is a bit more efficient, as it requires no
parsing of the query string parameters.

If either of these attributes are available in a POST request, the
C<REQUEST_METHOD> key of the Plack environment hash will be replaced with its
value. This allows your apps to override any HTTP method over POST. If your
application needs to know that such overriding has taken place, the original
method is stored under the C<plack.original_request_method> key in the Plack
environment hash.

=head1 Support

This module is stored in an open L<GitHub
repository|http://github.com/theory/plack-middleware-methodoverride/tree/>. Feel
free to fork and contribute!

Please file bug reports via L<GitHub
Issues|http://github.com/theory/plack-middleware-browserrest/issues/> or by
sending mail to
L<bug-Plack-Middleware-MethodOverride@rt.cpan.org|mailto:bug-Plack-Middleware-MethodOverride@rt.cpan.org>.

=head1 Acknowledgements

This module gleefully steals from
L<Catalyst::TraitFor::Request::REST::ForBrowsers> by Dave Rolsky. Thanks to
L<Aristotle Pagaltzis|http://plasmasturm.org/> for the shove in this
direction, to L<Matt S Trout|http://www.trout.me.uk/> for suggesting that it
be implemented as middleware, and to L<Hans Dieter
Pearcey|http://www.weftsoar.net/> for convincing me not to parse body
parameters.

=head1 Author

David E. Wheeler <david@kineticode.com>

=head1 Copyright and License

Copyright (c) 2010 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
