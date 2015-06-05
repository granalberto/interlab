#!/usr/bin/perl

use Data2Perl;
use Data::Dumper;
use JSON;
use XML::Simple;

my $obj = Data2Perl->new(string => '000000000000001RS003GLU 000.000BUN 0010.10CHO 00100.0245');

#my $obj = BTPerl->new(string => '000000000000001RS001GLU 000.000245');

print ref ($obj->to_perl), "\n";

print Dumper ($obj->to_perl);

my $xs = JSON->new;
my $xm = XML::Simple->new;

print $xs->encode($obj->to_perl),"\n";

print $xm->XMLout($obj->to_perl);
