#!/usr/bin/perl

#Bia Walter

#This script takes as input a list of observed indels and their correspondent structural impacts along with background information, and returns scores analogous to p-values. The background information is calculated by rank statistics and the gap-modelling pipeline and is composed of a ranked list of `i' gap-impact groups. The present script then checks in which group `n' the observed indels are. Then it calculates the probability `p' of observing them or more extreme indel-cases using the following rule:

# p = (i-n)/i

#with `p' being the probability of observing the indel or a more extreme indel-event
#`i' varying from zero to the number of groups - 1
#`n' being the group the observed indel belongs to

#$perl indel-score.pl $f4-$species-observed.indel $f4-$species > $f4-$species.indel


$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

$file_name = shift;
$length_sequence = shift;

#Iterating over file containing the list of indel structural impacts
while (<reading_file>){

	if (/no_indels/){
		print "no_indels\n";
		exit;
	}

	chomp;
	@row = split (/\t/);
	$indel_length = $row[1]; #indel size
	$impact = $row[3]; #impact

	$n = 0; #After the while loop, $n will contain the observed rank
	$i = -1;

	#Opening the file with the ranked list of $indel_length gap-length structural impact groups
	open(my $fh, "<", "$file_name-$indel_length.indelgroup") or die "Can't open $file_name-$indel_length.indelgroup\n";

	#Compressed version of background file
	while(<$fh>){
		$i++;
		
		if(/^(\s+)(.+)/){
			$line = $2;
		} else {
			$line = $_;
		}

		@list_row = split (/\s/, $line);
		#Searching over ranked list
		#If group is found, sets group to variable $i
		if($impact >= $list_row[1]){
			$n = $i;
		}
	}

	$i++;

	#Calculating the probability of finding observed indel using the rule p = (i-n)/i, with `i' being the number of groups -1 and `n' being the group the observed indel belongs to
	#Fix 1 (in case no ranks can be calculated)
	if ($i == 0) { # can not determine rank, assume no p-value contribution
		$rank_pvalue=1.0;
	} else {
		$rank_pvalue = ($i-$n)/$i;
	}

	#Adding some experimentation on how to re-calculate the score using more than only the rank where your observed impact is

	$impact_score = 4 * $length_sequence - $impact;

	#Fix 2: in case the impact is so big, is is larger than 4*length of sequence. The assumption is that the consensus and the species are of comparable length. If not, than we set the $impact_score to 1, so that the p-value can be calculated, it will be very small, indicating big structural change (expected for big in/dels) 
	
	if ($impact_score < 1) { # impact is extreme compared to sequence length, clamp to "largest"
		$impact_score = 1;
	}

	$observed_impact_pvalue = ($impact_score)/(4*($length_sequence + 1));
	
	push (@list,($rank_pvalue*$observed_impact_pvalue));
}

$all = join ',', @list;
print "$all\n";

close reading_file;

