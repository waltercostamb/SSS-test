#!/usr/bin/perl

#Script by Bia Walter

#This script receives reports from RNALfold and gives as an output a processed report, containing only the regions of sub-structures with highest z-score that do not overlap. Input is not the raw report from RNALfold, but the sorted report ($sort -k3 -n report > report.sorted)

#The user should also provide a second argument: the species of the sequence, so that the script outputs the species at the end of every line 

#$perl best-substructures.pl report.sorted SPECIES

use strict;
use Data::Dumper;

my $reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

my $species = shift;

my @structures;

#Storing all substructures in @structures
while (<reading_file>){
	chomp;

	if (/z=/){
		push (@structures, $_);
	}
               
}

my @line;
my $old_ref;
my $old_pos = 0;
my $old_z;
my $old_length;
my $old_lim;
my $ref_pos;
my $ref_data;
my $ref_z;
my $ref_length;
my $i = 0;
my $sup_lim;
my $curr_z;
my $curr_length;
my $marker = 0;

#Grouping substructures
foreach (@structures){
   unless($_ eq ""){
	@line = split (/\s+/);

	if ($i == 0){
		#Set first position as the group comparator position
		$ref_pos = $line[2];
		#Set first group data as the group representative
		$ref_data = $_;
		$ref_z = $line[4];
		$ref_length = length $line[0];
		#Setting the superior limit position for the ref_lncRNA, summing initial pos + length, adding 5 nt after the end of this substructure to set a marging for the next substructure to coexist 
		$sup_lim = $ref_pos + $ref_length + 5;
		$i = 1;
	} else {
		  #If true, current substructure cannot coexist with the reference 
		  if ($line[2] <= $sup_lim){

			$curr_z = $line[4];

        		#Compare z-score, only substitute representative for the current one, if current z-score is better than the representative	
		  	if($curr_z < $ref_z){

				if($marker == 0){
					#Sets old reference to $old_ref
                                	$old_ref = $ref_data;
                                	$old_pos = $ref_pos;
                                	$old_z = $ref_z;
                                	$old_length = $ref_length;
					$old_lim = $sup_lim;
					$marker = 1;
				}

				#Substitutes reference for current subtructure
		  	  	$ref_data = $_;
			  	$ref_pos = $line[2];
			  	$ref_z = $line[4];
				$ref_length = length $line[0];
				$sup_lim = $ref_pos + $ref_length + 5; 
			}
		  #Else, current sub-structure constitutes a different group as the reference, then, print old reference and change old reference for current new sub-group
		  } else{
			  #Compare positions of new reference and old reference
			  if($old_pos != 0 && $ref_pos >= $old_lim){
			  	print "$old_ref\t$species\n";
			  }
			
               	  	  print "$ref_data\t$species\n";
	                  #Substitutes reference for current subtructure
			  $ref_pos = $line[2];
			  $ref_data = $_;
			  $ref_z = $line[4];
			  $ref_length = length $line[0];
			  $sup_lim = $ref_pos + $ref_length + 5;

			  $marker = 0;
			  $old_pos = 0;
		    }
	  }
   }
}

if ($old_pos != 0 && $ref_pos >= $old_lim){
	print "$old_ref\t$species\n";
}

if ($ref_data ne ""){
	print "$ref_data\t$species\n";
}

close reading_file;




