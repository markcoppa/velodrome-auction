
use strict;

use lib "c:\\auction2019\\web";

use Buyer;
use Buyers;
use CGI;
use Item;
use Items;

use PDF::API2::Simple;
use PDF::Table;


###########
# Globals #
###########

my $dest_dir = "c:\\auction2019\\receipts";


my @months = qw(January February March April May June July August September October November December);

my $mva_address = '#512 16625 Redmond Way Ste M, Redmond, WA 98052';
my @time_fields = localtime();
my $date_string = "$months[$time_fields[4]] $time_fields[3], " . ($time_fields[5] + 1900);
my $header_image = "c:\\auction2019\\jbmv.jpg";
my $name = "Mark Coppa";
my $email = "markcoppa\@gmail.com";
my $intro_text1 = "Thank you for your generous contribution to the Marymoor Velodrome Association at our " .
                  ($time_fields[5] + 1900) . " Jerry Baker Memorial Velodrome Dinner & Fundraiser Auction.  " .
                  "Through the generosity of contributors like yourself, we were able to raise significant " .
                  "funds at this year's event.";
my $intro_text2 = "This letter is to thank you and acknowledge that at the auction you purchased:";
my $post_text1 = "This organization has been granted not-for-profit status under section 501(c)(3) of the Internal Revenue Service code. Accordingly, contributions made to the organization are deductible for federal income tax purposes subject to the following: All contributions must be supported by this receipt.  Such deduction is also limited to the excess of the amount paid for item(s) over the fair market value.  This is a good faith estimate by our organization and may not reflect \"fair market value.\"  In any event, we encourage you to consult your tax advisor regarding deductibility to you.  MVA’s Tax ID Number is 911518094.";
my $post_text2 = "Please retain this record for your tax records";
my $post_text3 = "Thank you for your generosity,";
my $post_text4 = "Mike Rogers";
my $post_text5 = "Treasurer";
my $post_text6 = "Marymoor Velodrome Association";

# Font and line height
my $line_height = 14;

my $left_x = 60;
my $restart_y = 720;
my $new_page_threshold = 20;


#########################
# Go through each buyer #
#########################

my $buyers = Buyers::new();
my $list = $buyers->{buyers};

