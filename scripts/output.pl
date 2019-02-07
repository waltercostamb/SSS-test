#!/usr/bin/perl -w

#Bia Walter
#This script gets as input k.txt, containing non_syn as well as syn densities, along with sdss scores and prints it in the final format of the sd-ss pipeline.

#perl ../scripts/output.pl k.txt sdss.final > alignment_ID.sdss

my $k_file = shift;
my $sdss_file = shift;

open ("k_file", $k_file) || die "It was not possible to open file $k_file\n";
open ("sdss_file", $sdss_file) || die "It was not possible to open file $sdss_file\n";

while (<sdss_file>){
	chomp;
	push @sdss, $_;
}

while (<k_file>){
	chomp;
	@line = split (/\s/);

	foreach $el(@sdss){
		if ($el =~ /$line[0]/){
			@sp_sdss = split (/\t/, $el);

			print "$line[0]\t";
			printf ("%.2f",$line[1]);
			print "\t";
			printf ("%.2f",$line[2]);
			print "\t$line[3]\t$line[4]\t$sp_sdss[0]\t$sp_sdss[3]\t$sp_sdss[4]\n";
		}
	}

}


close k_file;
close sdss_file;

