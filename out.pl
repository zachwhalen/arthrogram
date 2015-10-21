#!/usr/bin/local/perl

#  This is the commented version of the script I used to generate "An Arthrogram", which creates potential panel layouts in a 3x3 grid.
#  With modification, this script can easeily create other grid-based layouts; 
#  just change the $maxRows,$maxCols, $allpoints, $columns, and $rows accordingly.
#  More information at http://www.zachwhalen.net/posts/introducing-an-arthrogram/ ‎
#  
#  This program is (c) 2015 Zach Whalen, but it's released under a CC BY 4.0 license.
#  https://creativecommons.org/licenses/by/4.0/


# use experimental 'smart match'. This makes something easier later on.
no if $] >= 5.017011, warnings => 'experimental::smartmatch'; # I don't actually understand this line. I found it on Stack Overflow

# This is going to make layouts that follow a 3 by 3 grid like
# ...
# ...
# ...

# So each grid position gets named like
# ABC
# DEF
# GHI

# Define it like
$maxRow = 3;
$maxCol = 3;

# Make sure there's a file for writing layouts to
system ("touch arthrogram.txt");

# this while (1) makes it run forever
# (watch its output and kill it when it hasn't a new layout for a while)
while (1){
	
	# load all the layouts we've already found so we not re-finding them
	open READ, "arthrogram.txt" or die "couldn't find it";
	@already = <READ>;
	close READ;
	my %have = {};
	foreach (@already){
		chomp;
		$have{$_} = 'got';
	}

	# each of those letter-named grid positions is a string
	my $allpoints = 'ABCDEFGHI';

	# it has to be rotated too
	
	my $columns = 'ADGBEHCFI';
	my $rows = 'ABCDEFGHI'; # yes is the same as $allpoints, I don't remember why
	
	# start building a potential layout
	my %layout; # a hash
	my $layoutstring = ''; #a string
	
	# LOOK is a label, which lets me jump back to this point early if overlaps are discovered
	LOOK: while (length($allpoints) > 0){

		# pick a letter from that $allpoints string
		my $point = substr($allpoints,int(rand(length $allpoints)),1);
		# ... and figure out it's position as x,y coordinates
		my ($px,$py) = (index($rows,$point) % $maxRow, index($columns,$point) % $maxCol);
	
		# pick another letter from $allpoints
		my $target = substr($allpoints,int(rand(length $allpoints)),1);
		# ... and figure out it's position as x,y coordinates 
		my ($tx,$ty) =  (index($rows,$target) % $maxRow, index($columns,$target) % $maxCol);
	

		# can we draw a valid rectangle with these two points?
		# "valid" means that every point between the two actually exists in $allpoints 

		# sort them so we know which comes first
		my @xrange = sort($tx,$px);
		my @yrange = sort($ty,$py);

		# how far apart are these two points?
		my $width = abs($tx - $px);
		my $height = abs($ty - $py);

		# figure out where the top-left corner is
		my ($tlX, $brX) = sort($tx,$px);
		my ($tlY, $brY) = sort($ty,$py);
		my $tlLetter = substr($rows,$tlY * $maxRow + $tlX,1);

		# Now, describe this rectangle as a panel, according to my notation schema
		my $rectString = $tlLetter . ($width + 1) . ":" . ($height + 1) . ";";

		my $remove = '';

		# work up and down each row and column
		for ($w = 0; $w < $maxRow;$w++){
			for ($h = 0; $h < $maxCol; $h++){
	
				# is this between my two points?
				# and is this letter still available?
	
				my $thisletter = substr($rows,$h * $maxRow + $w,1);
				
				# if x position and y position are within the rectangle ...
				if ($w ~~ [$xrange[0]..$xrange[1]] && $h ~~ [$yrange[0]..$yrange[1]]){
					
					# ... and if it hasn't already been removed as part of some other panel
					if (index($allpoints,$thisletter) == -1){
						# overlap detected. Try another panel
						next LOOK;
					}else{
						# slate it for removal
						$remove .= $thisletter;
					}
				}
			}
		}

		# success continues! Remove all of those points slated for removal
		foreach (split//,$remove){
			substr($allpoints,index($allpoints,$_),1,"");
		}
		# add this panel to our layout
		$layout{$tlLetter} = ($width + 1) . ":" . ($height + 1);
	
	}

	# ceate the panel layout string for saving it
	foreach (sort keys %layout){
		$layoutstring .= "$_$layout{$_}";
	}

	
	# check to see if we already have this layout
	if ($have{$layoutstring} eq 'got'){
		#print "Already found this one, moving on...\n";
	}else{
		# report success
		print "Generated layout: $layoutstring\n";
		# save it to the file
		open WRITE, ">>arthrogram.txt" or die "Ehhh, something happened";
		print WRITE $layoutstring . "\n";
	}
	close WRITE;
	# ... and look for the next one
}

exit;
