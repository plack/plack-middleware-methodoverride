#!/usr/bin/env perl -w

use strict;
use Test::More;
plan skip_all => "These tests are for authors only!"
    unless $ENV{AUTHOR_TESTING} or $ENV{RELEASE_TESTING};
eval "use Test::Spelling";
plan skip_all => "Test::Spelling required for testing POD spelling" if $@;

add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__DATA__
APIs
Plack
RESTful
Acknowledgements
Pagaltzis
Pearcey
Rolsky
middleware
Tatsuhiko
Miyagawa
