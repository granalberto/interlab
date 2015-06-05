#!/usr/bin/env perl

use warnings;
use strict;
use Ipconfig;

my $conf = Ipconfig->new(
    ip => '192.168.1.230',
    mask => '255.255.255.0',
    router => '192.168.1.1');

print "OK\n" if $conf->makeconfig;
