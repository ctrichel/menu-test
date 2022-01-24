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
our $success_total = 0;
our @output = [];

# Main 
my @menu_data = &read_file($testfile);  # read $testfile and store data in @menu_data
&parse_data(@menu_data);

print "FINAL:".Dumper($success_total,@output);

# &display_output(@final_output);
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
    
    my (%item_hash,%count_hash);

    foreach my $count (1 .. $length) {
        my ($menu_item,$item_value) = split(/,/,${$data_array}[$count]); # split data line on comma
        $item_value =~ s/^\$//; # remove '$'
        $item_value = sprintf "%0.2f",$item_value; # force numeric (strip newline)
        $item_hash{$menu_item} = $item_value; # store data pair (item and value) in hash
        $count_hash{$menu_item} = 0; # initialize count hash
    }
    
    foreach my $item (keys %item_hash) {
        if ($item_hash{$item} > $goal_total) {  print "skipping $item...\n"; next;   }
        &reparse(\%item_hash,\%count_hash,$goal_total,0);
    }
    
    return;
}

sub reparse() {    
    my %menu_items = %{$_[0]};
    my %count_hash = %{$_[1]};
    my $cost_limit = $_[2];
    my $subdepth = $_[3];

    $subdepth++;
    print "Entering reparse $subdepth...\n";
    while ($cost_limit > 0) {
        print "for loop $subdepth started\n";
        foreach my $item (keys %menu_items) {

            if ($menu_items{$item} > $cost_limit) {  print "skipping $item\n"; delete $menu_items{$item}; next;   }

            $cost_limit = $cost_limit - $menu_items{$item};
            $count_hash{$item}++;
            print "added $item\n";
            
            if ($cost_limit > 0) {
                print "calling reparse within $subdepth\n";
                &reparse(\%menu_items,\%count_hash,$cost_limit,$subdepth);
            } elsif ($cost_limit==0) {
                print "success detected\n";
                push(@main::output, \%count_hash);
                $main::success_total++;
                print "returning from $subdepth...\n";
            }
        }
        print "for loop $subdepth exited\n";
    }

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
    print "lines read: ".$count."\n";
    return \@data;
}

