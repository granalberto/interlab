# Mijares Consultoria y Sistemas SL
# Copyrigth (C) - 2012
# Todos los derechos reservados
#

package Data2Perl;

use Mouse;

has 'string' => (is => 'ro', isa => 'Str');

sub to_perl {
    my $self = shift;
    
    my $cod = substr($self->string, 0, 15);
    my $lista = substr($self->string, 15, 1);
    my $muestra = substr($self->string, 16, 1);
    my $num = substr($self->string, 17, 3) + 0;

    my $init = 20;
    my %values;
    
    foreach (1 .. $num) {
	$values{substr($self->string, $init, 4)} = 
	    substr($self->string, $init + 4, 7);
	$init += 11;
    }

    my $data = { cod => $cod,
		 tl => $lista,
		 tm => $muestra,
		 ni => $num,
		 res => \%values };

    return $data;
}
1;
