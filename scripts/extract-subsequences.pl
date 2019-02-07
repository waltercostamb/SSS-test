#!/usr/bin/perl

#Bia Walter

#This script receives one file containing ALL best reports from RNALfold (containing the species information), AND a sequence alignment in a twoline FASTA format.

#$perl extract-subsequences.pl RNALfold.report twoline.alg

use strict;
use Data::Dumper;

my $reading_file = shift;
my $reading_file2 = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";
open ("reading_file2", $reading_file2) || die "It was not possible to open file $reading_file2\n";

my @name;
my $name_file2;

if($reading_file2 =~ /\./){
	@name = split (/\./, $reading_file2);
	$name_file2 = $name[0];
} else {
	$name_file2 = $reading_file2;
}

my @structures;

#Storing all substructures in array @structures
while (<reading_file>){
	chomp;
	push @structures, "$_";          
}

my $curr_species;
my @seq;
my @species_seq;
my $a;
my @sub;
my $first_pos;
my $last_pos;
my $last_pos_real;
my $length;
my $i;
my %positions;
my $alignment_position = 0;
my $species_position = 0;
my $m = 0;

#Going through each structure and printing the sequence, structure, species and sequence positions as well as alignment position
while (<reading_file2>){
	chomp;

	#If line is header, store species
	if (/^>(.+)\s\|\s(.+)/){
		$curr_species = $2;
	  #If line is sequence, extract sub-sequence for each sub-structure and print them, along with species
	} else {
		@seq = split ('');
		
		#This loop creates @species_seq array containing the real species sequence (without the gaps)
		foreach my $w(@seq){
			$alignment_position++;
			unless($w eq "-" || $w eq ''){
				$species_position++;
				push @species_seq, $w;
				$positions{$species_position} = $alignment_position;
			}
		}

		foreach $a(@structures){
			#Store fields of RNALfold report -for each sub-structure-
			@sub = split ('\s+', $a);

			#Looks in every RNALfold report sub-structure, if matches species with FASTA sequence, extracts correspondent sub-sequence
			if($a =~ /$curr_species/){
				$first_pos = $sub[2] - 1;
				$length = length $sub[0];
				$last_pos = $first_pos + $length - 1;
                                $last_pos_real = $first_pos + $length;
				print ">$name_file2\tspecies_pos $sub[2]-$last_pos_real\talign_pos $positions{$sub[2]}-$positions{$last_pos_real} | $curr_species\t\n";

				#Printing the sequence of the substructure
				foreach ($i = $first_pos; $i <= $last_pos; $i++){
					print "$species_seq[$i]";
				}		
				print "\n";
			}
		} 
		undef @species_seq;    
		undef %positions;
		$alignment_position = 0;
		$species_position = 0;
		$m = 1;
	  }
}

close reading_file;
close reading_file2;



