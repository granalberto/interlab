#!/usr/bin/env perl

use warnings;
use strict;
use BT3000;

my $obj = BT3000->new(
#    string => '000000000000297RSN0101CREL',
    string => 'L',
    device => 'ttyUSB0'
    );


my $res = $obj->talk_bt3000;

print $res,"\n";
