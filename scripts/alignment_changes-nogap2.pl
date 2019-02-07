#!/usr/bin/perl -w

#Bia Walter

#This script receives aligned sequences in FASTA format as input and analyses the alignment in relation to species specific changes. The output is a sorted score of changes for each species. All gaps are excluded from this analysis. A change is only reported as species specific if there is a dominant base present in the alignment. This dominant base has to be present above a certain threshold, defined by the user.

#The threshold needs to be between 0 and 100

#$perl alignment_changes-nogap.pl multifasta.aln THRESHOLD

use strict;
use Data::Dumper;

#Input file should be FASTA format of aligned sequences! 
my $reading_file = shift;
my $pre_threshold = shift;
my $threshold = $pre_threshold/100;

open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

my $get_sequences = 0;
my $n_sequences = -1;

my @species_id = ();
my @species_seq = ();


#Store all species ID's into @species_id (as a list) and all species sequences into @species_seq in upper case (as a list)
while (<reading_file>){
	chomp;

	#If FASTA header
	if (/^>(.*)/){

		#Count the number of sequences of the "reading_file"
                $n_sequences++; 
		$species_id[$n_sequences] = $1;
		$species_seq[$n_sequences] = '';
	}
	#If sequence, concatenates all broken lines into a big string
	else {
	        $species_seq[$n_sequences] .= uc $_;
	}	                     
}

close reading_file;

###########################
#    Code flow control    #
# print "@species_id\n";  #
# print "@species_seq\n"; #
###########################

