# SSS-test

This folder contains the bash script SSS.sh and local.pl. The first runs the SSS-test (Selection on the Secondary Structure-test) and the second runs the local pipeline to predict local blocks in long non-coding RNAs. The input for both is a multi-FASTA, either pre-aligned or not aligned. The SSS-test predicts structural selection by assigning selection scores for each of the given sequences. The local pipeline calculates local structural blocks for long ncRNAs.

Required software: 

	- RNAsnp: http://rth.dk/resources/rnasnp/software
	
	- muscle aligner: http://www.drive5.com/muscle

	- Vienna RNA package: http://www.itc.univie.ac.at/~ivo/RNA/INSTALL.html

	- Bio::AlignIO from cpan: http://search.cpan.org/dist/BioPerl/Bio/AlignIO.pm

	- fasconvert from cpan: http://search.cpan.org/dist/FAST/bin/fasconvert
	
	- Statistics::R from cpan: http://search.cpan.org/~gmpassos/Statistics-R-0.02/lib/Statistics/R.pm

Pre-Usage:
- if necessary, copy the lib/distParam directory from the RNAsnp sources over
  to the RNAsnp installation location.
- export the path to RNAsnp installation location:
  export RNASNPPATH=/path-to/RNAsnp-1.2
- make sure that all binaries of required software are in the path (with
  /path-to/ and /RNAsnp/ /ViennaRNA/ etc replaced appropriately; relplot.pl is
  provided in a subfolder of the share folder of ViennaRNA)
  export PATH=$PATH:/path-to/RNAsnp/bin:/path-to/ViennaRNA/bin:/path-to/ViennaRNA/share/ViennaRNA/bin:/path-to/muscle/bin
  
  Help page for usage:	perl SSS.sh
  
      	                perl local.pl --help
          
Notice that once you run the SSS-test for the first time for any multi-FASTA file, intermediate files will be created. Therefore, the next time you run the test again for the same file, the calculation of the sss-scores will be considerably faster.

Input multi-FASTA files have to be in the appropriate format and in a separate folder for both pipelines. The name of the file must correspond to the ID of the group followed by e file extension.
 - Examples: identity.fasta, identity.fa, identity.alg    
 
 The header of the fasta sequences must have the header indicator '>' followed immediatly by the ID of the group (the same name of the file without extension), followed by a tab, followed by a pipe sign, followed by a second tab, followed by the species name or sequence ID. Minus sings are prohibitted, while underscores are allowed.             
 - Example of a valid FASTA header for file identity.fasta: >identity	|	species                                                                 

Output of the local.pl is a folder with local structural blocks, that can be submitted to the SSS.sh on not aligned mode (fasta)

Output header of SSS.pl:                                                                                                                                                                    
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
                                                                                                                              
