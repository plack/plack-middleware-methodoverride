package Plack::Middleware::MethodOverride;

use strict;
use 5.8.1;
use parent qw(Plack::Middleware);
use URI;
our $VERSION = '0.11';

my %ALLOWED = map { $_ => undef } qw(GET HEAD PUT DELETE OPTIONS TRACE CONNECT);

sub new {
    my $self = shift->SUPER::new(
        param  => 'x-tunneled-method',
        (@_ == 1 && ref $_[0] eq 'HASH' ? %{ +shift } : @_),
    );
    $self->header($self->header || 'X-HTTP-Method-Override');
    return $self;
}

sub call {
    my ($self, $env) = @_;
    my $meth = $env->{'plack.original_request_method'} = $env->{REQUEST_METHOD};

    if ($meth && uc $meth eq 'POST') {
        if (my $override = $env->{$self->header}) {
            # Google does this.
            $env->{REQUEST_METHOD} = uc $override if exists $ALLOWED{uc $override };
        } elsif (my $q = $env->{QUERY_STRING}) {
            # Parse the query string.
            my $uri = URI->new('/');
            $uri->query($q);
            my %form = $uri->query_form;
            if (my $override = $form{$self->param}) {
                $env->{REQUEST_METHOD} = uc $override if exists $ALLOWED{uc $override };
            }
        }
    }
    $self->app->($env);
}

sub header {
    my $self = shift;
    return $self->{header} unless @_;
    if ($_[0]) {
        my $key = shift;
        $key =~ tr/-/_/;
        return $self->{header} = 'HTTP_' . uc $key;
    } else {
        $self->{header} = shift;
    }
}

sub param {
    my $self = shift;
    return $self->{param} unless @_;
    return $self->{param} = shift;
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
probably going to need some hackish workarounds. This module provides one such
workaround for your Plack applications.

Specifically, you can also use a header named C<X-HTTP-Method-Override> (as
used by Google for its APIs) override the POST request method. Or you can add
a parameter named C<x-tunneled-method> to your form action's query. Either
way, the overriding works I<only> via POST requests, not GET.

If either of these attributes are available in a POST request, the
C<REQUEST_METHOD> key of the Plack environment hash will be replaced with its
value. This allows your apps to override any HTTP method over POST. If your
application needs to know that such overriding has taken place, the original
method is stored under the C<plack.original_request_method> key in the Plack
environment hash.

The list of methods you can specify are:

=over

=item GET

=item POST

=item HEAD

=item PUT

=item DELETE

=item OPTIONS

=item TRACE

=item CONNECT

=back

=head2 Configuration

If for some reason you need to use a different query parameter or header to
override methods, just configure it, like so:

   enable 'MethodOverride', header => 'X-HTTP-Method', param => 'my_method';

The configuration keys are:

=over

=item C<header>

Specifies the HTTP header name to specify the overriding HTTP method. Defaults
to C<X-HTTP-Method-Override>.

=item C<param>

Specifies the query parameter name to specify the overriding HTTP method.
Defaults to C<x-tunneled-method>.

=back

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
L<Catalyst::TraitFor::Request::REST::ForBrowsers> by Dave Rolsky and the
original version by Tatsuhiko Miyagawa (which in turn stole from
L<HTTP::Engine::Middleware::MethodOverride>). Thanks to L<Aristotle
Pagaltzis|http://plasmasturm.org/> for the shove in this direction, to L<Matt
S Trout|http://www.trout.me.uk/> for suggesting that it be implemented as
middleware, and to L<Hans Dieter Pearcey|http://www.weftsoar.net/> for
convincing me not to parse body parameters.

=head1 Author

David E. Wheeler <david@kineticode.com>

=head1 Copyright and License

Copyright (c) 2010 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
