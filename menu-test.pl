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

# Main 
my @menu_data = &read_file($testfile);  # read $testfile and store data in @menu_data
my @final_output = &parse_data(@menu_data);
# &display_output(@final_output);
exit;

#####
#
# Subroutines
#
#####

sub parse_data() {
    my $data = $_[0];
    my $length = $#{$data};
    my $depth = 0;
    my (@output,$success_count,$success_flag);
    my $goal_total = ${$data}[0];
    $goal_total =~ s/^\$//; # remove '$' and newline for value
    $goal_total = sprintf "%0.2f",$goal_total;
    
    my %item_hash;
    my $small_value=1;
    my $large_value=1;
    
    foreach my $count (1 .. $length) {
        my ($menu_item,$item_value) = split(/,/,${$data}[$count]); # split data line on comma
        $item_value =~ s/^\$//; # remove '$' and newline for value
        $item_value = sprintf "%0.2f",$item_value; # force numeric (strip newline)
        $item_hash{$menu_item} = $item_value; # store data pair (item and value) in hash

        if (($item_value - $small_value) < 0) { $small_value = $item_value; } # determine and store smallest value
        if (($item_value - $large_value) > 0) { $large_value = $item_value; } # determine and store largest value
    }
    
    print "First:\n".Dumper(\%item_hash,$goal_total,$small_value,$large_value,$depth);
    (@output,$success_count,undef) = &reparse(\%item_hash,$goal_total,$small_value,$large_value,1,\@output,0,0);
    
    print "Final:\n".Dumper($success_count,\@output);
    return @output;
}

sub reparse() {    
    my $menu_items = $_[0];
    my $cost_limit = $_[1];
    my $low_limit = $_[2];
    my $hi_limit = $_[3];
    my $subdepth = $_[4];
    my $suboutput = $_[5];
    my $success_count = $_[6];
    my $success_flag = $_[7];

    print "Entering reparse#$subdepth...\n";    
    print Dumper(\%{$menu_items},$cost_limit,$low_limit,$hi_limit,$subdepth,\@{$suboutput},$success_count,$success_flag);
    
    foreach my $item (sort keys %{$menu_items}) {
        print "$subdepth:\n$cost_limit\n$item\t$$menu_items{$item}\n";
        if (($cost_limit < 0)||($success_flag)) {  print "success detected\n"; $success_flag = 1; last;   }
        if ($$menu_items{$item} > $cost_limit) {  print "skipping '$item'\n"; next;   }

        $cost_limit = $cost_limit - $$menu_items{$item};
        $$suboutput[$success_count] .= (!defined $$suboutput[$success_count])?$item:",".$item ;

        if (!$success_flag) {
            (@{$suboutput},$success_count,$success_flag) = &reparse(\%{$menu_items},$cost_limit,$low_limit,$hi_limit,++$subdepth,\@{$suboutput},$success_count,$success_flag);
        }
    }

    if ($success_flag && ($subdepth == 1)) { print "next array slice\n"; $success_count++; $success_flag = 0; }
    print "Exiting reparse#$subdepth...\n";
    return @{$suboutput},$success_count,$success_flag;
}

sub read_file() {
    my $filename = $_[0];
    my @data = [];
    my $count = 0;
    
    open (my $fileh, "<", $filename) ||
        die "Unable to open '$filename'!\n ! $! !\n";
    
    while (! eof $fileh) {
        $data[$count++] = readline($fileh);
    }
    close $fileh;
    print "lines read: ".$count."\n";
    return \@data;
}

