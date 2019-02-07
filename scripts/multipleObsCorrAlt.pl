#!/usr/bin/perl

#Maria Beatriz Walter Costa

#This script takes as input a list of p-values in a specific tmp2-like format, as exemplified below and returns the combined p-values using the Fisher's method, along with two lists of the individual p-values, before and after the Bonferroni correction. It (i) gets from the input pvalues1 and pvalues2 for all changes, (ii) corrects the pvalues using the Bonferroni method, (iii) calculates the log of the corrected pvalues, (iv) sum all the logs of pvalues1 and pvalues2 and (v) outputs the two combined p-values using Fisher's as well as two vectors containing p-values1 and p-values2 before and after the correction. The correction is made because of the multiple observation problem. 

#Bonferroni correction: $corr_i = $pvalue*$number_of_observations  
#Fisher's method for combining p-values = -2 * SUM log p-values

#$perl pvalues.pl $f4-$species.tmp2 > $f4-$species.pvalue

# tmp2-like format (changes-pair-compensated number posBASE-d_max-pvalue1-pvalue2 , posBASE-d_max-pvalue1-pvalue2)

#	  INPUT -> changes-pair-compensated   2 3A-0.0436-0.9852-0.9734,24G-0.0024-0.9175-0.9043
#                   nc-RNA-length	      128
#                   compensatory-changes      1 10G-0.0007-0.4456-0.5234
#                   compensatory-pairs        10-85 

#				fishers_score	vector_of_pvalue(corrected)	vector_of_log(before correction)

#	  OUTPUT-> pvalue1	-5.6068		0.4588,0.2409		 	0.9175,0.4237 
#		   pvalue2	-5.1950		0.4522,0.2075			0.9043,0.4150
 
use Data::Dumper;



use warnings;
use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);

my $input;
my $method;
my $help;

GetOptions(
        'input=s' => \$ortho_file,
        'method=s' => \$ref_species,
        'help' => \$help,
) or die "Usage: $0 --input FILE --method METHOD\n";

if ($help){
        print"This script multiple corrects a given set of p-values, according to either Bonferroni or an alternative method\n\n";
        print "Usage: $0 --input FILE --method METHOD\n";
        print "\nThe output of this script is a vector of multiple corrected p-values\n";
        die "\n";
}

open ("input_file", $input_file) || die "It was not possible to open file $input_file\n";


$p1_log_sum = 0;
$p2_log_sum = 0;
$p1_vec = "";
$p2_vec = "";

while (<input_file>){
	chomp;
	
	#Retrieving the p-values
	if(/^changes/){
		@rows = split (/\t/);

		unless ($rows[1] == 0 ){
			@changes = split (/\,/, $rows[2]);

			$k = @changes;
			#Iterating over all p-values
			foreach my $c(@changes){
				@p = split (/\-/, $c);

				$p1_vec = $p1_vec.$p[2].",";
				$p2_vec = $p2_vec.$p[3].",";

				#Bonferroni correction for p-value1
				$corr_p1 = $p[2]*$k;

				if($corr_p1 > 1){
					$corr_p1 = 1.000;
				}

				$corr_p1_round = sprintf "%.4f", $corr_p1;
				$p1_vec_corr = $p1_vec_corr.$corr_p1_round.",";

				#Check which method is set up by the user
				if ($method =~ /bonferroni/){ #TODO: add no case-sensitivity!
					#Bonferroni correction for p-value2
					$corr_p2 = $p[3]*$k;
				} elsif ($method =~ /alt/){

				}

				if($corr_p2 > 1){
					$corr_p2 = 1.000;
				}

				$corr_p2_round = sprintf "%.4f", $corr_p2;
				$p2_vec_corr = $p2_vec_corr.$corr_p2_round.",";

				#Taking the logs of the corrected p-values
				$p1_log_sum += log($corr_p1_round);
				$p2_log_sum += log($corr_p2_round);

				
			}
		} else {
				print "pvalue1\t0\t-\n";
				print "pvalue2\t0\t-\n";
				exit;
		}
	}
}



chop $p1_vec;
chop $p2_vec;
chop $p1_vec_corr;
chop $p2_vec_corr;

#Multiplying -2 to the sum of the logs to combine the pvalues using Fisher's method
$p1_log_sum = $p1_log_sum*(-2);
$p2_log_sum = $p2_log_sum*(-2);

$p1_log_sum_round = sprintf "%.4f", $p1_log_sum;
$p2_log_sum_round = sprintf "%.4f", $p2_log_sum;

#Return the combined p-values and the lists of corrected and non-corrected p-values 
print "pvalue1\t$p1_log_sum_round\t$p1_vec_corr\t$p1_vec\n";		
print "pvalue2\t$p2_log_sum_round\t$p2_vec_corr\t$p2_vec\n";	

close input_file;

