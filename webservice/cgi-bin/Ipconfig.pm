# Mijares Consultoría y Sistemas SL
# Copyright (C) - 2012
# Todos los derechos Reservados
#

package Ipconfig;

use Mouse;

has 'ip' => (is => 'ro', isa => 'Str');
has 'mask' => (is => 'ro', isa => 'Str');
has 'router' => (is => 'ro', isa => 'Str');

sub makeconfig {
    my $self = shift;
    my $file = '/home/sysop/webservice/netconf/values.conf';
    open CONFIG, '>', $file;
    print CONFIG 'IP=' . $self->ip . "\n";
    print CONFIG 'MASK=' . $self->mask . "\n";
    print CONFIG 'GW=' . $self->router . "\n";
    close CONFIG;
}

1;
