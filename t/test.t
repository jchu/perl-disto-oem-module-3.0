#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use OEMModule3;

my $module = OEMModule3->new({
        comm_class => 'OEMModule3::Serial',
        serial_device => '/dev/ttyS0',
        baud_rate => 9600,
    });

ok($module->on());
ok($module->measure_distance() =~ /\d+/);
ok($module->off());
