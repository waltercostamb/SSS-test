#!/usr/bin/perl

#Bia Walter

#This script transforms an RNAforester output in a format of columns, containing in each line the length of the input sequence, start of the gap which was used in the gap-modelling pipeline, length of gap and distance reported by RNAforester found in pattern /global optimal score:\s(\d+)/.

#$perl format-output.pl gap-modelling.out RNA_LENGTH START GAP_LENGTH > gap-modelling.formatted


$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

$rna_length = shift;
$start = shift;
$gap_length = shift;

#print "RNA_length\tgap_start\tgap_length\tstructural_distance\n";

while (<reading_file>){
	chomp;
	if (/global optimal score:\s(\d+)/){
		print "$rna_length\t$start\t$gap_length\t$1\n";
	}
}

close reading_file;

