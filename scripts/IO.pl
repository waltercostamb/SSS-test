#!/usr/bin/perl - w

#Bia Walter
#Script takes a multi-FASTA file and prints each FASTA sequence in a separate file. FORMAT is also given by the user (example: fa or alg)
#Name of the output files: familyID-Species.fa: >familyID | Species > familyID-Species.FORMAT

#$perl IO.pl file.fa FORMAT

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";
$format = shift;

if($format eq ""){
	$format = "txt";
}

foreach (<reading_file>){
	chomp;
	if (/^>/){
		push @headers, "$_";          
	} else {
		push @sequences, "$_";          
	}
}

close reading_file;

foreach(@headers){
	if (/^>(\S+)\s\|\s(\S+)$/){
		$familyID = $1;
		$species = $2;


		$file = $familyID."-".$species.".".$format;

		open(DATA, '>>' , $file) or die "Não foi possível abrir o arquivo $file!\n";
		print DATA $_,"\n";
		print DATA $sequences[$i],"\n";
		close DATA;
	}
	$i++;
}


