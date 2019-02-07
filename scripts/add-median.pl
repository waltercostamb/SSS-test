#!/usr/bin/perl -w

#Bia Walter

#This script takes as inputs (i) an sdss file and (ii) the distance median of the species, and outputs the sdss with the median. 

#$perl add-median.pl sdss.final median > sdss-with-median.final;

my $tmp2_file = shift;
open ("tmp2_file", $tmp2_file) || die "It was not possible to open file $tmp2_file\n";

my $median = shift;

my $header_detector = 0;

while (<tmp2_file>){
	chomp;
	if($header_detector == 0){
		print "$_\tfamily_diversity\n"
	} else {
		print "$_\t$median\n";
	}
	$header_detector++;
}

close tmp2_file;





