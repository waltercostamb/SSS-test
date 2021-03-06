#!/usr/bin/perl

#Maria Beatriz Walter Costa

#To get the usage, run the script with the help option: perl check-muscle-output.pl --help

use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);

my $muscle_file;
my $fasta_file;
my $help;

GetOptions(
        'muscle_output=s' => \$muscle_file,
	'fasta_file=s' => \$fasta_file,
        'help' => \$help,
) or die "Usage: $0 --muscle_output MUSCLE_OUTPUT-FASTA --fasta_file ORIGINAL-INPUT-FASTA\n";

if ($help){
        print "Evaluation of muscle output\n";
        print "Maria Beatriz Walter Costa (bia\@bioinf.uni-leipzig.de)\n\n";
        print "This script checks output multi-FASTA files generated by muscle. It checks if the aligned sequences without gaps are the same length of the respective un-aligned sequences. If they are the same length, the scripts outputs nothing. If the script finds any sequence to be at different lengths, it reports an error message, which will be later on received by the local pipeline, which will be aborted.\n\n";
	print "IMPORTANT: inputs must be twoline format!";
	print "Usage: $0 --muscle_output MUSCLE_OUTPUT-FASTA --fasta_file ORIGINAL-INPUT-FASTA\n";
        print "--muscle_output: is a file from muscle\n";
        print "--fasta_file: is the original input to muscle, an un-aligned file\n";
        die "\n";
}

open ("muscle_file", $muscle_file) || die "It was not possible to open file $muscle_file\n";
open ("fasta_file", $fasta_file) || die "It was not possible to open file $fasta_file\n";

my %fastaData;
my $species;
my $length;
my $header;
my $sequence;

#Read fasta_file
while (<fasta_file>) {
	chomp;

	#Access header and get correspondent species
	if (/^>/){
		$header = $_;
		/\s(\w+)$/;
		$species = $1;

		#Get sequence length 
		$sequence = <fasta_file>;
		chomp ($sequence);
		$length = length ($sequence);

		#Store species as key of hash #fastaData and sequence lentgh as value 
		$fastaData{$species} = $length;
	}
} 

my %muscleData;

#Read muscle_file
while (<muscle_file>) {
	chomp;

	#Access header and get correspondent species
	if (/^>/){
		$header = $_;
		/\s(\w+)$/;
		$species = $1;

		#Get sequence length 
		$sequence = <muscle_file>;
		chomp ($sequence);
		$sequence =~ s/-//g;
		$length = length ($sequence);

		#Store species as key of hash #fastaData and sequence lentgh as value 
		$muscleData{$species} = $length;
	}
}

#print Dumper %fastaData;
#print Dumper %muscleData;

my $marker = 0;

#Compare sequence lengths of both files
foreach my $speciesFasta (sort keys %fastaData) {
	foreach my $speciesMuscle (sort keys %muscleData) {
		if ($speciesFasta eq $speciesMuscle) {

			#If lengths are different, print a warning!
			#Remember, the keys of the hashes are the lengths
			if ($fastaData{$speciesFasta} ne $muscleData{$speciesMuscle}) {

				my $file = "warning-muscle.txt";
                		open(DATA, '>>' , $file) or die "Não foi possível abrir o arquivo $file!\n";

				#$marker serves for the following message to be printed only once
				if ($marker == 0){
					print "ERROR: muscle failed to properly align the sequences!\n";
					print DATA "ERROR: muscle failed to properly align the sequences!\n";
					close DATA;
				}

				print "Sequence $speciesFasta has different length in muscle's input and output\n";
				$marker = 1;
			}
		}
	}
}

close muscle_file;
close fasta_file;

