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
no warnings 'recursion';

my $parameters = \@ARGV;
my $testfile = ${$parameters}[0];
our (@output,@index);

# Main 
my @menu_data = &read_file($testfile);  # read $testfile and store data in @menu_data
my @final_output = &parse_data(@menu_data);

exit;

#####
#
# Subroutines
#
#####

sub parse_data() {
    my $data_array = $_[0];
    my $length = $#{$data_array};
    my $goal_total = ${$data_array}[0];
    $goal_total =~ s/^\$//; # remove '$'
    $goal_total = sprintf "%0.2f",$goal_total; # force numeric (strip newline)
    
    my (@value_array,@item_array,@suboutput);

    foreach my $count (1 .. $length) {
        my ($menu_item,$item_value) = split(/,/,${$data_array}[$count]); # split data line on comma
        $item_value =~ s/^\$//; # remove '$'
        $item_value = sprintf "%0.2f",$item_value; # force numeric (strip newline)
        $item_array[$count-1] = $menu_item; # store data pair (item and value) in hash
        $value_array[$count-1] = $item_value; # initialize count hash
    }
    
    my (@final_output,@final_subindex) = &reparse(\@value_array,$#value_array,$goal_total,0,[],[]);
    
    print "Solutions:\n";
    my $count = 0;
    foreach my $solution (@main::index) {
        print "$count: ";
        foreach my $index ($solution) {
            foreach my $item (@$index) {
                print "$item_array[$item], ";
            }      
        }
        print "\n";
        $count++;
    }
    
    return;
}

sub reparse() {    
    my $test_values = $_[0];
    my $max_depth = $_[1];
    my $cost_limit = $_[2];
    my $subdepth = $_[3];
    my $suboutput = $_[4];
    my $subindex = $_[5];
    
    my $subtotal = &sum_array(\@$suboutput);
    
    if ($subtotal == $cost_limit) { # if the subtotal of suboutput equals the cost limit then success found, return solution
        push(@main::index,\@$subindex); # push array of indexes to global storage
        return @$suboutput,@$subindex;
    } elsif (($subtotal > $cost_limit)||($subdepth > $max_depth)) { # if subtotal is greater than the cost limit or subdepth is greather than the max depth then went beyond limits, return nothing
        return;
    }

    &reparse(\@$test_values,$max_depth,$cost_limit,$subdepth+1,\@$suboutput,\@$subindex); #check next depth down using current solution
    &reparse(\@$test_values,$max_depth,$cost_limit,$subdepth,[@$suboutput,$$test_values[$subdepth]],[@$subindex,$subdepth]); #check current depth adding next value to solution

}

sub sum_array() {
    my $array = $_[0];
    my $sum = 0;
    foreach my $item (@$array) {
        $sum += $item;
    }
    return $sum;
}

sub read_file() {
    my $filename = $_[0];
    my @data = [];
    my $count = 0;
    
    open (my $fileh, "<", $filename) ||
        die "Unable to open '$filename'!\n ! $! !\n";
    
    while (! eof $fileh) {
        $data[$count] = readline($fileh);
        if ((!$data[$count])||($data[$count] !~ m/.+\,\$\d+\.\d\d/g)&&($data[$count] !~ m/^\$\d+\.\d\d/g)) {
            die "Data is malformed at line $count!\nUnable to proceed.\n";
        }
        $count++;
    }
    close $fileh;
    if ($count == 0) { die "No data in datafile '$filename'!\nUnable to proceed.\n"; }
    print "datafile lines read: ".$count."\n";
    return \@data;
}

