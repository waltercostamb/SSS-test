#!/usr/bin/perl -w

#Bia Walter
#This script adds the indel scoring to the base-to-base sd-ss scoring, and then outputs two values: (i) number of synonymous changes and (ii) number of non-synonymous changes.

#$perl add-scores.pl sdss.tmp indel.tmp > selection.tmp

my $base_file = shift;
my $indel_file = shift;

open ("base_file", $base_file) || die "It was not possible to open file $base_file\n";
open ("indel_file", $indel_file) || die "It was not possible to open file $indel_file\n";

while (<base_file>){
	chomp;

	@line = split (/\s+/);

	$file = $line[1];
	$length = $line[3];

	@int1 = split (/\)\/\(/, $line[2]);
	@int2 = split (/\//, $int1[0]);
	$ns = $int2[1];

	$int2[0] =~ s/^\(//s;
	$nc = $int2[0];

	@int3 = split (/\//, $int1[1]);
	$sc = $int3[0];
	$int3[1] =~ s/\)$//s;
	$ss = $int3[1];
}

$nc_new = 0;
$ns_new = 0;
$sc_new = 0;
$ss_new = 0;

#Keeping species sequence in array @sp_seq
while (<indel_file>){
	chomp;

	@line = split (/\s+/);

	$nc_new = $nc + $line[0];
	$ns_new = $ns + $line[1];
	$sc_new = $sc + $line[2];
	$ss_new = $ss + $line[3];
}

$flag = 0;

if($nc_new <= 0){
	$nc_new = 0.1;
	$flag = 1;
}

if($ns_new <= 0){
	$ns_new = 0.1;
	$flag = 1;
}

if($sc_new <= 0){
	$sc_new = 0.1;
	$flag = 1;
}

if($ss_new <= 0){
	$ss_new = 0.1;
	$flag = 1;
}

print "$file\t$nc_new\t$sc_new\t$length\n";


close base_file;
close indel_file;


