#!/usr/bin/bash

#To get the usage just run the script with no arguments.

export LD_LIBRARY_PATH=$HOME/libs

if [ $# == 0 ] ; then
    echo "Local structure pipeline: finds conserved local structures"
    echo "Maria Beatriz Walter Costa (bia@bioinf.uni-leipzig.de)"
    echo ""
    echo "This script processes a multi-FASTA file of long non-coding RNAs. It returns multi-FASTA files, each containing a local structure family. These can afterwards be submitted to the SSS-test. Local structures are found based on RNALfold reports. The most energetically stable ones are chosen, in a manner that they do not overlap each other. Afterwards they are classified as orthologous local structures based on alignment positions. To be considered ortholgous, they must overlap in at least 70%."
    echo ""
    echo "Usage: local.sh -i input -f format -o output_folder"
    echo ""
    echo "Input file must be in the SSS format and in a separate folder, in the same formatting as in the SSS-test."
    echo ""
    echo "-i input file (in a separate folder, e. g. dir/file.fasta)"
    echo "-f format (fasta or alignes)"
    echo "-o output folder"
    echo ""
    exit 1;
fi

while getopts ":i:f:o:" opt; do
    case $opt in
      "i") input="$OPTARG";;
      "f") FORMAT="$OPTARG";;
      "o") output_folder="$OPTARG";;
    esac
done

if [[ ! -s $input ]]; then
	echo "It was not possible to open file $1"
	exit
fi

if [[ $input =~ "-" ]]; then
	echo "Input file must be in SSS format, and can not contain '-'"
	echo "Example allowed names: 'input.fa', 'input.alg', 'input_100.fa', 'input_100.alg'"
	exit
fi

folder=${input%/*} 
filename=${input##*/} 
file=${filename%.*} 

script_dir="../${program_folder}scripts"

NUM_OF_SEQ=`cat $input | grep '>' | wc -l`
#Testing if there is a minimum number of species in the input so that the pipeline is applicable
if [[ $NUM_OF_SEQ < 2 ]]
   then
	echo "Warning###"
	echo "$input has only $NUM_OF_SEQ species, which is not enough information to assign orthologous families local structures";
	echo "You should have at least 2 species to assign orthologous local structures, and at least 3 to calculate SSS scores";
	exit
fi

#Making an output directory if it doesn't exist
if [[ ! -d $output_folder ]]; then
	mkdir $output_folder
fi

if [[ -d tmp_${file}_local ]]; then
	rm -r tmp_${file}_local
fi

mkdir tmp_${file}_local
cd tmp_${file}_local

if [ $FORMAT == "fasta" ]; then 
	echo 'Aligning sequences'
	muscle -in ../$input > $file.alg;
	echo ''

	perl $script_dir/twoline-fasta.pl ../$input > $file-twoline; 
	perl $script_dir/twoline-fasta.pl $file.alg > $file.alg-twoline; 

	rm $file.alg
	mv $file.alg-twoline $file.alg
	mv $file-twoline $file.fa
fi

if [ $FORMAT == "aligned" ]; then 
	echo 'Getting raw multi-FASTA'
	perl $script_dir/twoline-fasta.pl ../$input > $file.alg-twoline; 
	mv $file.alg-twoline $file.alg

	perl $script_dir/nogap.pl $file.alg > $file.fa;
fi

echo 'Creating individual FASTA files'
perl $script_dir/IO.pl $file.fa fa;
perl $script_dir/get-species.pl $file.alg > species.tmp;

if [ $FORMAT == "fasta" ]; then 

	echo 'Checking muscle output'
	perl $script_dir/check-muscle-output.pl --muscle_output $file.alg --fasta_file $file.fa

	if [[ -f "warning-muscle.txt" ]]; then
		rm warning-muscle.txt
		echo ""
		echo "Please, align the $input with another tool and submit it to local.sh in already aligned mode"	
		rm $file.alg *.fa species.tmp
		cd ../
		rmdir tmp_${file}_local
		rmdir $output_folder
		exit
	fi
fi

#Local structure search with RNALfold
echo "Looking for local structures with RNALfold..."

while read species
   do
	RNALfold -z 2 < $file-$species.fa > $file-$species.localfold;

	#Correction of RNALfold format
	awk '{if(length($2)<=2){print $1 "\t("$3"\t"$4"\t"$5"\t"$6} else {print $0}}' $file-$species.localfold > $file-$species.localfold.formated;
	sort -k3 -n $file-$species.localfold.formated > $file-$species.localfold.formated.sorted;
	perl $script_dir/best-substructures.pl $file-$species.localfold.formated.sorted $species > $file-$species.best;
	sed 's/  */\t/g' $file-$species.best > $file-$species.structures

	cat $file-$species.structures >> $file.local

	
	rm $file-$species.localfold $file-$species.localfold.formated $file-$species.localfold.formated.sorted $file-$species.best $file-$species.structures $file-$species.fa
done < species.tmp

rm species.tmp

echo "Extracting local structure sequences"
perl $script_dir/extract-subsequences.pl $file.local $file.alg > substructures.fa;

echo "Assigning orthologous local sequence families"
perl $script_dir/assign-orthologous.pl substructures.fa > substructures-ortho.fa

#Filter script to verify eventual duplicates of the same species belonging to the same substructure block, which can in rare cases be calculated by assign-orthologous.pl
echo "Choice of best representative of eventual cases of multiple sequences of same species"
perl $script_dir/filterDuplicatedSpecies.pl --input substructures-ortho.fa > substructures-ortho-filtered.fa

echo "Creating table of local structure alignment positions"
perl $script_dir/sub-table.pl substructures-ortho-filtered.fa > ../$output_folder/$file-local_positions.txt  

echo "Creating local sequence family files"
perl $script_dir/local-files.pl substructures-ortho-filtered.fa

#Moving files of local sequences to the input folder
mv *fasta ../$output_folder/.

rm substructures.fa substructures-ortho.fa $file.alg $file.local $file.fa substructures-ortho-filtered.fa

cd ../
rmdir tmp_${file}_local


