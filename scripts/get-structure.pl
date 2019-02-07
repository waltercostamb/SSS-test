#!/usr/bin/perl - w

#Bia Walter
#Script takes as input a RNAfold.out file and outputs the MFE structure in a one line dot-bracket format.

#$perl get-structure.pl RNAfold.ot

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

foreach (<reading_file>){
	chomp;
	if (/\S+\s+\(/){
		@mfe = split (/\s/);
		print $mfe[0],"\n";
	}
}

close reading_file;


