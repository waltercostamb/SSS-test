#!/usr/bin/perl -w

#Bia Walter

#This script takes as inputs (i) tmp2 and (ii) structural distance files. It then sums all the individual structural impact of all changes of the species. 

#$perl median.pl sdss.final > median;

use Data::Dumper;

my $tmp2_file = shift;
open ("tmp2_file", $tmp2_file) || die "It was not possible to open file $tmp2_file\n";

my $header_detector = 0;

while (<tmp2_file>){
	chomp;
	unless($header_detector == 0){
		@rows = split (/\t/);

		#Keep distances in array
		push (@array, $rows[3]);
	}
	$header_detector++;
}

close tmp2_file;

print median(@array), "\n";

sub median
{
    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;

	#print Dumper @vals;	

    if($len%2) #odd?
    {
        return $vals[int($len/2)];
    }
    else #even
    {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}





