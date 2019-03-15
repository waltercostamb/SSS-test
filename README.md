# SSS-test

Selection on the Secondary Structure-test: a test that detects positive and negative selection from a set of orthologs, either small or long ncRNAs.

This repository contains the SSS-test and the local pipeline designed to calculate local blocks from a multi-FASTA file or lncRNA orthologs.

The programs were designed for Unix-based operational systems, so you can use them in any Linux or MacOS computer. For Windows systems you need either specific compilers or a Virtual Machine in addition. To obtain the repository in a Unix machine and use it locally, you can either download the repository directly from the GITHub webpage, or you can clone the repository in the terminal with the following command line:

git clone https://github.com/waltercostamb/SSS-test

__***Requirements***__

The SSS-test and the local pipeline both require a simple multi-FASTA file as input, either pre-aligned or not aligned. The SSS-test predicts structural selection by assigning selection scores for each of the given sequences. The local pipeline calculates local structural blocks for long ncRNAs.

Required software: 

	- RNAsnp: http://rth.dk/resources/rnasnp/software  
	- muscle aligner: http://www.drive5.com/muscle  
	- Vienna RNA package: http://www.itc.univie.ac.at/~ivo/RNA/INSTALL.html  
	- Bio::AlignIO from cpan: http://search.cpan.org/dist/BioPerl/Bio/AlignIO.pm  
	- fasconvert from cpan: http://search.cpan.org/dist/FAST/bin/fasconvert  
	- Statistics::R from cpan: http://search.cpan.org/~gmpassos/Statistics-R-0.02/lib/Statistics/R.pm

Pre-Usage:  
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
  
	bash SSS.sh  
	bash local.sh
         
Notice that once you run the SSS-test for the first time for any multi-FASTA file, intermediate files will be created. Therefore, the next time you run the test again for the same file, the calculation of the sss-scores will be considerably faster.

__***Input format requirements***__

The input multi-FASTA files have to be in the appropriate format and in a separate folder for both pipelines. The name of the file must correspond to the ID of the group followed by e file extension.  
 - Examples: identity.fasta, identity.fa, identity.alg    
 
The header of the fasta sequences must have the header indicator '>' followed immediatly by the ID of the group (the same name of the file without extension), followed by a tab, followed by a pipe sign, followed by a second tab, followed by the species name or sequence ID. Minus sings are prohibitted, while underscores are allowed.  

 - Example of a valid FASTA header for file identity.fasta: >identity	|	species                                                                 

We are implementing a subroutine to simplify FASTA header requirements.

__***Tutorial***__

In this section, you will learn how to use the local pipeline and the SSS-test with examples contained in this repository. Just follow the directions below, and you will calculate selection scores for ncRNAs and lncRNA blocks and obtain images of secondary structures to analyse visually.

Usage:	        

	bash SSS.sh folder/identity.fa FORMAT (fasta/aligned) Structure(Yes/No)
	bash local.sh folder/identity.fa FORMAT (fasta/aligned)

In the /examples/ folder, you will find two multi-FASTA files: SIX3_AS1sub10.fa and H19X.fa. The first is a local structure block from the lncRNA SIX3-AS1 that can be submitted to the SSS-test directly. After running the SSS-test, you will obtain an output table with the selection scores and an output folder with the secondary structures of each species and respective consensus. Both outputs will be located in the input folder.

To run the SSS-test for the local block 10 of the SIX3-AS1 lncRNA, use the following command line:

	bash SSS.sh example/SIX3_AS1sub10.fa fasta Yes 

You will produce an output file with the SSS-scores at: /examples/SIX3_AS1sub10.sss and an output folder at: /examples/SIX3_AS1sub10_structures/.

To measure structural selection locally in the H19X-AS1 lncRNA, you should first calculate local structure blocks and then apply the SSS-test for them. For that you can use the command lines below. The first command will create a folder: /HX19_local/ with the local structure blocks. The second applies the SSS-test to local structure 2, as an example.

	bash local.sh example/H19X.fa fasta 
	bash SSS.sh H19X_local/H19X_sub2.fa fasta Yes

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

If you have any questions or find any problems, contact the developer: bia.walter@gmail.com

