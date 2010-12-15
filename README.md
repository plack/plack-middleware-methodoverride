Plack/Middleware/MethodOverride version 0.11
============================================

This module provides middleware to support requesting HTTP methods via POST.
This is especially useful for browsers that don't offer DELETE or PUT methods.

Specifically, you can provide a query parameter named "x-tunneled-method" or a
header named "x-http-method-override" (as used by Google's APIs). Either way,
the overriding works only via POST requests, not GET.

Installation
============

To install this module, type the following:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Dependencies
------------

Plack::Middleware::MethodOverride requires Plack 0.9929 or higher.

Copyright and License
---------------------

Copyright (c) 2010 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
