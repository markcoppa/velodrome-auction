
use strict;

open FILE, "..\\year.txt" or die "Could not find year.txt";
my $year = <FILE>;
chomp $year;
close FILE;

use lib "c:\\auction${year}\\web";

use Buyer;
use Buyers;
use CGI;
use Item;
use Items;


###########
# globals #
###########

my $location = "c:\\auction${year}";


########
# main #
########


my @rtp_data;
my @item_data;


my $buyers = Buyers::new();
my $list = $buyers->{buyers};
foreach my $id (keys %$list)
{
    my $buyer = Buyer::new($id);
    next if ($buyer->{id} == -1);
    next if (!$buyer->{paddle});

    my $items = $buyer->{items};

    # Only print buyers that have won something
    next if ($buyer->{raise_the_paddle} == 0 && (scalar keys %$items) == 0);

    my $padding_length = 40;

    my @contents;
    push @contents, "Name:   $buyer->{name}\n";
    push @contents, "Email:  $buyer->{email}\n";
    push @contents, "Paddle: $buyer->{paddle}\n";

    # Print raise the paddle
    if ($buyer->{raise_the_paddle} > 0)
    {
        my $entry = "$buyer->{paddle},$buyer->{name},$buyer->{raise_the_paddle}\n";
        push @rtp_data, $entry;
    }

    # Print items
    if (scalar keys %$items > 0)
    {
        foreach my $item_id (sort {$a <=> $b} keys %$items)
        {
            my $item = $items->{$item_id};
            push @item_data, "$buyer->{paddle},$buyer->{name},$item->{description},$item->{value},$item->{final_price}\n";

        }
    }
}


open WFILE, ">$location\\jbdf.csv";
print WFILE "paddle,name,amount\n";
print WFILE @rtp_data;

open WFILE, ">$location\\items.csv";
print WFILE "paddle,name,item_description,item_value,item_final_price\n";
print WFILE @item_data;
close WFILE;