#20/10/2015 - Added an extra code block to get the length of each species sequence @species_len AND get the sequence of the species without the gaps in @species_seq_nogaps
my $number = 0;
my @alg_seq;
my $real_seq = "";
my $bs;
my $len;
my @species_len;
my @species_seq_nogaps;
foreach(@species_seq){
	@alg_seq = split (//, $species_seq[$number]);
	foreach $bs(@alg_seq){
		unless ($bs =~ /-/){
			$real_seq = $real_seq.$bs;	
		}
	}
	$len = length $real_seq;
	push @species_seq_nogaps, $real_seq;
	push @species_len, $len;
	$real_seq = "";
	$number++;
}

#####################################
#    Code flow control              #
# print Dumper @species_id;         #
# print Dumper @species_seq;        #
# print Dumper @species_len;        #
# print Dumper @species_seq_nogaps; #  
#####################################

#This last sum of 1 is necessary to correctly adjust the counting of the number of sequences of the "reading_file"
$n_sequences++;

#############################
#  Adjusting of threshold   #
# basing on species number  #
#############################

if ($n_sequences == 3){
	if($threshold > 0.65){
		$threshold = 0.65;
	}
} elsif ($n_sequences == 2 || $n_sequences == 1) {
	print "not enough information to assess species specificity!\tNumber of species\t$n_sequences\t$reading_file\n";
	exit;
}

my %position_counting;
my @score_species = (0) x $n_sequences;
my $number_columns = length $species_seq[0];

my $x;
my $x_corrected;
my $specified_positions = "";
my $i;
my $letter;

#Work on every column of the alignment to get the mutation positions
for ($x = 0; $x< $number_columns; $x++){
	
	%position_counting = ();

	#Count the number of times each base appeared in the current column of the alignment, and store all counting into the hash %position_counting
	for ($i = 0; $i < $n_sequences; $i++){
		$letter = substr ($species_seq[$i], $x, 1);
		$position_counting{$letter}++;
	}

	#####################################
	#         Code flow control         #
	#                                   #
	#print Dumper(\%position_counting); #
	#####################################

	my $max = 0;
	my $key;
	my $max_base;

	#Substitutes the values of the hash %position_counting by the frequency of appearence of the base in this column
	foreach $key(keys (%position_counting)){
		$position_counting{$key} = $position_counting{$key}/$n_sequences;
		
		#Set the most frequent base to string $max_base and its frequency to $max
		if ($position_counting{$key} > $max) {
			$max = $position_counting{$key};
			$max_base = $key;
		}
	}

	#####################################
	#         Code flow control         #
	#                                   #
	#print Dumper(\%position_counting); #
	#####################################

        ##############################################################################
	#                                 26/01/15                                   #
	#  unless condition excludes gaps from being considered as a dominant base   #
	##############################################################################
	unless ($max_base eq "-"){
		#Checks if the most frequent base in this column is more frequent than the user-given $threshold, or in other words, check if there is a dominant base 
		if ($max >= $threshold){
		
			#Works on every species (or every line) for this column
			for ($i = 0; $i < $n_sequences; $i++){

				#$letter is the current base of comparison
				$letter = substr ($species_seq[$i], $x, 1);

				#Increases mutation count ($score_species) if the species' base is in the considered alphabet and is different from the dominat base:
				# 26/01/2015 - changed the alphabet to exclude gaps from the score calculation
				if ($letter =~ /[ACGTU]/){
					unless ($letter eq $max_base){
						$score_species[$i]++; #score calculation!

						#18/11/2014
						#$x_corrected is the position of the species specific base
						$x_corrected = $x + 1;

						#This if structure creates a complete list containing all species specific changes of the alignment as in the following example: "-Human:5-Macaque:10-Pan:11-" 
						#A very important remark: this list is based on the alignment position of the row, and NOT in the real sequence position of the species!
						#Script correction 26/01/2015: pattern matching was incomplete						
						if($specified_positions eq ""){
							if ($species_id[$i] =~ /\s\|\s(.+)$/){			
								$specified_positions = $1.":".$x_corrected.":"."$letter";
							}
						} else {
						  	  if ($species_id[$i] =~ /\s\|\s(.+)$/){			
							  	$specified_positions = $specified_positions."-".$1.":".$x_corrected.":"."$letter";
							  }
						  }
					}
				}
			}
		}
	}
}

print "species_no\t$n_sequences\n";
print "alignment_row_no\t$number_columns\n";
print "\n";

print "identifier\tspecies\tscore\tseq-length\tmutations_species_position\tmutations_alignment_position\n";

#20/10/2015 $specified_positions has the changes in the alignment positions, I added this code block to get the real sequence positions
###################################
#        Code flow control        #
#                                 #
#print $specified_positions,"\n"; #
###################################

#20/10/2015: split on the string of $specified_positions, to array @specified_positions, with each mutation as an element (@specified_positions = (Human:1, Orangutan:3, Chimp:6, Human:10))
my  @specified_positions;
@specified_positions = split (/-/, $specified_positions);

#20/10/2015
#Getting dominant species
my $dominant_species;
my @species_seq_current;
my $t;
my $r;
my @r_el;
my $mutations = "";
my $mutations_alignment = "";
my $rnafold_header;
my $sp_c;
my %correspondent_pos;

#21/10/2015: Bug fixing: hash %order created to sort the scores afterwards by order. Will be printed after the following for loop
my %order;

for ($i = 0; $i < $n_sequences; $i++){

	@species_seq_current = split (//, $species_seq[$i]);
	
	#04/08/2016: hash %correspondent_pos gets the correspondence between the alignment and the species positions of the current species
	my $aln_pos = 1;
	my $s;
	my $lim = scalar @species_seq_current;
	my $sp_pos = 1;
	for ($s = 0; $s < $lim; $s++){
		if($species_seq_current[$s] =~ /[ACGTU]/){
			$correspondent_pos{$aln_pos} = $sp_pos;
			$sp_pos++;
		}
		$aln_pos++;
	}
	
	#20/10/2015: Gets the mutations of the current species in the real sequence positions, instead of the alignment positions (as before in string $specified_positions)
	foreach $r(@specified_positions){
		@r_el = split (/:/, $r);
		if ($species_id[$i] =~ /$r_el[0]$/){#02/11/2015: Added anchor $ at the end of the pattern, so it matches only once (more precise) 
			$mutations = $mutations.$correspondent_pos{$r_el[1]}."$r_el[2]".",";
			$mutations_alignment = $mutations_alignment.$r_el[1]."$r_el[2]".",";#22/01/2016: Added mutation positions according to the alignment
		}
	}

	chop $mutations; 
	chop $mutations_alignment;
 
	if ($species_id[$i] =~ /(\S+)\s\|\s(\S+)/){#02/11/2015: Adaptation of reg exp, to make it more comprehensive!
		$rnafold_header = $1;
		$sp_c = $2;
	}

	#21/10/2015: This small block will store all my reports in hash %order, which will at the end be sorted and finally printed
	if ($mutations ne ""){
		$order{"$rnafold_header\t$sp_c\t$score_species[$i]\t$species_len[$i]\t$mutations\t$mutations_alignment\n"} = $score_species[$i];
	} else {
		$order{"$rnafold_header\t$sp_c\t$score_species[$i]\t$species_len[$i]\t-\t-\n"} = $score_species[$i];
	}
	
	%correspondent_pos = ();
	$mutations = "";
	$mutations_alignment = "";
}

#21/10/2015: Printing the reports in order of scores
my $score;
foreach $score (sort {$order{$b} <=> $order{$a}} keys %order){
	print $score;
}




