#!/bin/bash

cat <<EOF
*************************************************************************
*********************** The format of the script: ***********************
$0 OUTPUT_FILE.out
*************************************************************************
EOF

if [ -z "$1" ] ; then
	        echo -e "\033[31mERROR:\033[0m Missing file operand! Please identify the name of OUTPUT_FILE.out"
		        exit 1
fi

echo "====================================="
echo "In process..."
echo "..."

#input_file=$PWD/$input_file
input_file=${1%.*}.d12
plot_file=$PWD/${1%.*}__data.ssv
output_file=${1%.*}.out



starttime=`grep -a 'EEEEEEEEEE STARTING  DATE' $output_file | awk '{print $4,$5,$6,$7,$8}'`

#input_file=ZrO2.out         # Change the file name here
#plot_file=ZrO2__data.ssv     # Name the output file here 


if test -e $plot_file  ; then
	rm -r $plot_file
fi

read MAX_G MAX_D <<< `grep 'MAXIMUM GRADIENT COMPONENT' $output_file | awk '{print $4,$NF}'` 
read RMS_G RMS_D <<< `grep 'R.M.S. OF GRADIENT COMPONENT' $output_file | awk '{print $5,$NF}'`
TOLDEE=`grep -aim 1 -A 1 'TOLDEE' $input_file | tr -cd "[0-9]"`
MAXCYCLE=`grep -aim 1 -A 1 'MAXCYCLE' $input_file | tr -cd "[0-9]"`
FMIXING=`grep -aim 1 -A 1 'FMIXING' $input_file | tr -cd "[0-9]"`
LEVSHIFT=`grep -aim 1 'LEVSHIFT' $input_file`
NOTRUSTR=`grep -aim 1 'NOTRUSTR' $input_file`

MAX_TRUSTR=`grep -aim 1 'MAXIMUM TRUST RADIUS' $output_file | awk '{print $NF}'`

echo "# Job Starting Date: $starttime" >> $plot_file
echo "# Directory: $PWD" >> $plot_file
echo "# File: $PWD/$output_file" >> $plot_file
[[ -n $NOTRUSTR ]] && echo "# NOTRUSTR USED" >> $plot_file && MAX_TRUSTR="N/A"
[[ -n $TOLDEE ]] && echo "# TOLDEE: $TOLDEE" >> $plot_file
[[ ! -n $TOLDEE ]] && echo "# TOLDEE: 7" >> $plot_file
[[ -n $LEVSHIFT ]] && echo "# LEVSHIFT USED" >> $plot_file
[[ -n $MAXCYCLE ]] && echo "# MAXCYCLE: $MAXCYCLE" >> $plot_file
[[ ! -n $MAXCYCLE ]] && echo "# MAXCYCLE: 50" >> $plot_file
[[ -n $FMIXING ]] && echo "# FMIXING: $FMIXING" >> $plot_file
[[ ! -n $FMIXING ]] && echo "# FMIXING: 30" >> $plot_file
echo -n "# CYCLE_NUMBER | TOTAL_ENERGY (Ha) | SCF_CYCLES | MAX_G.($MAX_G) | RMS_G.($RMS_G) | MAX_D.($MAX_D) | RMS_D.($RMS_D) | TRUST_R.($MAX_TRUSTR)" >> $plot_file
#echo -n "# CYCLE_NUMBER | TOTAL_ENERGY (Ha) | SCF_CYCLES | MAX_GRADIENT(0.000450) | RMS_GRADIENT(0.000300) | MAX_DISPLAC.(0.001800) | TRUST_RADIUS |" >> $plot_file
cycle_total=$(grep -ae 'TOTAL ENERGY(DFT)(AU)'  $output_file | wc -l)
for((i=1;i<=$cycle_total;i++));do
    cycle_number=$(grep -am $i 'OPTIMIZATION - POINT' $output_file | tail -1 | awk '{print $NF}') 
    line_number1=$(grep -am $i -n 'OPTIMIZATION - POINT'  $output_file | tail -1 | cut  -d  ":"  -f  1)
    line_number2=$(grep -am $(expr $i + 1) -n -E 'OPTIMIZATION - POINT|OPT END - CONVERGED|OPT END - FAILED'  $output_file | tail -1 | cut  -d  ":"  -f  1)
    GRIMME_CHECK=`sed -n "${line_number1},${line_number2}p" $output_file | grep -ae 'TOTAL ENERGY + DISP (AU)'`
    if [[ -n $GRIMME_CHECK ]] ; then
	    total_energy=`grep -am $i 'TOTAL ENERGY + DISP (AU)' $output_file | tail -1 | awk '{print $(NF)}'`
    else
	    total_energy=`grep -am $i 'TOTAL ENERGY(DFT)(AU)' $output_file | tail -1 | awk -F ')' '{print $4}' | awk -F 'DE' '{print $1}'`
    fi
    SCF_CYCLES=`grep -am $i 'TOTAL ENERGY(DFT)(AU)' $output_file | tail -1 | awk -F ')' '{print $3}'`
    #var_type=$(echo $total_energy | tr -cd "[0-9]")
    #if [ -z $var_type ] ; then
    #    SCF_CYCLES=$(grep -am $i 'TOTAL ENERGY(DFT)(AU)' $output_file | tail -1 | awk '{print $(NF-5)}') 
    #    SCF_CYCLES=$(echo $SCF_CYCLES | tr -cd "[0-9]")
    #else
    SCF_CYCLES=$(echo $SCF_CYCLES | tr -cd "[0-9]")
    #fi
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
    printf "\t %6.6f %s" $MAX_GRADIENT  $MAX_GRADIENT_CONVERGED >> $plot_file
    printf "\t %5.6f %s" $RMS_GRADIENT $RMS_GRADIENT_CONVERGED >> $plot_file
    printf "\t %6.6f %s" $MAX_DISPLAC $MAX_DISPLAC_CONVERGED >> $plot_file
    printf "\t %6.6f %s" $RMS_DISPLAC $RMS_DISPLAC_CONVERGED >> $plot_file
    printf "\t %15.3f" $TRUST_RADIUS >> $plot_file
done
#endtime=$(date +%s)
#dif=$(expr $endtime - $starttime)
#time_used=$(date +%M:%S -d "1970-01-01 UTC $dif seconds")
#sed -i "/# Starting Date:/a\# Termination Date: $(date)" $plot_file
#sed -i "/# Starting Date:/a\# Time Used: $time_used" $plot_file
printf "\n# Done!" >> $plot_file
echo "====================================="
