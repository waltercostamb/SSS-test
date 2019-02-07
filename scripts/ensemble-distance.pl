#!/usr/bin/perl -w

#Bia Walter
#This script compares two dot plots and outputs a distance score between the whole structural space. It analyses the upper box of the dot plot, which means the whole ensemble, and doesn't compute the MFE separately, since it is also contained in the ensemble.
#Both plots should have a direct correspondence of base position! Either they are both the same size or the input to RNAfold should be in alignment format on both inputs. 

#The ensemble structural distance is normalized by the sequence length.

#$perl ensemble-distance.pl consensus-plot_dp.ps species-plot_dp.ps $distance

my $consensus_plot = shift;
my $species_plot = shift;

open ("consensus_plot", $consensus_plot) || die "It was not possible to open file $consensus_plot\n";
open ("species_plot", $species_plot) || die "It was not possible to open file $species_plot\n";

my $alg_length = shift;

#Storing all base-pairs and correspondent probabilities in @consensus_pairs, each element is a key of hash %cons
while (<consensus_plot>){
	chomp;
	if (/ubox$/ && $_ !~ /\%/){
		@field = split (/\s/);
		$p = $field[0]."-".$field[1];
		$cons{$p} = $field[2];
		push (@consensus_pairs, "$p"); 
	}
}

#Storing all base-pairs and correspondent probabilities in @species_pairs, each element is a key of hash %sp
while (<species_plot>){
	chomp;
	if (/ubox$/ && $_ !~ /\%/){
		@field = split (/\s/);
		$s = $field[0]."-".$field[1];
		$sp{$s} = $field[2];
		push (@species_pairs, "$s");
	}
}

$distance = 0;

#Find common base-pairings, and difference in probabilities to distance score
#Loop to work all base-pairs of first set
foreach $c(@consensus_pairs){
	$i = 0;

	#Loop to work all base-pairs of second set
	foreach $s(@species_pairs){
		#Condition: if base-pair is common, substract probabilities and add to distance score
		if($c eq $s){
			push @common, $c; #Create set of common pairs in @common

			$i = abs ($cons{$c} - $sp{$s});
			$distance += $i;
		} 
	}
}

#Find out unique base-pairs in set one, and add probabilites to distance score
foreach $c(@consensus_pairs){
	$marker = 0;
	$i = 0;

	foreach $el(@common){
		if($el eq $c){
			$marker = 1;
		}
	}

	unless($marker == 1){
		$i = $cons{$c};
		$distance += $i;
	}
}


#Find out unique base-pairs in set two, and add probabilites to distance score
foreach $s(@species_pairs){
	$marker = 0;
	$i = 0;

	foreach $el(@common){
		if($el eq $s){
			$marker = 1;
		}
	}

	unless($marker == 1){
		$i = $sp{$s};
		$distance += $i;
	}
}

$normalised_dist = ($distance/$alg_length)*100;

printf("%.1f", $normalised_dist); 
print "\n";

close consensus_plot;
close species_plot;


