
use DBI;
package Auction;

open FILE, "..\\year.txt";
my $year = <FILE>;
chomp $year;
close FILE;

my $dbfile = "c:\\auction${year}\\database\\${year}db.db";

sub new
{
    my $self;
    $self->{dbh} = DBI->connect("DBI:SQLite:dbname=$dbfile", "", "");

    bless $self;
}
