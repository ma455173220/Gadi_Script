#!/bin/bash

output_file="energy_summary"

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

data_analysis_file=$PWD/$output_file

energy_analyse () {
	
	echo "====================================="
	echo "In process..."
	echo "..."
	
	#output_file=$PWD/$input_file
	output_file=$1
	plot_file=$PWD/${1%.*}__data.ssv

	
	starttime=$(date +%s)
	
	#output_file=ZrO2.out         # Change the file name here
	#plot_file=ZrO2__data.ssv     # Name the output file here 
	
	
	if [ -a $plot_file ] ; then
		rm -r $plot_file
	fi
	
	echo "# Starting Date: $(date)" >> $plot_file
	echo "# Directory: $PWD" >> $plot_file
	echo "# File: $PWD/$output_file" >> $plot_file
	echo -n "# CYCLE_NUMBER | TOTAL_ENERGY (Ha) | SCF_CYCLES | MAX_GRADIENT(0.000450) | RMS_GRADIENT(0.000300) | MAX_DISPLAC.(0.001800) | RMS_DISPLAC.(0.001200) | TRUST_RADIUS" >> $plot_file
	#echo -n "# CYCLE_NUMBER | TOTAL_ENERGY (Ha) | SCF_CYCLES | MAX_GRADIENT(0.000450) | RMS_GRADIENT(0.000300) | MAX_DISPLAC.(0.001800) | TRUST_RADIUS |" >> $plot_file
	cycle_total=$(grep -ae 'TOTAL ENERGY(DFT)(AU)'  $output_file | wc -l)
	for((i=1;i<=$cycle_total;i++));do
	    cycle_number=$(grep -am $i 'OPTIMIZATION - POINT' $output_file | tail -1 | awk '{print $NF}') 
	    line_number1=$(grep -am $i -n 'OPTIMIZATION - POINT'  $output_file | tail -1 | cut  -d  ":"  -f  1)
	    line_number2=$(grep -am $(expr $i + 1) -n -E 'OPTIMIZATION - POINT|OPT END - CONVERGED|OPT END - FAILED'  $output_file | tail -1 | cut  -d  ":"  -f  1)
	    read total_energy SCF_CYCLES <<< $(grep -am $i 'TOTAL ENERGY(DFT)(AU)' $output_file | tail -1 | awk '{print $(NF-3),$(NF-4)}')
	    var_type=$(echo $total_energy | tr -cd "[0-9]")
	    if [ -z $var_type ] ; then
	            read total_energy SCF_CYCLES <<< $(grep -am $i 'TOTAL ENERGY(DFT)(AU)' $output_file | tail -1 | awk '{print $(NF-4),$(NF-5)}') 
	            SCF_CYCLES=$(echo $SCF_CYCLES | tr -cd "[0-9]")
	        else
		        SCF_CYCLES=$(echo $SCF_CYCLES | tr -cd "[0-9]")
		    fi
	        CYCLE_REJECTED=$(sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'STEP REJECTED')
	    if [ -n "$CYCLE_REJECTED" ] ; then
	            printf "\n%s \t %d \t %15.10f \t %d" xxx $cycle_number $total_energy $SCF_CYCLES >> $plot_file
	        else
		        printf "\n \t %d \t %15.10f \t %d" $cycle_number $total_energy $SCF_CYCLES >> $plot_file
		    fi
	        #sed -n "${line_number1},${line_number2}p" ./$output_file | grep -ae 'MAX GRADIENT' | awk '{print $3,$7}'| while read a b;do
	    #    MAX_GRADIENT=$a MAX_GRADIENT_CONVERGED=$b
	    read TRUST_RADIUS <<<  $(sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'UPDATED TRUST RADIUS' | awk '{print $4}')
	    read MAX_GRADIENT MAX_GRADIENT_CONVERGED <<< $(sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'MAX GRADIENT' | awk '{print $3,$7}')
	    read RMS_GRADIENT RMS_GRADIENT_CONVERGED <<< $(sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'RMS GRADIENT' | awk '{print $3,$7}')
	    read MAX_DISPLAC MAX_DISPLAC_CONVERGED <<< $(sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'MAX DISPLAC' | awk '{print $3,$7}')
	    read RMS_DISPLAC RMS_DISPLAC_CONVERGED <<< $(sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'RMS DISPLAC' | awk '{print $3,$7}')
	    printf "\t \t %6.6f %s" $MAX_GRADIENT  $MAX_GRADIENT_CONVERGED >> $plot_file
	    printf "\t \t %5.6f %s" $RMS_GRADIENT $RMS_GRADIENT_CONVERGED >> $plot_file
	    printf "\t \t %6.6f %s" $MAX_DISPLAC $MAX_DISPLAC_CONVERGED >> $plot_file
	    printf "\t \t %6.6f %s" $RMS_DISPLAC $RMS_DISPLAC_CONVERGED >> $plot_file
	    printf "\t %15.3f" $TRUST_RADIUS >> $plot_file
	done
	endtime=$(date +%s)
	dif=$(expr $endtime - $starttime)
	time_used=$(date +%M:%S -d "1970-01-01 UTC $dif seconds")
	sed -i "/# Starting Date:/a\# Termination Date: $(date)" $plot_file
	sed -i "/# Termination Date:/a\# Time Used: $time_used" $plot_file
	printf "\n# Done!" >> $plot_file
	echo "====================================="
	
}


for i in $directory_list ; do
	cd $i
	last_input_file=`ls -tr *.d12 | tail -1`
	last_output_file=${last_input_file%.*}.out
	if [ -a $last_output_file ] ; then
		~/energy_analyse.sh $last_output_file >> /dev/null
		ls -tr *data.ssv | tail -1 | xargs less >> $data_analysis_file 
	else
		echo "# Starting Date: $(date)" >> $data_analysis_file
		echo "# Directory: $PWD" >> $data_analysis_file
		echo "# File: $PWD/$last_output_file" >> $data_analysis_file
		echo >> $data_analysis_file
		printf "\t Error: Output file doesn't exist. Job has not started!" >> $data_analysis_file
	fi
	echo -e "\n" >> $data_analysis_file
	echo "=====================================" >> $data_analysis_file
	echo -e "\n" >> $data_analysis_file
done

echo "====================================="

