#!/usr/bin/perl

use strict;
use warnings;


use Module::Build;

Module::Build->new(

    module_name     => 'OEMModule3',
    dist_abstract   => 'API for DISTO OEM Module 3.0',
    dist_author     => 'Jonathan Chu <jrchu@cs.ucla.edu>',
    license         => 'perl',
    requires        => {
        'Moo'               => 0,
        'List::MoreUtils'    => 0,
    },
    create_packlist => 0,
    installdirs     => 'vendor',
)->create_build_script;
