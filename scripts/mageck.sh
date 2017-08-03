#!/bin/bash

if [[ $# -ne 4 ]]; then
    echo "USAGE: $0 <sgRNA_gene.csv> <control_samples[,control_sample]> <treatment_sample[,treatment_sample]> <folder_of_csv_files>"
    exit 1
fi

MASTER_DIR=$(dirname $(dirname -- $(readlink -f -- $0)))
MAGECK=$MASTER_DIR/src/mageck/bin/mageck
# Using RRA needs to set PATH
export PATH=$MASTER_DIR/src/mageck/bin:$PATH

# Get a list of csv files
csv_files=$(ls $(readlink -f -- $4)/*.csv)

# Get the gene count from each cvs
for file in ${csv_files[@]}; do
    awk -F',' '{a[++k]=$2}END{for(i=1;i<k;i++)print a[i]}' $file > $file.tmp
done

# Collect all csv files as a mageck.table
paste -d ',' $1 $(for file in ${csv_files[@]}; do echo $file.tmp; done) | sed "s///g" | sed "s/,/\t/g" > $(readlink -f -- $4)/mageck.table

# Clean up tmp files
for file in ${csv_files[@]}; do
    rm -rf $file.tmp
done



$MAGECK test -k $(readlink -f -- $4)/mageck.table -c $2 -t $3 -n mageck
