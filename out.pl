#!/usr/bin/local/perl

# See: https://github.com/zachwhalen/arthrogram

#use experimental 'smartmatch';
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

#	A 3 by 3 grid like
#	...
#	...
#	...


# So

#   ABC
#	DEF
#	GHI

# Or

$maxRow = 3;
$maxCol = 3;

# Create the file
system ("touch arthrogram.txt");

# run forever
# (have to kill it when it stops reporting new layouts)
while (1){

	open READ, "arthrogram.txt" or die "couldn't find it";

	@already = <READ>;

	close READ;

	%have = {};

	foreach (@already){
		chomp;
		$have{$_} = 'got';
	}

	my $allpoints = 'ABCDEFGHI';

	# two directions

	my $rows = 'ABCDEFGHI';
	my $columns = 'ADGBEHCFI';

	
	# start 

	my %layout;
	my $layoutstring = '';
	LOOK: while (length($allpoints) > 0){


		my $point = substr($allpoints,int(rand(length $allpoints)),1);
		my ($px,$py) = (index($rows,$point) % $maxRow, index($columns,$point) % $maxCol);
	

		my $target = substr($allpoints,int(rand(length $allpoints)),1);
		my ($tx,$ty) =  (index($rows,$target) % $maxRow, index($columns,$target) % $maxCol);
	

		# can we draw a valid rectangle with these two points?
		# valid means that every point between actually exists

		my @xrange = sort($tx,$px);
		my @yrange = sort($ty,$py);

		my $width = abs($tx - $px);
		my $height = abs($ty - $py);

		my ($tlX, $brX) = sort($tx,$px);
		my ($tlY, $brY) = sort($ty,$py);

		my $tlLetter = substr($rows,$tlY * $maxRow + $tlX,1);

		my $rectString = $tlLetter . ($width + 1) . ":" . ($height + 1) . ";";

		my $remove = '';

		for ($w = 0; $w < $maxRow;$w++){
			for ($h = 0; $h < $maxCol; $h++){

				# is this between my two points?
			    # and is this letter still available?

			    my $thisletter = substr($rows,$h * $maxRow + $w,1);

			    if ($w ~~ [$xrange[0]..$xrange[1]] && $h ~~ [$yrange[0]..$yrange[1]]){

			    	if (index($allpoints,$thisletter) == -1){
							# print "Overlap detected. Trying again....\n";
							next LOOK;
							}else{

							#continue
							# print "$thisletter is a match.\n";
							#remove it
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