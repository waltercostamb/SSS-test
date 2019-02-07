#!/usr/bin/perl

#Bia Walter

#This script takes as input an alignment in the sd-ss format (>file\t|\tSPECIES) and outputs it with a simpler header (>SPECIES), better suited for BioPerl convertAlignment.pl. 

#$perl convert-format.pl alignment.alg > align.alg


$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

while (<reading_file>){
	chomp;

	if (/^>\S+\t\|\t(\S+)$/){
		print ">$1\n";
	} else {
		print $_, "\n";
	}
}

close reading_file;


