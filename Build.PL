use strict;
use warnings;
use Module::Build;

Module::Build->new(
    module_name        => 'Plack::Middleware::MethodOverride',
    license            => 'perl',
    configure_requires => {
        'Module::Build' => '0.30',
    },
    build_requires     => {
        'Module::Build' => '0.30',
        'Test::More'    => '0.70',
    },
    requires => {
        'Test::Builder' => '0.70',
        'Plack'         => '0.9929',
        'perl'          => 5.008001,
        'URI'           => 0,
    },
    meta_merge => {
        resources => {
            homepage   => 'http://search.cpan.org/dist/Plack-Middleware-MethodOverride/',
            bugtracker => 'http://github.com/theory/plack-middleware-methodoverride/issues/',
            repository => 'http://github.com/theory/plack-middleware-methodoverride',
        }
        prereqs => {
            develop => {
                recommends => {
                    'Test::Pod'         => '1.41',
                    'Test::Spelling'    => '0',
                },
            },
        },
    },
)->create_build_script;
