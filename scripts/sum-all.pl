#!/usr/bin/perl

#Bia Walter

#This script takes as inputs (i) tmp2 and (ii) structural distance files. It then sums all the individual structural impact of all changes of the species. 

#$perl sum-all.pl $f4-$species.tmp2.1 $f4-$species.distance $species $alg_length $f4-$species.indel $f4-$species.pvalue indel.final >> sdss.final;

my $tmp2_file = shift;
open ("tmp2_file", $tmp2_file) || die "It was not possible to open file $tmp2_file\n";
my $structural_distance = shift;
my $f4 = shift;
my $species = shift;
my $alg_length = shift;

my $indel_file = shift;
open ("indel_file", $indel_file) || die "It was not possible to open file $indel_file\n";

my $pvalue_file = shift;
open ("pvalue_file", $pvalue_file) || die "It was not possible to open file $pvalue_file\n";

my $indel_final = shift;
open ("indel_final", $indel_final) || die "It was not possible to open file $indel_final\n";

my $dist_sum = 0;

while (<tmp2_file>){
	chomp;
	if(/^changes/){
		@rows = split (/\t/);
		@changes = split (/\,/, $rows[2]);
		$x = $rows[1];

		my @distance;
		foreach $i(@changes){
			@distance = split (/\-/, $i);
			$dist_sum += $distance[1];
		}
	}

	if(/length/){
		@rows2 = split (/\t/);
		$length = $rows2[1];
	}
}

while (<pvalue_file>){
	chomp;
	@rows = split (/\s/);
	if(/^pvalue1/){
		$p1_log_sum = $rows[1];
		$p1_vec = $rows[2];		
	}		
	if(/^pvalue2/){
		$p2_log_sum = $rows[1];
		$p2_vec = $rows[2];		
	}
}

while (<indel_final>){
	chomp;
	if(/no_indels/){
		$indels_list = "no_indels";
		$indel_log_sum = 0;
		last;
	}
	@rows = split (/\t/);
	$indel_log_sum = $rows[0];
	$indels_list = $rows[1]; 				
}

$sp_score = $p1_log_sum+$indel_log_sum;
$sp_score_round = sprintf "%.4f", $sp_score;

while (<indel_file>){
	chomp;	
	print "$f4-$species\t$x\t$dist_sum\t$structural_distance\t$length\t$alg_length\t$indels_list\t$indel_log_sum\t$p1_log_sum\t$p2_log_sum\t$sp_score_round\n";				
}


close tmp2_file;
close indel_file;
close pvalue_file;
close indel_final;

