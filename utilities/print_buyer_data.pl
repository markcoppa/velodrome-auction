
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

my $location = "c:\\auction${year}\\printing";


########
# main #
########

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
        push @contents, "\n\nRaise the paddle total\n----------------------\n";
        push @contents, MakeDollar($buyer->{raise_the_paddle});
        push @contents, "\n";
    }

    # Print items
    if (scalar keys %$items > 0)
    {
        push @contents, "\n\nAuction Items\n-------------\n";
        foreach my $item_id (sort {$a <=> $b} keys %$items)
        {
            my $item = $items->{$item_id};
            my $str = $item->{description};
            $str = substr($str, 0, 38);

            $str = BufferIt($str);
            $str .= MakeDollar($item->{final_price}) . "\n";
            push @contents, $str;
        }
        my $str = "Auction items total";
        $str = BufferIt($str);
        $str .= MakeDollar($buyer->{items_total}) . "\n";
        push @contents, $str;
    }

    # Print grand total
    push @contents, "\n\n";
    my $str = "Grand total";
    $str = BufferIt($str);
    $str .= (MakeDollar($buyer->{raise_the_paddle} + $buyer->{items_total})) . "\n";
    push @contents, $str;

    my $file = "$location\\$buyer->{paddle}.txt";
    unless (open FILE, ">$file")
    {
        die "Couldn't open file \"$file\" for overwriting";
    }
    print FILE @contents;
    close FILE;
}


sub BufferIt
{
    my ($str) = @_;

    my $full_size = 40;

    my $to_buffer = $full_size - length $str;
    for (my $i = 0; $i < $to_buffer; ++$i)
    {
        $str .= " ";
    }

    return $str;
}


# MakeDollar
# Purpose:
#
#############################################################################
sub MakeDollar
{
    my ($a) = @_;

    $a = reverse $a;
    my $dollar;
    my $ta;
    foreach my $number (split //, $a)
    {
        $dollar .= "," if ($ta && length($ta)%3 == 0);
        $dollar .= "$number";
        $ta .= $number;
    }

    return ("\$" . reverse $dollar);
}

