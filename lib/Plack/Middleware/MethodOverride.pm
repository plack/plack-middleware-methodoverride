use 5.008001;
use strict;
use Plack::Request ();

package Plack::Middleware::MethodOverride;

# ABSTRACT: Override REST methods to Plack apps via POST

use parent 'Plack::Middleware';
use Plack::Util::Accessor 'param';

my %allowed_method = map { $_ => undef } qw(GET HEAD PUT DELETE OPTIONS TRACE CONNECT);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{param}  = 'x-tunneled-method'      unless exists $self->{param};
    $self->{header} = 'X-HTTP-Method-Override' unless exists $self->{header};
    $self->header($self->{header}); # munge it
    return $self;
}

sub call {
    my ($self, $env) = @_;
    my $meth = $env->{'plack.original_request_method'} = $env->{REQUEST_METHOD};

    if ($meth and uc $meth eq 'POST') {
        my $override = uc (
            $env->{$self->header}
            or $env->{QUERY_STRING} && Plack::Request->new($env)->query_parameters->{$self->param}
        );
        $env->{REQUEST_METHOD} = $override if exists $allowed_method{$override};
    }

    $self->app->($env);
}

sub header {
    my $self = shift;

    return $self->{header}      if not @_;
    return $self->{header} = '' if not $_[0];

    (my $key = 'HTTP_'.$_[0]) =~ tr/-a-z/_A-Z/;
    return $self->{header} = $key;
}

1;

__END__

=head1 SYNOPSIS

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

Or override it via the C<X-HTTP-Method-Override> header in a request:

  my $req = HTTP::Request->new(POST => '/foo', [
      'X-HTTP-Method-Override' => 'PUT'
  ]);

=head1 DESCRIPTION

Writing
L<REST|http://en.wikipedia.org/wiki/Representational_State_Transfer>ful apps
is a good thing, but if you're also trying to support web browsers, it would
be nice not to be reduced to C<GET> and C<POST> for everything.

This middleware allows for C<POST> requests that pretend to be something else:
by adding either a header named C<X-HTTP-Method-Override> to the request, or
a query parameter named C<x-tunneled-method> to the URI, the client can say
what method it actually meant. That is, as long as it meant one of these:

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

If so, then the C<REQUEST_METHOD> in the PSGI environment will be replaced
with the client's desired value. The original request method is always stored
under the C<plack.original_request_method> key.

=head1 CONFIGURATION

These are the named arguments you can pass to C<new>. Or, more likely, on the
C<enable> line in your C<builder> block, as in

   enable 'MethodOverride', header => 'X-HTTP-Method', param => 'my_method';

=head2 C<header>

Specifies the HTTP header name which specifies the overriding HTTP method.

Defaults to C<X-HTTP-Method-Override>, as used by Google for its APIs.

=head2 C<param>

Specifies the query parameter name to specify the overriding HTTP method.

Defaults to C<x-tunneled-method>.

=head1 ACKNOWLEDGEMENTS

This module gleefully steals from
L<Catalyst::TraitFor::Request::REST::ForBrowsers> by Dave Rolsky and the
original version by Tatsuhiko Miyagawa (which in turn stole from
L<HTTP::Engine::Middleware::MethodOverride>). Thanks to L<Aristotle
Pagaltzis|http://plasmasturm.org/> for the shove in this direction, to L<Matt
S Trout|http://www.trout.me.uk/> for suggesting that it be implemented as
middleware, and to L<Hans Dieter Pearcey|http://www.weftsoar.net/> for
convincing me not to parse body parameters.

=cut
