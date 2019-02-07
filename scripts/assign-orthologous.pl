#!/usr/bin/perl

#Script by Bia Walter

#This script receives a fasta file containing substructures on lncRNAs of many species. It then classifies each substructure, or entry of the fasta file, according to the alignment position of the long non-coding molecule. The first header will be the first substructure. Following headers will be compared to the previous ones, and if the alignment position of the sequence is within 30% of the start and end of the substructure, the header will be assigned to this substructure. Threshol of 30% can be changed, and is assigned to variable $threshold_set_by_user.

#$perl assign-orthologous.pl substructures.fasta

use strict;
use Data::Dumper;

my $reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

my $threshold_set_by_user = 0.3;

my $species;
my @line;
my %class;
my $i = 0;
my @alg_positions;
my @alg_positions_class;
my $length;
my $sub = 0;
my $marker;
my $thresh;

#Work all headers
while (<reading_file>){
	chomp;
	if (/^>/){
		#Set marker to default zero
		$marker = 0;
		#Assign current alignment positions
		@line = split /\s+/;
		@alg_positions = split (/-/, $line[4]);	
		#Get the threshold based on the length of the current sequence
		#Threshold is (user_defined)% of the length of the current sequence
		#This threshold will be later used for defining substructure classes
		$thresh = ($alg_positions[1] - $alg_positions[0] + 1)*$threshold_set_by_user;

		#If this is the first header, assign the first $sub to 1, set it as a key to hash %class and set correspondent value to an array with the alignment positions
		if ($sub == 0){
			$sub = 1;
			#The $alg_positions[0] is always START, the $alg_positions[1] is always END
			$class{$sub} = [@alg_positions];

			#Print header of first fasta with first $sub
			print "$line[0]\t$line[1] $line[2]\t$line[3] $line[4] sub$sub | $line[6]\n";
		} else {
			#Compare current positions with positions of all substructures already stored in %class
			foreach my $sub_class (keys %class){
				#Get alg positions of the class' sub
				@alg_positions_class = @{$class{$sub_class}};

				#Define wich substructure class the current sequence belong to by the comparison below
				#If it belongs to a sub that was already defined in %class, print it accordingly, if it is a new sub, add it to %class as a new sub class
				#The start position of the current sequence has to be within $threshold of the class start, which means that (user_defined)% of the current sequence can 'escape' the class start. 'escape' means start earlier or later, but no more than a percentage
				if ($alg_positions[0] >= $alg_positions_class[0] - $thresh && $alg_positions[0] <= $alg_positions_class[0] + $thresh){

					#Condition matches means the current sequence belong to this class' sub
					#Print header of current FASTA accordingly
					print "$line[0]\t$line[1] $line[2]\t$line[3] $line[4] sub$sub_class | $line[6]\n";
					#Set marker to 1, marking that current sub has already been assigned 
					$marker = 1;
					last;
				} 
			}

			#Unless the current structure has already been assigned a sub, do the following commands
			unless ($marker == 1){
				#This is a new sub, so assign new sub and correspondent alinment positions to %class
				$sub++;
				$class{$sub} = [@alg_positions];
	
				#Print header of current FASTA accordingly
				print "$line[0]\t$line[1] $line[2]\t$line[3] $line[4] sub$sub | $line[6]\n";
			}
		}
	} else {		
		print "$_\n";
	}
}



close reading_file;

