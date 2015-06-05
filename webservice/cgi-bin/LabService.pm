# Mijares Consultoria y Sistemas SL
# Copyrigth (C) - 2012
# Todos los derechos reservados
#

package LabService;

use base 'CGI::Application';
use warnings;
use strict;
use MySerial;
use Ipconfig;
use JSON;
use Data2Perl;


sub setup {
    my $self = shift;
    $self->mode_param('lab');
    $self->run_modes(
	'bt3000' => 'serial_a',
	'ipconfig' => 'netconfig');
}


sub cgiapp_prerun {
    my $self = shift;
    my $cgi = $self->query;

    if ($cgi->param('lab') eq 'bt3000') {
	my $q = MySerial->new(
	    string => $cgi->param('s'),
	    device => $cgi->param('d')
	    );
	my $conf = '/tmp/' . $q->device . '.conf';
	$q->write_config_file unless -f $conf && -r _;
    }
}


sub serial_a {
    my $self = shift;
    my $cgi = $self->query;
    my $q = MySerial->new(
	string => $cgi->param('s'),
	device => $cgi->param('d')
	);
    my $r = $q->talk_bt3000;
    my $output = '';

    if ($r =~ /^Y/) {      ## Aceptado	
	my @msg = split(/:/, $r);
	$self->header_add(-type => 'text/plain');
	$output .= $msg[1];
    }
    elsif ($r =~ /^N/) {   ## Error
	$self->header_add
	    (-status => '412 Precondition Failed',
	     -type => 'text/plain');
	my @msg =  split(/:/, $r);
	$output .= $msg[1];
    }
    elsif ($r =~ /^E/) {   ## Sin resultados
	$self->header_add
	    (-status => '204 No Content',
	     -type => 'text/plain');
	my @msg = split(/:/, $r);
	$output .= $msg[1];
    }
    elsif ($r =~ /^T/) {   ## Timeout
	$self->header_add
	    (-status => '504 Gateway Timeout',
	     -type => 'text/plain');
	my @msg = split(/:/, $r);
	$output .= $msg[1];
    }
    else {                 ## Resultados
	my $json = JSON->new;
	my $hash = Data2Perl->new(string => $r);
	$self->header_add(-type => 'application/json');
	$output .= $json->encode($hash->to_perl);
    }

    return $output;
}


sub netconfig {
    my $self = shift;
    my $cgi = $self->query;
    my $output = '';

    unless ($cgi->param('ip')) {
	system('/bin/rm /home/sysop/webservice/netconf/values.conf');
#	system ('/bin/rm /tmp/netconf');
	$self->header_add(
	    -type => 'text/plain'
	    );
	$output .= 'Configuracion de red por defecto';
	return $output;
	    }

    my $netconf = Ipconfig->new(
	ip => $cgi->param('ip'),
	mask => $cgi->param('mask'),
	router => $cgi->param('gw')
	);

    if ($netconf->makeconfig) {
	$self->header_add(
	    -type => 'text/plain'
	    );
	$output .= 'Nueva configuracion de red aceptada';
	return $output;
    }
    else {
	$self->header_add(
	    -status => '500 Internal Server Error'
	    -type => 'text/plain'
	    );
	$output .= 'No se pudo escribir la configuracion de red';
	return $output;
    }
}

1;
