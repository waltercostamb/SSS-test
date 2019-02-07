#!/usr/bin/perl -w

#Bia Walter
#This script adds the indel scoring to the base-to-base sd-ss scoring and outputs the corrected score.

#$perl add-scores.pl sdss.tmp indel/weight.tmp > sdss_indel/weight.tmp

my $base_file = shift;
my $indel_file = shift;

open ("base_file", $base_file) || die "It was not possible to open file $base_file\n";
open ("indel_file", $indel_file) || die "It was not possible to open file $indel_file\n";

$marker_distance = 0;

while (<base_file>){
	chomp;

	@line = split (/\s+/);

	$file = $line[1];
	$length = $line[3];

	if (defined $line[4]){
		if($line[4] ne "" && $line[4] ne "*"){
			$distance = $line[4];
			$marker_distance = 1;
		}
	}

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

#print "$file\t$length\t($nc/$ns)/($sc/$ss)\n";

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

$score = ($nc_new/$ns_new)/($sc_new/$ss_new);

if ($marker_distance == 0){
	if ($flag == 0){
		printf ("%.2f",$score);
       		print "\t$file\t($nc_new/$ns_new)/($sc_new/$ss_new)\t$length\n";
	} elsif ($flag == 1) {
		printf ("%.2f",$score);
       		print "\t$file\t($nc_new/$ns_new)/($sc_new/$ss_new)\t$length\t*\n";
	}
}

if ($marker_distance == 1){
	if ($flag == 0){
		printf ("%.2f",$score);
       		print "\t$file\t($nc_new/$ns_new)/($sc_new/$ss_new)\t$length\t$distance\n";
	} elsif ($flag == 1) {
		printf ("%.2f",$score);
       		print "\t$file\t($nc_new/$ns_new)/($sc_new/$ss_new)\t$length\t$distance\t*\n";
	}
}


close base_file;
close indel_file;


