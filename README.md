# SSS-test

Selection on the Secondary Structure-test: a test that detects positive and negative selection from a set of orthologs, either small or long ncRNAs.

This repository contains the SSS-test and the local pipeline designed to calculate local blocks from a multi-FASTA file or lncRNA orthologs.

The programs were designed for Unix-based operational systems, so you can use them with Linux or MacOS. For Windows systems you need either specific compilers or a Virtual Machine in addition. To obtain the repository in a Unix machine and use it locally, you can either download the repository directly from the GITHub webpage, or you can clone the repository in the terminal.  

__***News***__  

13.08.2021: Improved tutorial in README file  
11.08.2021: Added caution message to Pre-Usage about "Statistics::R"  
17.02.2021: Removed line from SSS-test: export $PATH of RNAsnp  
23.11.2020: The names of the tools were changed from 'SSS.sh' to 'SSS-test' and 'local.sh' to 'local-structure-pipeline'.  
01.05.2019: Requirements for the FASTA header of the input file were simplified.  

__***Cloning the repository on your UNIX machine***__  

	git clone https://github.com/waltercostamb/SSS-test   

__***Requirements***__

Both the SSS-test and local pipeline require additional software, which must be installed previously. To install them, refer to each appropriate link.

Required software: 

	- RNAsnp: http://rth.dk/resources/rnasnp/software  
	- muscle aligner: http://www.drive5.com/muscle  
	- Vienna RNA package: https://www.tbi.univie.ac.at/RNA/#download  
	- Bio::AlignIO from cpan: https://metacpan.org/pod/Bio::AlignIO  
	- fasconvert from cpan: https://metacpan.org/pod/distribution/FAST/bin/fasconvert
	- Statistics::R from cpan: https://metacpan.org/pod/release/GMPASSOS/Statistics-R-0.02/lib/Statistics/R.pm  

Pre-Usage:  
- make sure your "Statistics::R" is correctly installed and updated. Your SSS-test results will not be correct if you see the following message on your shell: "Can't locate object method "set" via package "Statistics :: R" at ... PATH_TO / multipleObservationCorrection.pl line 87, <tmp2_file> line 1.". This message  indicates the software is incorrectly installed or too old  
- if necessary, copy the lib/distParam directory from the RNAsnp sources over to the RNAsnp installation location.  
- export the path to RNAsnp installation location:  
  export RNASNPPATH=/path-to/RNAsnp-1.2  
- make sure that all binaries of required software are in the path (with /path-to/ and /RNAsnp/ /ViennaRNA/ etc replaced appropriately; relplot.pl is provided in a subfolder of the share folder of ViennaRNA)  
  export PATH=$PATH:/path-to/RNAsnp/bin:/path-to/ViennaRNA/bin:/path-to/ViennaRNA/share/ViennaRNA/bin:/path-to/muscle/bin  

__***Bypassing installment requirements***__
 
If you do not wish to pre-install the required softwares and just use the SSS-test and local pipelines directly, you can use the nix-bundle available at: http://www.bioinf.uni-leipzig.de/Software/SSS-test/ 

Just download the SSS-test inside the nix-bundle directory and use the software directly.
  
__***Help pages***__
  
Help page for usage:	
  
	bash SSS-test
	bash local-structure-pipeline
         
Notice that once you run the SSS-test for the first time for any multi-FASTA file, intermediate files will be created. Therefore, the next time you run the test again for the same file, the calculation of the sss-scores will be considerably faster.

__***Input requirements***__

1) The input multi-FASTA file **must** to be in a subfolder of the running folder for both pipelines (SSS-test and local-structure-pipeline). If you are running the SSS-test or local.sh in $DIRECTORY, the input multi-FASTA must be located in $DIRECTORY/$SUB_FOLDER/  

2) The FASTA headers should **not** contain space characters. It is recommended that a small name is given to each sequence, making it easy to identify each one.  

__***Tutorial***__

The SSS-test and the local pipeline both require a simple multi-FASTA file as input, either pre-aligned or not aligned. The SSS-test predicts structural selection by assigning selection scores for each of the given sequences. The local pipeline calculates local structural blocks for long ncRNAs.  

<img src="https://github.com/waltercostamb/SSS-test/blob/master/sss_workflow.png" alt="drawing" width="500"/>  

In this section, you will learn how to use the local pipeline and the SSS-test with examples contained in this repository. Just follow the directions below, and you will calculate selection scores for ncRNAs and lncRNA blocks and obtain images of secondary structures to analyse visually.

Usage:	        

	bash SSS-test -i FOLDER/FILE -f FORMAT (fasta/aligned) -s STRUCTURE (Yes/No)
	bash local-structure-pipeline -i FOLDER/FILE -f FORMAT (fasta/aligned) -o OUTPUT_FOLDER

In the /examples/ folder, you will find two multi-FASTA files: SIX3_AS1sub10.fa and H19X.fa. The first is a local structure block from the lncRNA SIX3-AS1 that can be submitted to the SSS-test directly. After running the SSS-test, you will obtain an output table with the selection scores and an output folder with the secondary structures of each species and respective consensus. Both outputs will be located in the input folder.

To run the SSS-test for the local block 10 of the SIX3-AS1 lncRNA, use the following command line:

	bash SSS-test -i example/SIX3_AS1sub10.fa -f fasta -s Yes 

You will produce an output file with the SSS-scores at: /examples/SIX3_AS1sub10.sss and an output folder at: /examples/SIX3_AS1sub10_structures/.

To measure structural selection locally in the H19X-AS1 lncRNA, you should first calculate local structure blocks and then apply the SSS-test for them. For that you can use the command lines below. The first command will create a folder: /HX19_local/ with the local structure blocks. The second applies the SSS-test to local structure 2, as an example.

	bash local-structure-pipeline -i example/H19X.fa -f fasta -o H19X_local_structures   
	bash SSS-test -i H19X_local_structures/H19X_sub1.fasta -f fasta -s Yes  
	
The output of the local.sh script is a folder with all local structural blocks, which can be directly submitted to the SSS-test on not aligned mode (fasta).

__***Output***__

The output header of SSS-test is:                                                                                                                                                                    
sequence_ID	nr_changes	sp_dist	sp_length	alg_length	score_indels	score_changes	sp_score	family_divergence
                                                                                                                                                                                   
- sequence_ID: ID of the sequence
- nr_changes: number of species specific changes. A species specific change is a base of the species that differs from the dominant base of the row, when a dominant base exists for the row. A dominant base exists when at least 60% of the bases of the row converge
- sp_dist: structural distance between the species and the consensus. Distance is calculated using the ensemble base pairing probabilities
- sp_length: length of the species
- alg_length: length of the alignment
- score_indels: indels score, calculated using the Fisher's method
- score_changes: changes score, calculated using the Fisher's method
- sp_score: species selection score, calculated summing both indel and changes score
- divergence: family's structural divergence
                
__***Reference and citation***__

The SSS-test and local pipeline are refered in the following publication, which contains all details on the algorithms.  

If you use this test, please cite:  

"SSS-test: a novel test for detecting positive selection on RNA secondary structure", Maria Beatriz Walter Costa, Christian Höner zu Siederdissen, Marko Dunjic, Peter F. Stadler and Katja Nowick. BMC Bioinformatics. 2019  
https://doi.org/10.1186/s12859-019-2711-y

__***Contact***__

If you have any questions or problems, contact the developer: waltercostamb@gmail.com

__***Author***__

Maria Beatriz Walter Costa  
https://github.com/waltercostamb
