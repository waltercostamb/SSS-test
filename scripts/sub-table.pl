#!/usr/bin/perl

#Script by Bia Walter

#This script gets as input a multi-fasta file. The header must contain the species, species positions and local structure blocks. 
#It creates as an output a table with the substructures and the species and alignment positions.

#USAGE:
#$perl sub-table.pl substructures-ortho.fasta

use Data::Dumper;

#Open input
my $reading_file = shift;
open ("reading_file", $reading_file) || die "It was not possible to open file $reading_file\n";

#Store all headers and get the species list
while (<reading_file>){
	chomp;
	if (/^>/){
		push @headers, "$_";
		if(/(\w+)$/){
      			$species = $1;
			unless ( grep( /^$species$/, @pre_list_species )  ) {
				push(@pre_list_species, $species);
			}
		}
	} 
}

close reading_file;

#Sort the species list
@list_species = sort @pre_list_species;

#Store into a hash tree all local blocks ("subs") and the species within the blocks and the species positions
foreach(@headers){
	@line = split /\s+/;
	$sp_position = $line[2];
	$sub_block = $line[5];
	$species = $line[7];

	$blocks2species{$sub_block}{$species} = $sp_position;
}

#print header of local structure table
print "Block";
foreach (@list_species){
	print "\t$_";
}
print "\n";

#Print for each line, one sub, with all species occurances
#Whenever a species has no ortholog in the "sub", a "-" sign is printed
foreach $sub (sort { substr($a, 3) <=> substr ($b, 3)} keys %blocks2species){
	print "$sub";
	foreach $species(@list_species){
		if (exists $blocks2species{$sub} && exists $blocks2species{$sub}{$species}){
			print "\t$blocks2species{$sub}{$species}";
		} else {
			print "\t-";
		}
	}
	print "\n";
}



