#-----------------------------------------------------------
#
# OEMModule3::Serial
# 
# Serial Communication
#
#-----------------------------------------------------------

package OEMModule3::Serial;

use Moo;
use Device::SerialPort;

with('OEMModule3::Comm');

has serial_device => (
    is => 'ro',
    required => 1,
);

has baud_rate => (
    is => 'ro',
    #isa => sub {
    #    my $baud = shift;
    #    die unless any { $baud == $_ } @($self->baud_rates);
    #},
    default => sub { 9600 },
);

has baud_rates => (
    is => 'ro',
    default => sub {
        [1200, 2400, 4800, 9600, 19200]
    },
);

has serialport => (
    is => 'rw',
    lazy => 1,
    builder => '_build_port',
);
sub send {
    my $self = shift;
    my $cmd = shift;

    my $count_out = $self->serialport->write($cmd);
    sleep(1);

    my ($count_in, $string_in) = $self->serialport->read(16);
    return $string_in;
}

sub read_more {
    my $self = shift;

    my ($count_in, $string_in) = $self->serialport->read(16);
    return $string_in;
}

sub _build_port {
    my $self = shift;

    my $port = new Device::SerialPort($self->serial_device, 1)
        || die "Can't open " . $self->serial_device . ": $!\n";
    $port->baudrate($self->baud_rate);
    $port->parity("none");
    $port->databits(8);
    $port->stopbits(1);
    return $port;
}


1;
