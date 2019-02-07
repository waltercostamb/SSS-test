#!/usr/bin/perl

#Script by Bia Walter

#This script takes as input an alignment and a specific species and outputs a new alignment without the species sequence and header. 
#Input has to be in twoline format!

#$perl alignment-without-species.pl alignment.alg SPECIES

use Data::Dumper;

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";
$species = shift;

$i = 0;

while (<reading_file>){
	chomp;
	if (/^>/){
		if (/\t\|\t$species$/){
			$i = 1;
		} else {
			print $_, "\n";
		}
	} else {
		if ($i == 0){
			print $_, "\n";
		} 
		if ($i == 1){
			$i = 0;
		}
	}
}

close reading_file;

