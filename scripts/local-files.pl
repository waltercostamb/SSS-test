#!/usr/bin/perl - w

#Bia Walter
#Script for taking a FASTA file already classified for local-structures and printing each local-structure in a separate file.

#$perl local-files.pl classified.fa

use Data::Dumper;

$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

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
	if(/>(.*)/){
		@fasta_ID = split (/\s+/, $1);
		$name = $fasta_ID[0]."_".$fasta_ID[5];
	}	

	$file = "$name".".fasta";
	open(DATA, '>>' , $file) or die "Não foi possível abrir o arquivo $file!\n";
	print DATA ">$fasta_ID[0]_$fasta_ID[5]\t|\t$fasta_ID[7]\n";
	print DATA $sequences[$i],"\n";
	close DATA;
	$i++;
}

close reading_file;
