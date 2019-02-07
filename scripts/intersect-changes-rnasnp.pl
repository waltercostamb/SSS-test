#!/usr/bin/perl

#Bia Walter

#This script takes as inputs files: (i) changes of species and (ii) analyse-RNAsnp.tmp1. It then gets the intersection of changes of the species and the SNPs reported by RNAsnp. 

#$perl ds.pl alignment_changes-nogaps_output.changes output.tmp1 SPECIES > $f4-$species.tmp2

#OUTPUT format example below:  	(changes	number	posBASE-d_max-pvalue1-pvalue2 , posBASE-d_max-pvalue1-pvalue2)

#				changes 	2	24G-0.0024-0.9175-0.9043      ,	28A-0.0436-0.4237-0.4150
#       			nc-RNA-length	128


use strict;

my $changes_file = shift;
my $tmp1_file = shift;
open ("changes_file", $changes_file) || die "It was not possible to open file $changes_file\n";
open ("tmp1_file", $tmp1_file) || die "It was not possible to open file $tmp1_file\n";

my $working_species = shift;
my $marker0 = 0;
my $marker2 = 0;
my @rows;
my @rows2;
my $l;
my $ds;
my $sp1;
my $sp2;
my $alg_bases = "";
my $rnasnp_bases = "";
my @alg = "";

while (<changes_file>){
	if(/identifier/){
		$marker0 = 1;
		next;
	} 

	if ($marker0 == 1){
		chomp;
		@rows = split (/\t/);
		$sp1 = $rows[1];
	
		if($sp1 eq $working_species){
			$alg_bases = $rows[5]; #Row that contains alignment positions
			@alg = split (/\,/, $alg_bases);
			$l = $rows[3]; #For synonymous site calculation

			if ($rows[4] =~ /^\-$/){
				print "changes\t0\t-\n";
				print "nc-RNA-length\t$l\n";
				close changes_file;
				close tmp1_file;
				exit;
			}
			$marker2 = 1;
			last;
		}
	}
}

if ($marker2 == 0){
	print "The species you want to search ($working_species) is not available in file $changes_file!\n";
	exit;
}

my @rnasnp = "";
while (<tmp1_file>){
	if(/RNAsnp-report-bases/){
		chomp;
		@rows2 = split (/\t/);
		$rnasnp_bases = $rows2[2];
		@rnasnp = split (/,/, $rnasnp_bases);
	}

	if ($rows2[2] =~ /^\-$/){
		print "changes\t0\t-\n";
		print "nc-RNA-length\t$l\n";
		close changes_file;
		close tmp1_file;
		exit;
	}
}

my $x = 0;
my $a;
my $b; 
my $intersect = "";

foreach $a(@alg){

	#Substitutes all possible U's to T's of changes file
	$a =~ s/U/T/g;

	foreach $b(@rnasnp){

		my @raw_base_snp = split (/\-/,$b);

		#Substitutes all possible U's to T's of RNAsnp file
		$raw_base_snp[0] =~ s/U/T/g;

		if ($a eq $raw_base_snp[0]){
			$x++;
			if ($intersect eq ""){
				$intersect = $a."-"."$raw_base_snp[1]"."-"."$raw_base_snp[2]"."-"."$raw_base_snp[3]";		
			} else {
			  	  $intersect = $intersect.",".$a."-"."$raw_base_snp[1]"."-"."$raw_base_snp[2]"."-"."$raw_base_snp[3]";
			  }
		}
	}
}

if ($intersect eq ""){
	$intersect = "-";
}

print "changes\t$x\t$intersect\n";
print "nc-RNA-length\t$l\n";

close changes_file;
close tmp1_file;


