#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=384G
#SBATCH --time=24:00:00
#SBATCH -J STAR
#SBATCH -e %x-%j-%a.err
#SBATCH -o %x-%j-%a.out
#SBATCH --verbose

INPUT_R1=$(head -n $SLURM_ARRAY_TASK_ID $inputfiles_R1 | tail -n 1)
NAME=$(head -n $SLURM_ARRAY_TASK_ID $samplelist | tail -n 1)
OUTPUT=$outdir\/$NAME\_$SLURM_ARRAY_TASK_ID\_

source activate encode-rna-seq-pipeline

# example command: 
# sbatch -p hpc_l40_b --array=1-29 --export=inputfiles_R1=inputfiles.txt,STAR_INDEX=/rugpfs/fs0/risc_lab/store/jrendleman/references/STAR_Index,outdir=/lustre/fs4/risc_lab/scratch/jyeung/Different_Cell_Lines_NFkB_Profiling_PDvsDoxo_Jan2026/STAR_alignment,samplelist=samplenames.txt STAR_SE_aligner.slurm
STAR \
  --runThreadN 4 \
  --genomeDir $STAR_INDEX \
  --readFilesIn $INPUT_R1 \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --outFilterType BySJout \
  --outFilterMultimapNmax 15 \
  --alignSJoverhangMin 8 \
  --alignSJDBoverhangMin 1 \
  --outFilterMismatchNmax 500 \
  --outFilterMismatchNoverReadLmax 0.05 \
  --alignIntronMin 20 \
  --alignIntronMax 1000000 \
  --outTmpDir ${OUTPUT}_tmp \
  --outFileNamePrefix $OUTPUT \
  --quantMode GeneCounts

samtools index ${OUTPUT}Aligned.sortedByCoord.out.bam
