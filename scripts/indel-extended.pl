#!/usr/bin/perl

#Bia Walter
#This script processes the pairwise alignment of two sequences, a sequence of interest and a consensus. It detects insertions or deletions in the species sequence in relation to the consensus and returns several files, each one containing the species sequence mutated with one indel. The indel is detected in the following manner: each row is compared and when both sequences disagree, one containing a gap and the other a base, an indel is detected. After the detection, a gap extension is accounted for. The returned files contain each an individual indel. The script also returns the total number of indels and their length.

#$perl indel-extended.pl $f4-$species.alifold $f4-$species.alg > $species-indel.tmp

use Data::Dumper;

my $alifold_file = shift;
my $species_file = shift;

open ("alifold_file", $alifold_file) || die "It was not possible to open file $alifold_file\n";
open ("species_file", $species_file) || die "It was not possible to open file $species_file\n";

#Keeping consensus sequence in array @cons_seq
$a = 0;
while (<alifold_file>){
	$a++;
	chomp;

	if ($a == 1){
		$_ =~ s/\_/\-/g;
		@cons_seq = split (//); 
	}
}

#Keeping species sequence in array @sp_seq
while (<species_file>){
	chomp;
	unless(/^>/){
		$_ =~ s/\_/\-/g;
		@sp_seq = split (//);
	}
}

$s = 0; #synonymous changes
$n = 0; #non-synonymous changes
$marker = 0; #$marker is zero by default, if it turns to 1 at least one non-synonymous change was detected
$n = 0; #counter of indels
@lengths = ""; #list of indel lengths

#Indel detection by base-to-base comparison
#Calculation of synonymous and non-synonymous changes: $s and $n
for ($i = 0; $i <= $#cons_seq; $i++){ #$i is the alignment position

	$detect_change = 0; #marker that detects change when 1. Necessary to detect two changes one following the other
	$marker = 0; #$marker is zero by default, if it turns to 1 at least one non-synonymous change was detected
	$gap_length = 0; #gap_length is set to zero by begin of every indel search
	@seq = @sp_seq; #to be returned mutated sequence is always set to begin equal to the species
	$indel = "";

	if ($cons_seq[$i] =~ /\-/ && $sp_seq[$i] !~ /\-/){ #Compare row by row in the pairwise alignment and look for insertion in species
		#Detected: insertion in species
		$marker = 1;	
		$indel = "insertion";	
			
		do{
			#Make mutated sequence with the gap found in the consensus
			@seq[$i] = $cons_seq[$i];
			$i++;
			$gap_length++;
		} until ($cons_seq[$i] !~ /\-/ || $sp_seq[$i] =~ /\-/);
	}

	if ($cons_seq[$i] !~ /\-/ && $sp_seq[$i] =~ /\-/){ #Compare row by row in the pairwise alignment and look for deletion in species
		#Detected: deletion in species
		$marker = 1;	
		$indel = "deletion";		
			
		do{
			#Make mutated sequence with the insertion found in the consensus
			@seq[$i] = $cons_seq[$i];
			$i++;
			$gap_length++;
		} until ($cons_seq[$i] =~ /\-/ || $sp_seq[$i] !~ /\-/);
	}

	#Print the mutated sequence in the form of an output file with name: mutated$n-$gap_length-$indel.fa
	if($marker == 1){
		$n++;
		my $arquivo = "mutated$n-$gap_length-$indel.fa";
		open(my $fh, '>', $arquivo) or die "It was not possible to open file '$arquivo' $!";
		print $fh ">mutated$n-$gap_length-$indel\n";
		push @lengths, $gap_length;		
		foreach $b(@seq){
			print $fh "$b";
		}
		print $fh "\n";
		close $fh;
		$i--;
	}
}

$list = join ' ', @lengths; 
print "$n\n$list\n";

close alifold_file;
close species_file;


