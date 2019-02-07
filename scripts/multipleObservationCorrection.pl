#!/usr/bin/perl

#Maria Beatriz Walter Costa

#This script takes as input a list of p-values and returns a list of p-values multiple corrected as well as a score combining the p-values, according to a rule.
#Output: P-VALUE COMBINATION\tPVALUESLIST
#	 6.0127\t1.0000 1.0000 1.0000 1.0000 1.0000 0.1380 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 0.3585 1.0000

#Rule for combining p-values:
#	For changes: -2 * SUM log p-values
#	For indels:  -1 * SUM log p-values
 
#Another parameter taken by the script is if the input comes from change or indel, to handle the input file appropriately

#$perl multipleObservationCorrection.pl $f4-$species.pvalue change/indel > out

use Data::Dumper;
use strict;
use warnings;
use Statistics::R;

#Input file containing raw pvalues, that will be corrected for multiple observation in this script
my $tmp2_file = shift;
open ("tmp2_file", $tmp2_file) || die "It was not possible to open file $tmp2_file\n";

#Type of input can be either change or indel
my $type_of_input = shift;

#The weight is a measure given by the user that will be multiplied to the calculated score, to yield a final weighted score 
my $weight = shift;

my $line_counter = 0;

#Trying to import a scalar to R via R::Statistics, cannot be done the same way as an array (maybe a workaround?)
#my $method = "bonferroni";
my $p_value_list;
my $p_value_list2;

#Open file containing pvalues
while (<tmp2_file>){
   chomp;

   	#If the file input type is change, separate the columns first
	if ($type_of_input =~ /change/){
	   my @tmp = split (/\s/);
	
	   #This condition is here so that lists of zero p-values are not accounted for (when no species specific changes are detected, for instance)
	   unless ($tmp[2] eq '-' ){
		#Get the exact element of 1st line that contains the list of pvalues
		if ($line_counter == 0){
			$p_value_list = $tmp[3];
		} elsif ($line_counter == 1){
			chomp;
			my @tmp2 = split (/\s/);

			$p_value_list2 = $tmp2[3];
		}
		$line_counter++;
	   } else {
		print "pvalue1\t0\t-\n";
		print "pvalue2\t0\t-\n";
		exit;
	   }
	#If the file input type is indel, no ned to separate columns
	} elsif ($type_of_input =~ /indel/) {
		#If there are no detected indels on the sequence, exit and print report
		if (/no_indels/){
			print "1\tno_indels\tno_indels\n";
			exit;
       		}

		#If there are reported pvalues, store them in a string
		$p_value_list = $_;
		$p_value_list2 = $_; #Repeat the first list of p-values for working the rest of the script, and at the end, remove the second list and just print the first one
	} else {
		print "Input file type not recognized\n";
	}
}

my @p_values = split (/\,/, $p_value_list);
my @p_values2 = split (/\,/, $p_value_list2);
my $k = @p_values;

#Entering R's environment	
my $R = Statistics::R->new();
#Loading vectors of p-values
$R->set( 'p1', \@p_values );
$R->set( 'p2', \@p_values2 );

#Attempt at loading the method
#$R->set( 'method', \$method );

################################################################################################
#                                                                                              #
#        To change the multiple correction method, change the two lines below                  #
#                                                                                              #
################################################################################################
#Multiple correcting the p-values list
$R->run( q`p1_corrected <- p.adjust (p1, method = "BH")` );
$R->run( q`p2_corrected <- p.adjust (p2, method = "BH")` );

#Applying the log rule below to combine the p-value list with an R function (no weight is given here)
$R->run( q`p1_combined <- sum (-1*(log(p1_corrected)))` );
$R->run( q`p2_combined <- sum (-1*(log(p2_corrected)))` );

#Getting back the corrected p-value list, if there is more than one value, the R-returned string needs to be transformed into a proper array later on
my $p_values_corrected1 = $R->get('p1_corrected');
my $p_values_corrected2 = $R->get('p2_corrected');

#Getting back the scores
my $p1_log_sum = $R->get('p1_combined');
my $p2_log_sum = $R->get('p2_combined');

my $p_values_corrected_final1;
my $p_values_corrected_final2;

#If the number of observations, or pvalues is more than one, they are treated as arrays, if it equals only one, it is treated as a string
#More than one pvalue
if ($k > 1) {

	#Transforming the list into a proper array
	my @p_values_corrected_temp1 = @$p_values_corrected1;
	my @p_values_corrected_temp2 = @$p_values_corrected2;

	#Transforming array to string, for easy print later on
	$p_values_corrected_final1 = join (',', @p_values_corrected_temp1);
	$p_values_corrected_final2 = join (',', @p_values_corrected_temp2);

	#Remove coma at end of string
	chop $p_values_corrected_final1;
	chop $p_values_corrected_final2;

#Only one pvalue
} elsif ($k == 1) {

	#The pvalue gotten from R is already a string, so there is no need for transformations
	$p_values_corrected_final1 = $p_values_corrected1;
	$p_values_corrected_final2 = $p_values_corrected2;
	
}

#Line below gives different weights to the score, considering the user weight choice
$p1_log_sum = $p1_log_sum * $weight;
$p2_log_sum = $p2_log_sum * $weight;

#Rounding up the scores
my $combined_pvalues1 = sprintf "%.4f", $p1_log_sum;
my $combined_pvalues2 = sprintf "%.4f", $p2_log_sum;

#Printing the scores and pvalues lists, corrected and raw

#For changes:
if ($type_of_input =~ /change/){
	print "pvalue1\t$combined_pvalues1\t$p_values_corrected_final1\t$p_value_list\n";
	print "pvalue2\t$combined_pvalues2\t$p_values_corrected_final2\t$p_value_list2\n";
} elsif ($type_of_input =~ /indel/) {
	#For indels:
	print "$combined_pvalues1\t$p_values_corrected_final1\t$p_value_list\n";
}

close tmp2_file;

