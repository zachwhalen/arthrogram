#!/usr/bin/local/perl

# See: https://github.com/zachwhalen/arthrogram

#use experimental 'smartmatch';
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

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

			foreach (split//,$remove){

				substr($allpoints,index($allpoints,$_),1,"");
			}
	
		$layout{$tlLetter} = ($width + 1) . ":" . ($height + 1);
	
	}

	foreach (sort keys %layout){
		$layoutstring .= "$_$layout{$_}";
	}

	

	if ($have{$layoutstring} eq 'got'){
		#print "Already found this one, moving on...\n";
	}else{
		print "Generated layout: $layoutstring\n";
		open WRITE, ">>arthrogram.txt" or die "wat";
		print WRITE $layoutstring . "\n";
	}
	close WRITE;
}

exit;
