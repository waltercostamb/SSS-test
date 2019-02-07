#!/usr/bin/perl - w

#Bia Walter
#Script takes an aligned FASTA file and outputs a no-gap FASTA sequence.

#$perl nogap.pl aligned.fa

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

foreach (<reading_file>){
	chomp;
	if (/^>/){
		print "$_";          
	} else {
		@al_seq = split (//);
		foreach$x(@al_seq){
			unless($x eq "-"){
				print "$x";
			}
		}         
	}
	print "\n";
}

close reading_file;

