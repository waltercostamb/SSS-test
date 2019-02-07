#!/usr/bin/perl

#Bia Walter

#This script takes rnasnp_summary.tmp0 file, which has the bases in the consensus positions, and outputs the same file with the alignment positions.

#$perl tmp0_aligned.pl $f4-consensus.tmp0 $f4-consensus.alg > $f4-consensus.tmp0.1

use Data::Dumper;

$tmp0_file1 = shift;
$consensus_alg = shift;

open ("tmp0_file1", $tmp0_file1) || die "It was not possible to open file $tmp0_file1\n";
open ("consensus_alg", $consensus_alg) || die "It was not possible to open file $consensus_alg\n";

while (<tmp0_file1>){
	chomp;
	@row = split (/\t/);
	$pos = $row[1];	
}

while (<consensus_alg>){
	chomp;

	unless(/^>/){
		@base = split (//, $_);
		$alg = 1;
		$sp = 0;
		foreach $b(@base){
			unless($b eq '_'){
				$sp++;
				$correspond{$sp} = $alg;
			}	
			$alg++;
		}
	}
}

unless ($pos eq "-") {
	@old_pos = split (',', $pos);	  

	foreach $old(@old_pos){
		@base = split (/\-/, $old);

		if ($base[0] =~ /(\d+)(\w)/){
			$position = $1;
			$base = $2;
		}

		$revised_pos = $revised_pos.",".$correspond{$position}.$base."-".$base[1]."-".$base[2]."-".$base[3];
	}

	$str = substr $revised_pos, 1;

	print "RNAsnp-report-bases-alg-positions\tconsensus\t$str\n";
} else {
	print "RNAsnp-report-bases-alg-positions\tconsensus\t-\n";
}

close tmp0_file1;
close consensus_alg;

