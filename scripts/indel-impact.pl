#!/usr/bin/perl

#Bia Walter

#This script processes an RNAforester output into a shorter format. Output contains the ID of the indel, its size, if it is an insertion or deletion and the structural impact of it (impact detected from RNAforester in line indicated by pattern /global optimal score:\s(\d+)/).

#$perl indel-impact.pl RNAforester.out $i > indel.tmp
#Input argument $i is of the following format: mutated(\d+)\-(\d+)\-(\w+).fa

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

$reading_name = shift;

while (<reading_file>){
	chomp;
	if (/global optimal score:\s(\d+)/){
		$impact = $1;


		if($reading_name =~ /mutated(\d+)\-(\d+)\-(\w+)/){
			print "mutated$1\t$2\t$3\t$impact\n";
			last;
		}
	}
}

close reading_file;

