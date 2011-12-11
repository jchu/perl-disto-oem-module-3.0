#-----------------------------------------------------------
#
# OEMModule3::Comm
# 
# Communication Base
#
#-----------------------------------------------------------

package OEMModule3::Comm;

use strict;
use warnings;

use Moo::Role;

requires qw/send/;

1;
