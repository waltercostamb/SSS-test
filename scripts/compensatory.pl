#!/usr/bin/perl -w

#Bia Walter
#This script checks if any of the changed bases from the species form compensatory pairings when compared to the structure of the consensus. If so, it re-evaluates the number of changes (new_ch = old_ch - compensatory). 
#To do that the script takes as input the two dot plots and a tmp2 file containing all the changes. It analyses the MFEs of both dot plots, by going only at the lines marked by `lbox` and comparing the pairings, if a pair matches both dot plots, the change is printed along with the corresponding compensatory pair.

#$perl compensatory.pl family-species.tmp2 consensus-plot.ps species-plot.ps > $f4-$species.tmp2.1
#Obs: family-species.tmp2 should contain alignment positions


#	  FORMAT-> (changes	       	 number	posBASE-d_max-pvalue1-pvalue2 , posBASE-d_max-pvalue1-pvalue2)

#Example: INPUT ->  changes                   2 3A-0.0436-0.9852-0.9734,10G-0.0007-0.4456-0.5234
#                   nc-RNA-length	      128

#	  FORMAT-> (changes-pair-compensated number posBASE-d_max-pvalue1-pvalue2 , posBASE-d_max-pvalue1-pvalue2)

#	  OUTPUT -> changes-pair-compensated  1 3A-0.0436-0.9852-0.9734
#                   nc-RNA-length	      128
#                   compensatory-changes       1 10G-0.0007-0.4456-0.5234
#                   compensatory-pairs        10-85 

use Data::Dumper;

my $species_tmp2 = shift;
my $consensus_plot = shift;
my $species_plot = shift;

open ("species_tmp2", $species_tmp2) || die "It was not possible to open file $species_tmp2\n";
open ("consensus_plot", $consensus_plot) || die "It was not possible to open file $consensus_plot\n";
open ("species_plot", $species_plot) || die "It was not possible to open file $species_plot\n";

while (<consensus_plot>){
	chomp;
	if (/lbox$/){
		@field = split (/\s/);
		$p = $field[0]."-".$field[1];
		push (@consensus_pairs, "$p"); 
	}
}

while (<species_plot>){
	chomp;
	if (/lbox$/){
		@field = split (/\s/);
		$s = $field[0]."-".$field[1];
		push (@species_pairs, "$s");
	}
}

$marker2 = 0;
$compensatory = "";
$compensatory_pairs = "";
$size_compensatory = 0;

while (<species_tmp2>){
	chomp;
	if(/changes/){
		@rows = split (/\t/);
		$db = $rows[2];

		if($rows[1] =~ /^0$/){
			print "changes-pair-compensated\t0\t-\n";
			next;
		}

		@base0 = split (/,/, $db);
		foreach $b0(@base0){
			@base1 = split (/\-/, $b0);
			if ($base1[0] =~ /^(\d+)/){
				$base{$1} = $b0;				
				push (@base, $1);
			}
		}

		foreach $b(@base){
			$marker = 0;
			foreach $x(@species_pairs){	
				if ($x =~ /^$b\-/ || $x =~ /\-$b$/){
					foreach $c(@consensus_pairs){
						if ($c eq $x){
							$marker2 = 1;
							$marker = 1;
							if ($compensatory eq ""){
								$compensatory = $base{$b};
								$compensatory_pairs = $x;
								$size_compensatory++;
							} else {
								$compensatory = $compensatory.",".$base{$b};
								$compensatory_pairs = $compensatory_pairs.",".$x;
								$size_compensatory++;
							}
						}
					}
				}
			}
			if ($marker == 0){
				push (@corrected_bases, $base{$b});
			}
		}

		$size = @corrected_bases;
		$new = "";
		foreach $e(@corrected_bases){
			if($new eq ""){
				$new = $e;
			} else{
				$new = $new.",".$e;
			}
		}
		if ($size == 0){
			$new = "-";
			print "changes-pair-compensated\t$size\t$new\n";
		} else {
			print "changes-pair-compensated\t$size\t$new\n";
		}
	} else {
		print $_, "\n";
	}
}

if($marker2 == 1){
	print "compensatory-changes\t$size_compensatory\t$compensatory\n";
	print "compensatory-pairs\t$compensatory_pairs\n";
}

close species_tmp2;
close consensus_plot;
close species_plot;