my $cnt = 0;
foreach my $id (keys %$list)
{
    my $buyer = Buyer::new($id);
    next if ($buyer->{id} == -1);
    next if (!$buyer->{paddle});

    # Only print buyers that have won something
    my $items = $buyer->{items};
    next if ($buyer->{raise_the_paddle} == 0 && (scalar keys %$items) == 0);

    my $padding_length = 40;

    my $name = $buyer->{name};
    my $email = $buyer->{email};

#next unless ($name =~ /Andrew Baker/);

    my $paddle = PadWithZeros($buyer->{paddle}, 3);
    my $file = "${dest_dir}\\${paddle}_${name}.pdf";
    $file =~ s/ /_/g;

    if (-f $file)
    {
        `del $file`;
    }

    my $current_y = StartPdf($file, $name, $email);
    $current_y = PrintPdfTable($file, $items, $current_y, $buyer->{raise_the_paddle});
    EndPdf($file, $current_y);

    print "$file\n";
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



# PadWithZeros
# Purpose:
#
#############################################################################
sub PadWithZeros
{
    my ($s, $length) = @_;

    my $diff = ($length - (length $s));
    for (my $i = 0; $i < $diff; ++$i)
    {
        $s = "0" . $s;
    }

    return $s;
}


# StartPdf
#
#############################################################################
sub StartPdf
{
    my ($file, $name, $email) = @_;

    my $pdf = PDF::API2::Simple->new(file => "$file", line_height => $line_height, margin_right => 60);
    $pdf->add_font('Helvetica');
    $pdf->add_page();

    # Starting point
    my $current_y = 680;

    # Add header image
    my %image_opts = (x => 85, y => $current_y, width => 470, height => 90);
    $pdf->image($header_image, %image_opts);

    # Add MVA address
    $current_y -= $line_height;
    my %address_text_opts = (x => 180, y => $current_y);
    $pdf->text($mva_address, %address_text_opts);

    # Add date
    $current_y -= (2 * $line_height);
    my %date_text_opts = (x => 450, y => $current_y, font_size => 14);
    $pdf->text($date_string, %date_text_opts);

    # Add name and email
    $current_y -= (2 * $line_height);
    my %name_text_opts = (x => $left_x, y => $current_y, font_size => 14);
    $pdf->text("Dear $name,", %name_text_opts);

    $current_y -= $line_height;
    my %email_text_opts = (x => $left_x, y => $current_y, font_size => 14);
    $pdf->text($email, %email_text_opts);

    # Add intro texts
    $current_y -= (2 * $line_height);
    my %intro_text1_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($intro_text1, %intro_text1_opts);

    $current_y -= (5 * $line_height);
    my %intro_text2_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($intro_text2, %intro_text2_opts);

    $pdf->save();

    return $current_y;
}


# PrintPdfTable
#
#############################################################################
sub PrintPdfTable
{
    my ($file, $items, $current_y, $raise_the_paddle) = @_;

    my $pdf = PDF::API2->open("$file");
    my $page = $pdf->openpage(1);
    my $pdftable = new PDF::Table;

    my $cell_props = [
        [ #This array is for the first row. If header_props is defined it will overwrite these settings.
             {    #Row 1 cell 1
                background_color => '#000080',
                font_color       => 'white',
             },
             {    #Row 1 cell 2
                background_color => '#000080',
                font_color       => 'white',
             },
             {    #Row 1 cell 3
                background_color => '#000080',
                font_color       => 'white',
             },
            # etc.
        ],
        [#Row 2
            {    #Row 2 cell 1
                background_color => 'white',
                font_color       => 'black',
            },
            {    #Row 2 cell 2
                background_color => 'white',
                font_color       => 'black',
            },
            {    #Row 2 cell 3
                background_color => 'white',
                font_color       => 'black',
            },
        ],
    ];

    my $col_props = [
    {},# This is an empty hash so the next one will hold the properties for the second column from left to right.
    {
        justify => 'center',
    },
    {
        justify => 'center',
    },
    ];

    my $total_fmv = 0;
    my $total_paid = 0;


    # Convert items to a 2-dimensional array
    my $cnt_rows = 0;
    my @data;
    $data[0][0] = "Item Description";
    $data[0][1] = "Fair Market Value";
    $data[0][2] = "Price Paid";

    if (scalar keys %$items > 0)
    {
        foreach my $item_id (sort {$a <=> $b} keys %$items)
        {
            ++$cnt_rows;
            my $item = $items->{$item_id};
            $data[$cnt_rows][0] = $item->{description};
            $data[$cnt_rows][1] = MakeDollar($item->{value});
            $data[$cnt_rows][2] = MakeDollar($item->{final_price});

            $total_fmv += $item->{value};
            $total_paid += $item->{final_price};
        }
    }

    if ($raise_the_paddle > 0)
    {
        ++$cnt_rows;
        $data[$cnt_rows][0] = "Jerry Baker Development Fund";
        $data[$cnt_rows][1] = "\$0";
        $data[$cnt_rows][2] = MakeDollar($raise_the_paddle);

        $total_paid += $raise_the_paddle;
    }


    # Totals
    ++$cnt_rows;
    $data[$cnt_rows][0] = "Total";
    $data[$cnt_rows][1] = MakeDollar($total_fmv);
    $data[$cnt_rows][2] = MakeDollar($total_paid);


    $current_y -= $line_height;
    $pdftable->table
    (
        $pdf,
        $page,
        \@data,
        x => $left_x,
        w => 500,          # width
        start_y => $current_y,
        start_h => 300,    # height of table on the initial page

        padding => 5,  # all sides cell padding
        font => $pdf->corefont("Helvetica"),
        cell_props => $cell_props,
        column_props => $col_props,
    );

    $pdf->saveas($file);

    # Artifically count y different; TODO use calculated value when using real data
    $current_y -= (($cnt_rows + 1) * $line_height * 2);
    $current_y -= $line_height;

    return $current_y;
}


# EndPdf
#
#############################################################################
sub EndPdf
{
    my ($file, $current_y) = @_;

    # Reopen with Simple
    my $pdf = PDF::API2::Simple->open('open_file' => $file,
                                   'open_page' => 1, # default is 1
                                   line_height => $line_height
                                  );
    $pdf->add_font('Helvetica');

    my %post_text1_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($post_text1, %post_text1_opts);

    $current_y -= (9 * $line_height);
    if ($current_y < $new_page_threshold)
    {
        $current_y = $restart_y;
    }
    my %post_text2_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($post_text2, %post_text2_opts);

    # Thank you for your generosity
    $current_y -= (2 * $line_height);
    if ($current_y < $new_page_threshold)
    {
        $current_y = $restart_y;
    }
    my %post_text3_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($post_text3, %post_text3_opts);

    $current_y -= (3 * $line_height);
    if ($current_y < $new_page_threshold)
    {
        $current_y = $restart_y;
    }
    my %post_text4_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($post_text4, %post_text4_opts);

    $current_y -= $line_height;
    if ($current_y < $new_page_threshold)
    {
        $current_y = $restart_y;
    }
    my %post_text5_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($post_text5, %post_text5_opts);

    $current_y -= $line_height;
    if ($current_y < $new_page_threshold)
    {
        $current_y = $restart_y;
    }
    my %post_text6_opts = (x => $left_x, y => $current_y, autoflow => 1, font_size => 14);
    $pdf->text($post_text6, %post_text6_opts);

    $pdf->save($file);
}



