#!/usr/bin/perl

#Bia Walter

#This script takes as input a list of indel scores, multiple correct them using the Bonferroni method and outputs the combined p-values using the Fisher's method along with a list of the un-corrected and corrected p-values. 

# Bonferroni correction: $corr_i = $pvalue*$number_of_observations  
#Fisher's method for combining p-values = -2 * SUM log p-values

#$perl indels-bonferroni.pl $f4-$species.indel > indel.final

#	  INPUT -> 0.4360,0.9852,0.9734,0.0024

#		   log_sum		vector_indel_scores(corrected)	vector_indel_scores(before correction)
#	  OUTPUT-> 5.6068		0.4588,0.2409		 	0.9175,0.4237 

my $tmp2_file = shift;
open ("tmp2_file", $tmp2_file) || die "It was not possible to open file $tmp2_file\n";

while (<tmp2_file>){
	chomp;
	@list = split (/,/);

	if (/no_indels/){
		print "1\tno_indels\tno_indels\n";
		exit;
	}

	$k = @list;
	foreach my $i(@list){
		push @old_list, $i;

		$corr_p1 = $i*$k;

		if($corr_p1 > 1){
			$corr_p1 = 1.000;
		}

		$corr_p1_round = sprintf "%.2f", $corr_p1;
		push @final_list, $corr_p1_round;
		$p1_log_sum += log($corr_p1_round);
	}
}

$p1_vec_corr = join ',', @final_list;
$p1_vec = join ',', @old_list;


#Multiplying -2 to the sum of the logs to calculate the combination of pvalues by the Fisher's method
$p1_log_sum = $p1_log_sum*(-2);
$p1_log_sum_round = sprintf "%.4f", $p1_log_sum;

print "$p1_log_sum_round\t$p1_vec_corr\t$p1_vec\n";		

close tmp2_file;

