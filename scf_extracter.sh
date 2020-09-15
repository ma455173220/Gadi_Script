#!/bin/bash

echo "What's the input file?"
read input_file
echo "Which cycle?"
read scf_number
echo "====================================="
echo "In process..."
echo "..."

input_file1=$PWD/$input_file
if test -e $PWD/${input_file%.*}.SCFLOG ; then
	input_file2=$PWD/${input_file%.*}.SCFLOG	
else
	input_file2=$PWD/tmp-${input_file%.*}/SCFOUT.LOG
fi
output_file=$PWD/${input_file%.*}__SCF_$scf_number



if test -e $output_file  ; then
rm -r $output_file
fi

if [ $scf_number -eq '1' ] ; then
    	start_line=$(grep -n "OPTIMIZATION - POINT    $scf_number"  $input_file1 | cut  -d  ":"  -f  1)
	end_line=$(grep -n 'GEOMETRY OUTPUT FILE'  $input_file1 | cut  -d  ":"  -f  1)
	sed -n "${start_line},${end_line}p" $input_file1 >> $output_file
else
	start_line=$(grep -m $(expr ${scf_number} - 1) -n "INFORMATION \*\*\*\* EXCBUF \*\*\*\*" $input_file2 | cut -d ":" -f 1 | tail -1)
	end_line=$(grep -m $scf_number -n "INFORMATION \*\*\*\* EXCBUF \*\*\*\*" $input_file2 | cut -d ":" -f 1 | tail -1)
	sed -n "${start_line},${end_line}p" $input_file2 >> $output_file
fi


echo "====================================="


