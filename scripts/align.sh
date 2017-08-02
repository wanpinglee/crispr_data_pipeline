#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "USAGE: $0 <REF.fa> <READ.fq> <OUT_DIR>"
    exit 1
fi

###### sgRNA Parameters ######
MISMATCHS=2
SGRNA_LENGTH=20
SGRNA_PREFIX=AAACACCG
##############################

REF=$1
REF_PREFIX=${REF%.*} # Get the prefix of REF. It will be used for bowtie alignment.

FQ=$2
###### Get the filename of FQ as output prefix ######
FILENAME=${FQ##*/}
if [ ${FILENAME##*.} == "gz" ]; then
    FILENAME=${FILENAME%%.*}
else
    FILENAME=${FILENAME%.*}
fi

OUT_DIR=$3
PREFIX=$3/$FILENAME
mkdir -p $OUT_DIR # Create output directory if it does not exist.

###### Check files ######
# Check file existence
if [ ! -f $REF ]; then
    echo "ERROR: $REF does not exist."
    exit 1
fi

if [ ! -f $REF_PREFIX.csv ]; then
    echo "ERROR: $REF_PREFIX.csv does not exist."
    exit 1
fi

if [ ! -f $FQ ]; then
    echo "ERROR: $FQ does not exist."
    exit 1
fi

# Unzip files. If unzip files, ask users to unzip them.
if [ ${REF##*.} == gz ]; then
    echo "ERROR: Please unzip $REF."
    exit 1
fi

if [ ${FQ##*.} == gz ]; then
    echo "ERROR: Please unzip $FQ."
    exit 1
fi

# Check the file suffix. REF should have "fa" or "fasta" as suffix while FQ should have "fq" or "fastq".
if [ ${REF##*.} != "fa" ] && [ ${REF##*.} != "fasta" ]; then
    echo "ERROR: The reference should have suffix fasta or fa. Input is $REF"
    exit 1
fi

if [ ${FQ##*.} != "fq" ] && [ ${FQ##*.} != "fastq" ]; then
    echo "ERROR: The read file should have suffix fastq, fq, fastq.gz or fq.gz. Input is $FQ"
    exit 1
fi

MASTER_DIR=$(dirname $(dirname -- $(readlink -f -- $0)))
SCRIPT_DIR=$MASTER_DIR/scripts
BOWTIE_DIR=$MASTER_DIR/src/bowtie2
FASTQC=$MASTER_DIR/src/fastqc_v0.11.5/fastqc
Q_FILTER=$MASTER_DIR/build/bin/fastq_quality_filter
TRIMMER=$MASTER_DIR/src/CRISPR.sgRNA_read_trimmer/trim_reads.py
COUNTER=$MASTER_DIR/src/CRISPR.single_sgRNA_count/summarize_alignments.py

# Check the existence of bowtie index files.
# If bowtie index files do not exist, then we build them.
sh $SCRIPT_DIR/ref_build.sh $REF

###### QC ######
# FastQC
mkdir -p $OUT_DIR/$FILENAME/
echo "cat $FQ | $FASTQC stdin --outdir=$OUT_DIR/$FILENAME/"
cat $FQ | $FASTQC stdin --outdir=$OUT_DIR/$FILENAME/

# Quality filter
echo "$Q_FILTER -v -Q33 -q 25 -p 50 -i $FQ -o $PREFIX.filtered.fastq"
$Q_FILTER -v -Q33 -q 25 -p 50 -i $FQ -o $PREFIX.filtered.fastq


###### sgRNA Trimmer ######
FQ_READ_COUNT=`wc -l $PREFIX.filtered.fastq | awk '{print $1}'` # Note the number should be divided by 4.
echo "python $TRIMMER/trim_reads.py $PREFIX.filtered.fastq $SGRNA_PREFIX $MISMATCHS $SGRNA_LENGTH $FQ_READ_COUNT $PREFIX.trimmed"
python $TRIMMER $PREFIX.filtered.fastq $SGRNA_PREFIX $MISMATCHS $SGRNA_LENGTH $FQ_READ_COUNT $PREFIX.trimmed


###### Alignment ######
echo "$BOWTIE_DIR/bowtie2 -x $REF_PREFIX -U $PREFIX.trimmed.fastq -S $PREFIX.trimmed.sam"
$BOWTIE_DIR/bowtie2 -x $REF_PREFIX -U $PREFIX.trimmed.fastq -S $PREFIX.trimmed.sam

###### sgRNA_count ######
echo "python $COUNTER $PREFIX.trimmed.sam $FILENAME $REF_PREFIX.csv $PREFIX.csv $FQ_READ_COUNT"
python $COUNTER $PREFIX.trimmed.sam $FILENAME $REF_PREFIX.csv $PREFIX $FQ_READ_COUNT
















