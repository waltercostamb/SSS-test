#!/usr/bin/perl - w

#Bia Walter
#Script takes a FASTA sequence as input and outputs an evolved sequence, containing one gap. The user chooses the gap start base, the gap length and a number that corresponds to the ID of the evolved sequence.
#Input has to be in TWOLINE FORMAT

#$perl evolve.pl input.fa START LENGTH ID_NUMBER

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";
$start = shift;
$start = $start - 1;
$length = shift;

$id_number = shift;

foreach (<reading_file>){
	chomp;
	if (/^>/){
		print ">evolved$id_number";      
    
	} else {
		@seq = split (//);

		$x = 0;
		foreach $base(@seq){
			unless ($x == $start){
				print "$seq[$x]";
				$x++;
			} else {
				for ($i = 1; $i <= $length; $i++){
					print "-";
					$x++;
				}
			}
		}
	}
	print "\n";
}

close reading_file;

