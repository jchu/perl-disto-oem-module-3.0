#-----------------------------------------------------------
#
# OEMModule3
# 
# API for DISTO OEM Module 3.0
#
#-----------------------------------------------------------

package OEMModule3;

use strict;
use warnings;

use List::MoreUtils;
use Moo;

use OEMModule3::Serial;
use OEMModule3::Telnet;

our $VERSION = '0.1';

=pod Words

16 characters long
WW....+12345678_
WW....+1234+678_

12
Serial number of module

13
Software version

14
Hardware Version

15
Date of manufacture

31
Slope distance

40
Temperature

51
0

53
Measurement signal

58
Distance offset

=cut

=pod Errors

@E203
Prohibited parameter in command netry, or prohibited command, or non-valid result

@217
Parameter set-up incorrect

@221
Parity error

@E222
Interface buffer overflow

@E223
Interface framing error

@E224
GSI buffer overflow

@E252
Temperature too high

@E254
Temperature too low

@E255
Received signal too weak

@E256
Received signal too strong

@E257
Too much background light

@E272-229
Hardware failure

=cut


use Moo;

#-----------------------------------------------------------
#
# Class Variables
#
#-----------------------------------------------------------

has error => (
    is => 'ro',
);

has comm => (
    is => 'ro',
    lazy => 1,
    builder => '_build_comm',
);

has comm_class => (
    is => 'ro',
    isa => sub {
        die "Only OEMModule3::Serial and OEMModule3::Telnet supported" unless $_[0] =~ /OEMModule3::Serial|OEMModule3::Telnet/
    },
    required => 1,
);

# OEMModule3::Serial
has serial_device => (
    is => 'ro',
);

has baud_rate => (
    is => 'ro',
    #isa => sub {
    #    my $baud = $_[0];
    #    die unless any { $baud == $_ } @($self->baud_rates);
    #},
);

#has baud_rates => (
#    is => 'ro',
#    default => sub {
#        [1200, 2400, 4800, 9600, 19200]
#    },
#);

# OEMModule3::Telnet

has server_name => (
    is => 'ro',
);

has server_port => (
    is => 'ro',
);

my $RESET       = "a\r\n";
my $OFF         = "b\r\n";
my $CLEAR       = "c\r\n";
my $DMEASURE    = "g\r\n";
my $TRACK       = "h\r\n";
my $SMEASURE    = "k\r\n";
my $TMEASURE    = "t\r\n";
my $LASERON     = "o\r\n";
my $LASEROFF    = "p\r\n";
my $SWV         = "00\r\n";
my $HWV         = "01\r\n";
my $SN          = "02\r\n";
my $DOM         = "03\r\n";
my $DOFFSET     = "44\r\n";
my $BAUD        = "70\r\n";

my $PRE     = "D";
my $POST    = "\t";

#-----------------------------------------------------------
#
# Commands
#
#-----------------------------------------------------------

sub on {
    my $self = shift;
    return $self->reset();
}

sub reset {
    my $self = shift;
    return $self->send_command($RESET, 1);
}

sub off {
    my $self = shift;
    return $self->send_command($OFF, 1);
}

sub stop {
    my $self = shift;
    return $self->clear();
}

sub clear {
    my $self = shift;
    return $self->send_command($CLEAR, 1);
}

# millimeters
sub measure_distance {
    my $self = shift;

    my $resp = $self->send_command($DMEASURE, 1);

    if( $resp =~ /31..00(?<sign>[-+])(?<distance>\d{8})/ ) {
        return ($+{distance} + 0) * ($+{sign} eq '+' ? 1 : -1);
    } else {
        return undef;
    }
}

# TODO: Continuous tracking should keep track of all values
sub track {
    my $self = shift;

    #W131
    #W151

    return $self->send_command($TRACK, 2);
}

sub measure_signal {
    my $self = shift;

    my $resp = $self->send_command($SMEASURE, 2);

    if( $resp ) {
        # parse
        #W153

    } else {
        return 0;
    }
}

sub measure_temperature {
    my $self = shift;

    my $resp = $self->send_command($TMEASURE, 2);

    if( $resp ) {
        # parse
        #W140
    } else {
        return 0;
    }
}

sub laser_on {
    my $self = shift;
    return $self->send_command($LASERON, 1);
}

sub laser_off {
    my $self = shift;
    return $self->send_command($LASEROFF, 1);
}

sub sw_version {
    my $self = shift;

    my $resp = $self->send_command($SWV, 1);

    if( $resp ) {
        # parse
        #W113

    } else {
        return 0;
    }
}

sub hw_version {
    my $self = shift;

    my $resp = $self->send_command($HWV, 1);

    if( $resp ) {
        # parse
        #W114

    } else {
        return 0;
    }
}

sub serial_number {
    my $self = shift;

    my $resp = $self->send_command($SN, 1);

    if( $resp ) {
        # parse
        #W112
    } else {
        return 0;
    }
}

sub date_of_manufacture {
    my $self = shift;

    my $resp = $self->send_command($DOM, 1);

    if( $resp ) {
        # parse
        #W115
    } else {
        return 0;
    }
}

sub set_distance_offest {
    my( $self, $offset ) = @_;

    # validate offset
    #N44N%N

    my $resp = $self->send_command($DOFFSET, $offset, 1);

    if( $resp ) {
        # parse
        #W158
    } else {
        return 0;
    }
}

sub set_baud_rate {
    my( $self, $baud_rate ) = @_;

    # validate baud

    return $self->send_command($BAUD, $baud_rate, 1 );
}

#-----------------------------------------------------------
#
# Utiliies
#
#-----------------------------------------------------------

# TODO: fix args for parameters
sub send_command {
    my($self, $command, $expected) = @_;

    # validate command
    #unless( any { $command == $_ } @commands;
    #    $self->error('Unsupported command');
    #    return false;
    #}
    
    # send over serial
    my $resp = $self->comm->send("${PRE}${command}${POST}");

    if( $expected > 1 ) {
        $self->comm->read_more();
    }
    
    if( $resp =~ /\@E(?<error>\d{3})/ ) {
      $self->error($+{error});
      return undef;
    } elsif( $resp =~ /\?/ ) {
      return 1;
    } else {
      return $resp;
    }
}

sub _build_comm {
    my $self = shift;

    if( $self->comm_class eq 'OEMModule3::Serial' ) {
        return $self->comm_class->new({
                serial_device => $self->serial_device,
                baud_rate => $self->baud_rate
            });
    } elsif( $self->comm_class eq 'OEMModule3::Telnet' ) {
        my $telnet = $self->comm_class->new({
                server_name => $self->server_name,
                server_port => $self->server_port
            });
        return $telnet;
    }
}

#sub _valid_baudrate {
#    my ($self, $baud) = @_;
#
#    return any { $baud == $_ } @($self->baud_rates());
#}

1;
