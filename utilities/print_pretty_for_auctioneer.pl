
use strict;

use Auction;
use Buyers;

print "Starting...\n";

my $buyers = Buyers::new();

my $data = {};

open FILE, ">for_jeff.csv";
my $list = $buyers->{buyers};
foreach my $id (sort {$a <=> $b} keys %$list)
{
    my $paddle = $list->{$id}->{paddle};
    next if ($paddle eq "");

    my $name = $list->{$id}->{name};
    $data->{$paddle} = $name;
}

foreach my $key (sort {$a <=> $b} keys %$data)
{
    print FILE "$key,$data->{$key}\n";
}

close FILE;
