#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use OEMModule3;

plan skip_all => 'Set $ENV{OEM_TELNET} to run this test' unless $ENV{OEM_TELNET};

my $module = OEMModule3->new({
        comm_class => 'OEMModule3::Telnet',
        server_name => $ENV{OEM_TELNET},
        server_port => 2000,
    });

diag 'Turn module on';
ok($module->on());
sleep(2);
diag 'Measure distance';
ok($module->measure_distance() =~ /\d+/);
diag 'Turn module off';
ok($module->off());
sleep(2);

done_testing;
