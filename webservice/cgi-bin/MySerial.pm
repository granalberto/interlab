# Mijares Consultoria y Sistemas SL
# Copyrigth (C) - 2012
# Todos los derechos reservados
#

package MySerial;


use Mouse;
use Device::SerialPort;

has 'string' => (is => 'ro', isa => 'Str');
has 'device' => (is => 'ro', isa => 'Str');

sub bt3000sum {

    my $self = shift;
    my $sum = 0;
    foreach my $c (split //, $self->string) {
	$sum += ord($c);
    }   
    return sprintf(<%03s>, ($sum % 256));
}


sub write_config_file {

    my $self = shift;
    my $com = '/dev/' . $self->device;
    my $serial = new Device::SerialPort ($com);
    $serial->baudrate(9600);
    $serial->parity('none');
    $serial->databits(8);
    $serial->stopbits(1);
    $serial->write_settings;
    $serial->save('/tmp/' . $self->device . '.conf');
    $serial->close;
    warn "Creando archivo de configuracion para puerto serial\n";
}


sub bt3000msg {

    my $self = shift;
    my $fc = substr($self->string, 0, 1);
    if ($fc =~ /^[RLA]/) {
	return $self->string . chr(4);
    }
    elsif ($fc =~ /\d/) {
	return $self->string . $self->bt3000sum . chr(4);
    }
    else {
	die "Recibi un mensaje mal formado\n";
    }    
}


sub error {

    my $self = shift;
    my $char = shift;

    my %msg = (
	1 =>  'Error en la suma de verificacion',
	2 =>  'Instruccion desconocida',
	3 =>  'Error en campo de Rutina/STAT',
	4 =>  'Error en campo de Suero/Orina',
	5 =>  'Error en el campo Clon Si/No',
	6 =>  'Error en la posicion del contenedor',
	7 =>  'Error en el campo Numero de Analisis',
	8 =>  'Numero de test erroneo',
	9 =>  'Posicion ya en ejecucion',
	10 => 'Imposible clonar',
	11 => 'Codigo duplicado',
	12 => 'Uno o mas analisis no estan presentes en el analizador',
	13 => 'Uno o mas analisis no estan presentes en la bandeja actual',
	14 => 'Demasiados analisis para el paciente',
	17 => 'No hay pacientes para repetir',
	18 => 'Campo de suero en paciente a repetirse difiere al de la memoria',
	19 => 'Paciente a repetirse pero la lista esta llena',
	20 => 'Paciente a repetirse pero la lista es diferente',
	21 => 'La posicion asignada ya esta en uso',
	22 => 'Paciente ya existe o fue analizado, no es clon y pertenece a una lista suplementaria',
	23 => 'Paciente ya analizado, pero no hay repeticiones o clones activos'
	);
    
    return $msg{$char};

}



sub talk_bt3000 {

    my $self = shift;
    my $conf = '/tmp/' . $self->device . '.conf';
    my $serial = new Device::SerialPort ($conf) or die 
	"No pude abrir el puerto serial. $!\n";
    $serial->read_char_time(0);
    $serial->read_const_time(100);
    
    my $TIMES = 15;

    $serial->write(chr(2));                        ## Inicia el handshake    
    while ($TIMES > 0) {
	my ($count, $string) = $serial->read(255); ## Evaluo respuesta
	if ($count > 0) {
	    last if (ord($string) == 6);           ## Salgo del bucle
	}
	else {
	    $TIMES--;
	}
	
	if ($TIMES == 0) {
	    return 'T:No responde el handshake';
	}
    }	


    $serial->write($self->bt3000msg);
    
    my $buf;
    
    $TIMES = 15;
    while ($TIMES > 0) {
	my ($chars,$line) = $serial->read(255);
	if ($chars > 0) {
	    $buf .= $line;
	    last if ($chars < 255);
	}
	else {
	    $TIMES--;
	}
	
	if ($TIMES == 0) {
	    return 'T:Hay comunicacion pero analizador no responde consulta';
	}
	
    }
    
    
#       Evaluamos las posibles respuestas del analizador
    
    {
	require bytes;
	my $f = bytes::substr($buf, 0, 1);
	
	if (ord($f) == 89) {   ## La respuesta es Y
	    my $pos = bytes::substr($buf, 1, 1);
	    
	    return 'Y:Aceptado en posicion ' . ord($pos);
	    
	}
	
	if (ord($f) == 78) {   ## La respuesta es N
	    
	    return 'N:' . $self->error(ord(bytes::substr($buf, 1, 1)));
	    
	}
	
	if (ord($f) == 21) {   ## NAK No hay informes
	    
	    return 'E:No hay informes para enviar';
	    
	}
	
	else {                 ## Es un resultado
	    
	    return $buf;
	    
	}
	
    }
    
    $serial->close;
}

1;
