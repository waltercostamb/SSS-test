#!/usr/bin/perl -w

#Bia Walter

#This script gets as input the RNAsnp report and outputs all possible structure disruptive mutations. Output will be "-" for RNAsnp null report.

#$perl analyse-RNAsnp.pl consensus.rnasnp

#Output format:                             Base1 - d_max  - pvalue1 - pvalue2 , Base2-d_max-pvalue1-pvalue2,Base3-d_max-pvalue1-pvalue2
#                   RNAsnp-report-bases	    1G    - 0.0652 - 0.0207  - 0.0521  , 1C-0.0003-0.8569-0.8606,1A-0.0003-0.7959-0.8388

my $snp_file = shift;
open ("snp_file", $snp_file) || die "It was not possible to open file $snp_file\n";

print "RNAsnp-report-bases\t";

$x = 0;
$flag = 0;

while (<snp_file>){
	chomp;

	if (/^SNP/){
		$flag = 1;
		next;
	}

	if($flag == 1){
		@line = split (/\t/);

		if ($line[0] =~ /(\d+)(\w)/){
			$position = $1;
			$base = $2;
		}

		if($x == 0) {
			print "$position$base-$line[9]-$line[6]-$line[10]";
			$x = 1;
		} else {
			print ",$position$base-$line[9]-$line[6]-$line[10]";
		}
	}
}

if($x == 1){
	print "\n";
} else {
	print "-\n";
}

close snp_file;

