#!/usr/bin/local/perl

use Number::Spell;
#first organize all the layouts for this particular book

open READ, "threeouts.txt" or die "Can't open file";

my %stats;
my %chapters;

@lines = <READ>;

foreach (@lines){
	chomp;

	my $number = () = $_ =~ /[A-Z]/gi;

	$stats{$number} += 1;
	push(@{$chapters{$number}}, $_); 
}

# General information and settings.
# assuming eventual 150dpi
# this is 6.63 inches x 10.25 inches
my $pageWidth = 995;
my $pageHeight = 1538;
my $pageGeography = $pageWidth . "x" . $pageHeight;

# with 1/2 inch left and write margins, 3/4 inch 
my $margin = 75;
my $topMargin = 113;
my $bottomMargin = 160; # to make room for a page number
my $gutter = 8; #pad each panel with this

my $gridWidth = 3;
my $gridHeight = 3;
my $gridString = 'ABCDEFGHI';

$pageCounter = 1;

foreach $chapter (sort {$a <=> $b}  keys %chapters){

	

	print "Chapter $chapter:\n";
	print "\t$pageCounter\tTitle page\n";
	my $chapTitle = &chapTitler($chapter);
	# Make chapter title page
	$pageFile = sprintf("pages/%06d.png", $pageCounter);
	system("convert -size $pageGeography xc:white $pageFile");
	system("convert $pageFile -font TrashCinema-BB-Regular -pointsize 80 -gravity center -annotate +0-200 '$chapTitle' $pageFile");
	$pageCounter += 1;

	# Make a blank page so that the first page of chapter is recto

	$pageFile = sprintf("pages/%06d.png", $pageCounter);
	system("convert -size $pageGeography xc:white $pageFile");
	$pageCounter += 1;


	foreach $pageLayout (sort bylayout @{$chapters{$chapter}}){
		doLayout($pageLayout, $pageCounter);
		$pageCounter += 1;
	}

	# if the last page is even, add a blank page so that the next chapter starts on recto
	if ($pageCounter % 2 == 0){		
		$pageFile = sprintf("pages/%06d.png", $pageCounter);
		system("convert -size $pageGeography xc:white $pageFile");
		$pageCounter += 1;
	}

	

}

exit;

sub chapTitler() {

	my $chapter = $_[0];

	return uc(spell_number($chapter));


}

sub doLayout(){

	($layout, $pageNumber) = @_;
	print "\t$pageNumber\t$layout\n";

	$pageFile = sprintf("pages/%06d.png", $pageNumber);

	system("convert -size $pageGeography xc:white $pageFile");


	my @panels = unpack("(A4)*", $layout);

	foreach (@panels){
		#print  $_ . "\n";
		my ($point) = $_ =~ m/(^[A-Z])/;

		# find the x and y offset for this panel

		my $yoffset = (($pageHeight - $topMargin - $bottomMargin) / $gridHeight) * int(index($gridString, $point) / $gridWidth) + $topMargin;

		my $xoffset = (($pageWidth - $margin - $margin) / $gridWidth) * (index($gridString, $point) % $gridWidth) + $margin;

		my ($panelX, $panelY) = $_ =~ m/([0-9]):([0-9])/;

		my $panelHeight = (($pageHeight - $topMargin - $bottomMargin) / $gridHeight) * $panelY - ($gutter * 2);

		my $panelWidth = (($pageWidth - $margin - $margin) / $gridWidth) * $panelX - ($gutter * 2);

		drawRect("$pageFile", $panelWidth, $panelHeight, $xoffset, $yoffset);
	}

	# add page number
	system("convert $pageFile -font ManlyMen-BB-Regular -pointsize 36 -gravity south -annotate +0+110 '$pageNumber' $pageFile");
}

exit;
# try to make a page
# make a rectangular page

#system("convert -size $pageGeography xc:white tmp/page.png");


#drawRect("tmp/page.png", 340, 600, 200, 200);
# borrowing from granogen
sub drawRect  {
	
	my ($canvas, $width, $height, $xoffset, $yoffset) = @_;



	
	#make the top edge
	#the top left corner is where the image files hit, which is about 5px beyond the visible line edge
	#so width doesn't include gutter, basically

	$line = "line5.png";	
	$seed = int(rand(3500 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set tmp/lineT.png");

	$seed = int(rand(3500 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set tmp/lineB.png");

	$seed = int(rand(3500 - $height - 10));
	system("convert $line -crop 10x$height+0+$seed -alpha set  tmp/lineL.png");

	$seed = int(rand(3500 - $height - 10));
	system("convert $line -crop 10x$height+0+$seed -alpha set  tmp/lineR.png");

	my $tx = $xoffset + 5;
	my $ty = $yoffset;

	my $lx = $xoffset;
	my $ly = $yoffset + 5;

	my $rx = $xoffset + $width;
	my $ry = $yoffset + 5;

	my $bx = $xoffset + 5;
	my $by = $yoffset + $height;


	# fill it in with the image

	# apply the borders
	system("convert $canvas -page +$tx+$ty tmp/lineT.png -page +$lx+$ly tmp/lineL.png -page +$rx+$ry tmp/lineR.png -page +$bx+$by tmp/lineB.png -layers flatten $canvas");


	
}

sub bylayout {

	$first = $a;
	$second = $b;

	$first =~ s/[0-9\:]//g;
	$acount = 0;
	map {$acount += ord($_)} split(//, $first);

	$second =~ s/[0-9\:]//g;
	$bcount = 0;
	map {$bcount += ord($_)} split(//, $second);

	$acount <=> $bcount;



}