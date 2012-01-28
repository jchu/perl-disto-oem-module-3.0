#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use OEMModule3;

plan skip_all => 'Set $ENV{OEM_SERIAL} to run this test' unless $ENV{OEM_SERIAL};


my $module = OEMModule3->new({
        comm_class => 'OEMModule3::Serial',
        serial_device => '/dev/ttyS0',
        baud_rate => 9600,
    });

ok($module->on());
ok($module->measure_distance() =~ /\d+/);
ok($module->off());

done_testing;
