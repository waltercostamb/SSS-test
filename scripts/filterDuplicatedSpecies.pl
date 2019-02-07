#!/usr/bin/perl

#Maria Beatriz Walter Costa
#To get the usage, run the script with the help option: perl filterDuplicatedSpecies.pl --help

use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);

my $reading_file; #input
my $help;

GetOptions(
        'input=s' => \$reading_file,
        'help' => \$help,
) or die "Usage: $0 --input SUBSTRUCTURE-ORTHO\n";

if ($help){
        print "Filter of multiple sequences of the same species\n";
        print "Maria Beatriz Walter Costa (bia\@bioinf.uni-leipzig.de)\n\n";
	print "This script receives a FASTA file with specific header format containing substructure classification. It verifies if it contains only one representative per species. In cases with multiple representatives for the same species, it chooses only one representative per species. The representative is the one that has the closest sequence length to the group median (excluding the probe species).\n\n";
        print "Input is the output of script assign-orthologous.pl\n";
        print "Usage: $0 --input SUBSTRUCTURE-ORTHO\n\n";
        print "--input: SUBSTRUCTURE-ORTHO \n";
        die "\n";
}

open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

my $marker = 0;
my @line;
my $sub;
my $species;
my %subMap;
my %multipleChoices;
my $i = 1;

#Using multi-dimensional hashes (source: Perl Maven) to store the substructure data, followed by mutiples occurances detection and output on the next blocks
while (<reading_file>){
	chomp;
	#Get sub and species
	@line = split /\s+/;
	$sub = $line[5];	
	$species = $line[7];

	#Store data on multi-dimensional hash %subMap
	unless (exists $subMap{$sub}{$species}){
		$subMap{$sub}{$species}{'header'} = $_;
		$_ = <reading_file>;
		chomp;
		$subMap{$sub}{$species}{'sequence'} = $_;
	#Store only the extra occurances on hash %multipleChoices (notice that the species was already listed in %subMap)
	} else {
		$i++;
		#Marker ir activated only when multiples occurances are detected
		$marker = 1;
		$multipleChoices{$sub}{"$species-$i"}{'header'} = $_;
		$_ = <reading_file>;
		chomp;
		$multipleChoices{$sub}{"$species-$i"}{'sequence'} = $_;	
	}
}

my @tmp;
my $probe_length;
my $length_tmp;
my $main_length;
my $probe_length;
my $medien_length_family;

#After storing the data, detect if marker was activated by multiple occurances
#If marker was not activated ($marker == 0), this block is skipped and blocks are printed directly
#It marker was activated ($marker == 1), there are multiples, so enter loop, choose best option for species and store it in %subMap, which will on the next block be printed
if ($marker == 1){
	#Working each sub block of multipleChoices
	foreach $sub (sort keys %multipleChoices){
		#Accessing all species listed on current block
		foreach my $pre_species (sort keys %{$multipleChoices{$sub}}){
			@tmp = split /-/, $pre_species;
			$species = $tmp[0];
			
			#Following for-loop works all multiple entries of the same species and choose the best one, substituting it if necessary on %subMap
			my $total_sub_entries = keys %{$multipleChoices{$sub}};
			my $x;
			for ($x = 2; $x < ($total_sub_entries + 2); $x++) {

				#Calculate the length of the sequence on probe stored on %multipleChoices
				$probe_length = length $multipleChoices{$sub}{"$species-$x"}{'sequence'};
				#Calculate the length of the sequence already stored on %subMap for comparison
				$main_length = length $subMap{$sub}{$species}{'sequence'};

				#Next block calculates the medien sequence length of the current sub (excluding the species under probing)
				my $i = 0;
				my $medien_length_tmp = 0;
				foreach my $species_tmp (sort keys %{$subMap{$sub}}){
					#Unless is used to exclude the probe species from the medien length calculation
					unless ($species_tmp eq $species){
						$medien_length_tmp += length $subMap{$sub}{$species_tmp}{'sequence'};
						$i++;
					}
				}

				#Special case noted and corrected on 28/03/18
				#If there is only one species present on the substructure, the block above would fail, because $i would be zero. To correct this, the block below directly assigns $i to 1 and $medien_length_tmp to the length of the only species present on the substructure in such special cases
				my $number_species_on_sub = keys %{$subMap{$sub}};
				if ($number_species_on_sub == 1) {
					$i = 1;
					$medien_length_tmp = length $subMap{$sub}{$species}{'sequence'}
				}

				#Calculate medien length
				$medien_length_family = $medien_length_tmp/$i;
				#Calculate absolute difference between already stored sequence and medien
				my $main_diff = $main_length - $medien_length_family;
				#Calculate absolute difference between probe sequence and medien
				my $probe_diff = $probe_length - $medien_length_family;

				#If probe absolute difference is smaller, that means it is better to represent the species in the family, therefore, substitute header and sequence in %subMain
				if (abs ($probe_diff) < abs($main_diff)) {
					#Substitute main sequence for this species
					$subMap{$sub}{$species}{'header'} = $multipleChoices{$sub}{"$species-$x"}{'header'};
					$subMap{$sub}{$species}{'sequence'} = $multipleChoices{$sub}{"$species-$x"}{'sequence'};
				}
			}
		}
	}
}

#Print header and sequences of the unique representatives of each species per sub
foreach $sub (sort keys %subMap){
	foreach $species (sort keys %{$subMap{$sub}}){
		print "$subMap{$sub}{$species}{'header'}\n";
		print "$subMap{$sub}{$species}{'sequence'}\n";
	}
}

close reading_file;

