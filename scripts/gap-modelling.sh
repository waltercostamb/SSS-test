#!/usr/bin/bash

#Bia Walter

#To get the usage just run the script with no arguments.

if [ $# == 0 ] ; then
    echo "Gap modelling evolution"
    echo "Maria Beatriz Walter Costa (bia@bioinf.uni-leipzig.de)"
    echo ""
    echo "This script models the evolution of an input sequence to contain gaps in varying positions. It starts with an ancestral sequence and evolves it to contain a gap of user-specified length. The sequence is folded with and without the constraint of the ancestral structure. Afterwards, the structural distance between the un-constrained and constrained structures is calculated with RNAforester. This process is repeated so that the gap is inserted in every position of the sequence, in a sliding window approach, from the first to the last base. The output is a summary report containing the impact information of the gap." 
    echo ""
    echo "Usage: gap-modelling.sh -f input_fasta -l gap_length -c familyID -d script_dir"
    echo "-f fasta format input file"
    echo "-l gap length for the modelling"
    echo "-c familyID (maybe familyID-species?)"
    echo "-d directory where the scripts for this pipeline are located (maybe ~bia/Documents/Lib-SSS-test/scripts/?)"
    echo ""
    exit 1;
fi

while getopts ":f:l:c:d:" opt; do
    case $opt in
      "f") fasta_sequence="$OPTARG";;
      "l") gap_length="$OPTARG";;
      "c") familyID="$OPTARG";;
      "d") script_dir="../$OPTARG";;
    esac
done

mkdir gapEvolution$gap_length-$familyID
cd gapEvolution$gap_length-$familyID

RNAfold -p -d2 --noLP < ../$fasta_sequence > fasta_sequence_rnafold.output

echo ">ancestral" >> ancestral.fa;
tail -n1 ../$fasta_sequence >> ancestral.fa; 

perl $script_dir/get-structure.pl fasta_sequence_rnafold.output > ancestral_structure.txt;

grep -v ">" ../$fasta_sequence > tmp
size=$(wc -c <"tmp")
size="$(($size-1))"
end="$(($size-$gap_length+1))"
rm tmp

echo "Gap modelling simulations..."
echo "Iterating over bases: 1 - $end"
echo "RNA_length gap_start gap_length structural_distance" > ../$familyID-$gap_length.indel

for start in `seq 1 $end`;
   do	
	perl $script_dir/evolve.pl ancestral.fa $start $gap_length $start > evolved$start.fa;

	echo ">evolved$start-constrained" > evolved$start-constrained.fa
	grep -v ">" evolved$start.fa >> evolved$start-constrained.fa

	cat evolved$start-constrained.fa > evolved$start-constrained.vienna
	cat ancestral_structure.txt >> evolved$start-constrained.vienna
	
	RNAfold -p -d2 --noLP -C --canonicalBPonly < evolved$start-constrained.vienna > evolved$start-constrained.out 2>/dev/null;
	#2>/dev/null means send any warning messages to /dev/null (to avoid RNAfold warnings of "removing non-canonical base pair from constraint") 	
	relplot.pl -p evolved${start}-constrained_ss.ps evolved${start}-constrained_dp.ps > evolved${start}-constrained_rss.ps;

	echo ">evolved$start-noconstraint" > evolved$start-noconstraint.fa
	grep -v ">" evolved$start.fa >> evolved$start-noconstraint.fa

	RNAfold -p -d2 --noLP < evolved$start-noconstraint.fa > evolved$start-noconstraint.out; 
	relplot.pl -p evolved$start-noconstraint_ss.ps evolved$start-noconstraint_dp.ps > evolved$start-noconstraint_rss.ps

	perl $script_dir/get-structure.pl evolved$start-constrained.out > evolved$start-constrained.txt;
	perl $script_dir/get-structure.pl evolved$start-noconstraint.out > evolved$start-noconstraint.txt;

	cat evolved$start-constrained.fa evolved$start-constrained.txt > constraint.vienna
	cat evolved$start-noconstraint.fa evolved$start-noconstraint.txt > noconstraint.vienna

	cat constraint.vienna noconstraint.vienna > comparator.txt

	#RNAforester makes an alignment of the structures and checks similarities/divergence, in the same fashion as CLUSTALW does for a sequence alignment, but taking the structure also into account
	RNAforester -d < comparator.txt > output_forester.tmp

	#When there is a problem in the input of RNAforester (e. g. full of gaps), it crashes and returns an error message. The output is then not calculated anymore, when this happens, a bash variable $? returns 1, and by detecting this, the pipeline knows there was an error in RNAforester and the sss calculation is terminated 
        #Example of error message from RNAforester: Error: Maximum array size of 2GB exceeded due to large input data. Calculation terminated.  
        if [ $? -eq 1  ];
           then
        	echo ""
                echo "ERROR: RNAforester encountered a problem in the input data and the sss scores can not be calculated for this family."
                echo ""
                cd ..
                rm -fr tmp_$familyID
                exit
        fi

	perl $script_dir/format-output.pl output_forester.tmp $size $start $gap_length >> ../$familyID-$gap_length.indel
	
	rm evolved$start.fa evolved$start-constrained.out evolved${start}-constrained_ss.ps evolved${start}-constrained_dp.ps evolved${start}-constrained_rss.ps evolved$start-noconstraint.fa evolved$start-noconstraint.out evolved$start-noconstraint_ss.ps evolved$start-noconstraint_dp.ps evolved$start-noconstraint_rss.ps evolved$start-noconstraint.txt comparator.txt constraint.vienna noconstraint.vienna evolved$start-constrained.fa evolved$start-constrained.vienna evolved$start-constrained.txt output_forester.tmp

done

rm ancestral.fa ancestral_structure.txt fasta_sequence_rnafold.output *.ps
cd ../
rmdir gapEvolution$gap_length-$familyID

