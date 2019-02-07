#!/usr/bin/perl

#Script by Bia Walter

#This script transforms a normal FASTA format into a FASTA format in which there are only two lines per entry, one is the header and the other is the sequence.

#$perl twoline-fasta.pl alignment.fasta

use strict;
use Data::Dumper;

my $reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

my $i = 0;
my @curr_seq = "";
my @seq = "";

while (<reading_file>){
	chomp;
	if (/^>/){
		if ($i == 0){
			print "$_\n";
		} else {
			  print "\n$_\n";
		  }
	} else {
		print $_;
		$i = 1;
	  }  
}

print "\n";

close reading_file;

