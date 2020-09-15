#!/bin/bash

output_file="scf_summary"

directory_list="
/scratch/ep0/hm1876/CeO2/PH/CeO2-9H2O/H2O-OV-F-O2-/option1
/scratch/ep0/hm1876/CeO2/PH/CeO2-9H2O/H2O-OV-UF-O2-/option1
/scratch/ep0/hm1876/CeO2/PH/CeO2-H3O+-8H2O/H3O+-OV-F-O2-/option1
/scratch/ep0/hm1876/CeO2/PH/CeO2-H3O+-8H2O/H3O+-OV-F-O2-/option2
/scratch/ep0/hm1876/CeO2/PH/CeO2-OH--8H2O/OH--OV-F-O2-/option1
/scratch/ep0/hm1876/CeO2/PH/CeO2-OH--8H2O/OH--OV-F-O2-/option2
/scratch/ep0/hm1876/CeO2/PH/CeO2-OH--8H2O/OH--OV-UF-O2-/option1
/scratch/ep0/hm1876/CeO2/PH/CeO2-OH--8H2O/OH--OV-UF-O2-/option2
/scratch/ep0/hm1876/CeO2/PH/CeO2-9H2O/OV-Original-Input-Geometry/NEAR-OV-2nd-H2O
"

echo "====================================="
echo "In process..."
echo "..."


if [ -a $output_file ] ; then
	rm -r $output_file
fi

scf_analysis_file=$PWD/$output_file

for i in $directory_list ; do
	cd $i
	last_input_file=`ls -tr *.d12 | tail -1`
	last_output_file=${last_input_file%.*}.out
	last_tmp_directory=tmp-${last_input_file%.*}
	if [ -d $last_tmp_directory ] ; then
		echo "# Starting Date: $(date)" >> $scf_analysis_file
		echo "# Directory: $PWD" >> $scf_analysis_file
		cd $last_tmp_directory
		echo "# TMP_Directory: $PWD" >> $scf_analysis_file
		echo >> $scf_analysis_file
		if [ -s "SCFOUT.LOG" ] ; then
			tail -300 SCFOUT.LOG >> $scf_analysis_file
		else
			cd $i
			tail -300 $last_output_file >> $scf_analysis_file
			echo >> $scf_analysis_file
			printf "\t NOTE: SCFOUT.LOG file is empty." >> $scf_analysis_file
		fi
	else
		echo "# Starting Date: $(date)" >> $scf_analysis_file
		echo "# Directory: $PWD" >> $scf_analysis_file
		echo >> $scf_analysis_file
		printf "\t Error: TMP directory doesn't exist. Job has not started!" >> $scf_analysis_file
	fi
	echo -e "\n" >> $scf_analysis_file
	echo "================================================================================================================================================================" >> $scf_analysis_file
	echo "================================================================================================================================================================" >> $scf_analysis_file
	echo "================================================================================================================================================================" >> $scf_analysis_file
	echo -e "\n" >> $scf_analysis_file
done

echo "====================================="


