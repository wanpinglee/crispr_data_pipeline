#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "USAGE: $0 <REF.fa>"
    exit 1
fi

REF=$1
REF_PREFIX=${REF%.*}

MASTER_DIR=$(dirname $(dirname -- $(readlink -f -- $0)))
BOWTIE_DIR=$MASTER_DIR/src/bowtie2

# Check if input file exists
if [ ! -f $REF ]; then
    echo "ERROR: The input reference file does not exist. Input: $REF"
    exit 1
fi 

# Check the existence of bowtie index files.
index_build=true
for suffix in 1 2 3 4 rev.1 rev.2
do
    if [ ! -f $REF_PREFIX.$suffix.bt2 ]; then
        index_build=false
    fi
done

# If bowtie index files do not exist, then we build them.
if [ $index_build == false ]; then
    if [ ! -f $BOWTIE_DIR/bowtie2-build ]; then
        echo "ERROR: You haven't built the tool please type \"make\" in $MASTER_DIR."
        exit 1
    fi

    echo "###### bowtie2-build ######"
    $BOWTIE_DIR/bowtie2-build $REF $REF_PREFIX
fi
