#!/usr/bin/perl -w

#Bia Walter

#This script takes as input a full sdss file and filters the output to exclude intermediate rows. 

#$perl filter-output.pl sdss.full > sdss.final;

my $tmp2_file = shift;
open ("tmp2_file", $tmp2_file) || die "It was not possible to open file $tmp2_file\n";

while (<tmp2_file>){
	chomp;
	@r = split (/\t/);
	print "$r[0]\t$r[1]\t$r[3]\t$r[4]\t$r[5]\t$r[7]\t$r[8]\t$r[10]\t$r[11]\n";
}

close tmp2_file;





