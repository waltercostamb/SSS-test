#!/usr/bin/perl

#Script by Bia Walter

#This script transforms a normal FASTA format into a FASTA format in which there are only two lines per entry, one is the header and the other is the sequence.

#A new function was added in the twoline script to accept any kind of fasta header. Either the old ipput of the SSS-test: ">FILE_NAME\t|\tSPECIES", or any header that will be transformed to such a format, with the species being the first characters of the input FASTA (with a maximum of 10 characters).

#$perl twoline-fasta.pl alignment.fasta

use strict;
use Data::Dumper;

my $reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

my $i = 0;
my @curr_seq = "";
my @seq = "";

#Header formatting
#Get file name ID

my $pre_file_id;

#If the input file name has a slash, remove all before the slash 
if ($reading_file =~ /\//) {
	my @pre_file_id = split (/\//, $reading_file);
	$pre_file_id = $pre_file_id[-1];
} else {
	$pre_file_id = $reading_file;
}

my @pre_file_id2 = split (/\./, $pre_file_id);
my $file_id = $pre_file_id2[0];

#Read the input
while (<reading_file>){
	chomp;
	if (/^>/){

		my $header;

		#Header formatting
		my $header_content = $_;
		#Removing the '>'
		$header_content =~ s/^>//;

		#Check if it is old format, if so, maintain, if not, change to SSS-format
		if ($header_content =~ /(\S+)\s\|\s(\S+)$/) {
			$header = ">$header_content";		
		} else {
			$header_content =~ /^\.{0,15}/;
			my $species = $header_content;
			$header = ">$file_id\t|\t$species";
		}

		#Twoline assessment
		if ($i == 0){
			print "$header\n";
		#Twoline assessment
		} else {
			  print "\n$header\n";
		}
	#Twoline assessment
	} else {
		print $_;
		$i = 1;
	  }  
}

print "\n";

close reading_file;

