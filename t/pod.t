#!/usr/bin/env perl -w

use strict;
use Test::More;
plan skip_all => "These tests are for authors only!"
    unless $ENV{AUTHOR_TESTING} or $ENV{RELEASE_TESTING};
eval "use Test::Pod 1.41";
plan skip_all => "Test::Pod 1.41 required for testing POD" if $@;
all_pod_files_ok();
