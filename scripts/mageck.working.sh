#!/bin/bash

if [[ $# -ne 4 ]]; then
    echo "USAGE: $0 <sgRNA_gene.csv> <control_samples[,control_sample]> <treatment_sample[,treatment_sample]> <folder_of_csv_files>"
    exit 1
fi

# Get an array of control samples
control_samples=$(echo $2 | tr "," "\n")
# Get an array of treament samples
treament_samples=$(echo $3 | tr "," "\n")

# Get a list of csv files
csv_files=$(ls $(readlink -f -- $4)/*.csv)

# Get the sample name from csv files and link names and files by a dictionary
declare -A sample_names
for file in ${csv_files[@]}; do
    name=$(head -n 1 $file | awk -F',' '{print $2}')
    sample_names["$name"]=$file
done

# Dictionaries for samples, e.g. control_sample_csv[sample_name]=its_csv
declare -A control_sample_csv
declare -A treatment_sample_csv
# Check if control and treatment samples have corresponding csv files
EXIT=false
for sample in ${!sample_names[@]}; do
    found=false
    for control_sample in ${control_samples[@]}
    do
        if [[ "$sample" == "$control_sample"* ]]; then
            found=true;
            control_sample_csv[$sample]=${sample_names[$sample]}
            break; 
        fi
    done

    # No need to check treament_samples
    if [[ $found == true ]]; then break; fi

    for treament_sample in ${treament_samples[@]}
    do
        if [[ "$sample" == "$treament_sample"* ]]; then 
            found=true;
            treatment_sample_csv[$sample]=${sample_names[$sample]}
            break; 
        fi
    done

    if [[ $found == false ]]; then
        echo $sample
        echo "    is not found in any csv file."
    fi
done

# Clean up arrays
unset sample_names
unset control_samples
unset treament_samples

# Get a dictionary: sgrna_gene[sgRNA] = gene
declare -A $(awk -F',' -v front_skip=1 '
    NR>front_skip{print "sgrna_gene["$1"]="$2}
' $1)

count=1
for file in ${treatment_sample_csv[@]}; do
    dic_names+=(dic_$count)
    declare -A $(awk -F',' -v front_skip=1 -v id=$count '
        NR>front_skip{print "dic_"id"["$1"]="$2}
    ' $file)

    count=$((count+1))
done


for dic in ${dic_names[@]}; do
    echo $dic
    for ele in ${\dic[@]}; do echo $ele; done
done
#for sgrna in "${!table[@]}"; do
#    echo "$sgrna - ${table[$sgrna]}"
#done
