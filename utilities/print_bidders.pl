
use strict;

use Auction;
use Buyers;


my $buyers = Buyers::new();

my $data = {};

my $list = $buyers->{buyers};
foreach my $id (sort {$list->{$a}->{name} cmp $list->{$b}->{name}} keys %$list)
{
    my $email = $list->{$id}->{email};


    if ($email eq "")
    {
        $email = "*** GET EMAIL ADDRESS ***"
    } 

    my $name = $list->{$id}->{name};

    print "$name\t\t$email\n";
    
}

