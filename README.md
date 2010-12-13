Plack/Middleware/TunnelMethod version 0.10
==========================================

This module provides middleware to support tunneling of REST methods via
POST. This is especially useful for browsers that don't offer DELETE or
PUT methods. 

Specifically, you can provide a form element named "x-tunneled-method" which
can override the request method for a POST. This only works for a POST, not a
GET.

You can also use a header named "x-http-method-override" instead (Google uses
this header for its APIs).

Installation
============

To install this module, type the following:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Dependencies
------------

SemVer requires version.

Copyright and License
---------------------

Copyright (c) 2010 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
