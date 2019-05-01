#!/usr/bin/perl -w

#Bia Walter

#This script gets as input a multi-FASTA file (input to sd-ss pipeline) and outputs all species in a list.

#$perl get-species.pl multi.fa 


$reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";


while (<reading_file>){
	chomp;
	if (/^>.+\s\|\s(.+)/){
		print $1, "\n";

	#Else function added according to change in script twoline-fasta.pl for header formatting
	} elsif (/^>/) {
		my $header_content = $_;
                #Removing the '>'
                $header_content =~ s/^>//;
                $header_content =~ /^\.{0,15}/;
                my $species = $header_content;
                print "$species\n";
	} 
}

close reading_file;
