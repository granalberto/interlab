#!/usr/bin/env perl

use warnings;
use strict;

use Device::SerialPort;

my $serial = new Device::SerialPort('/dev/ttyUSB0');

$serial->baudrate(9600);
$serial->parity('none');
$serial->databits(8);
$serial->stopbits(1);

$serial->write_settings;

$serial->read_char_time(0);
$serial->read_const_time(100);

OUT: while (1) {

    my ($c, $s) = $serial->read(255);
    if ($c > 0) {
	warn $s, "\n";
	if (ord($s) == 2) {
	    $serial->write(chr(6));
	  IN: while (1) {
	      my ($b, $w) = $serial->read(255);
	      if ($b > 0) {
		  warn $w, "\n";
		  if ($w =~ /^ *\d/) {
		      $serial->write('Y'.chr(4));
		      last IN;
		  }
		  if ($w =~ /^[ARL]/) {
		      $serial->write('000000000000001RS001GLU 000.000888');
		      last IN;
		  }
	      }
	  }
	}
    }
}

