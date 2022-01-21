#####
#
# PERL Menu Test
#
# usage:
#   perl menu-test.pl <file>
#
#####

use strict;
use warnings;
use Data::Dumper;

my $parameters = \@ARGV;
my $testfile = ${$parameters}[0];

open (my $fileh, "<", $testfile) ||
    die "Unable to open $testfile !\n!!$!";

exit;