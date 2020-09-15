#!/bin/bash
 
echo "====================================="
echo "In process..."
echo "..."

sub_script_first_part=${2%-*}
sub_script_number=$(echo $2 | awk -F- '{print $NF}')
new_sub_script_number=$(printf "%02d\n" $(expr $sub_script_number + 1))
new_sub_script=$sub_script_first_part-$new_sub_script_number
next_new_sub_script_number=$(printf "%02d\n" $(expr $sub_script_number + 2))
next_new_sub_script=$sub_script_first_part-$next_new_sub_script_number
cp -f  $2 $new_sub_script
echo "$2 saved as $new_sub_script"

input_file_first_part=${1%-*}
input_file_number_with_extension=$(echo $1 | awk -F- '{print $NF}')
input_file_number=${input_file_number_with_extension%.*}   #remove the .d12 extension
output_file_number=$(printf "%02d\n" $(expr $input_file_number + 1))
output_file=$input_file_first_part-$output_file_number.d12
cp -f  $1 $output_file
echo "$1 saved as $output_file"

sed -i "s/TMPFOLDER=\"[^)]*\"/TMPFOLDER=\"tmp-${output_file%.*}\"/" $new_sub_script
sed -i "s/JOBNAME=\"[^)]*\"/JOBNAME=\"${output_file%.*}\"/" $new_sub_script
sed -i "s/SCRIPTNAME=\"[^)]*\"/SCRIPTNAME=\"$new_sub_script\"/" $new_sub_script
sed -i "s/NEXT_SCRIPTNAME=\"[^)]*\"/NEXT_SCRIPTNAME=\"$next_new_sub_script\"/" $new_sub_script


input_tmp_folder=tmp-${1%.*}
input_fort_folder=$input_tmp_folder/FORT
input_optinfo_folder=$input_tmp_folder/OPTINFO
if [ -z $3 ] ; then
        if [ -d "${1%.*}.optstory" ] ; then
	        input_file_gui=`ls ${1%.*}.optstory/opt* | sort | tail -1`
	        cp -f  $input_file_gui ${output_file%.*}.gui
	        [ $? -eq 0 ] && echo "$input_file_gui saved as ${output_file%.*}.gui"
	        cp -f ${1%.*}.f20 ${output_file%.*}.f9
	        [ $? -eq 0 ] && echo "${1%.*}.f20 saved as ${output_file%.*}.f9"
	        cp -f ${1%.*}.optinfo ${output_file%.*}.optinfo
	        [ $? -eq 0 ] && echo "${1%.*}.optinfo saved as ${output_file%.*}.optinfo"
	else
		opt_file=`ls $input_tmp_folder/opt* 2> /dev/null`
		if [ -n "$opt_file" ]; then
			input_file_gui=$(ls $input_tmp_folder/opt* | sort | tail -1)
			cp -f  $input_file_gui ${output_file%.*}.gui
			echo "$input_file_gui saved as ${output_file%.*}.gui"
		else
			echo -e "\033[31mError:\033[0m $input_tmp_folder/opt* file not exist"
		fi
		
		if [ -d "$input_fort_folder" ] ; then
			fort_file=`ls $input_fort_folder/fort* 2> /dev/null`
			if [ -n "$fort_file" ] ; then
				input_file_f9=$(ls $input_fort_folder/fort* | sort | tail -1)
				cp -f  $input_file_f9  ${output_file%.*}.f9
				echo "$input_file_f9 saved as ${output_file%.*}.f9"
			else
				echo -e "\033[33mWarning:\033[0m $input_fort_folder/fort.20 file not exist"
			fi
		else
			fort_file=`ls $input_tmp_folder/fort.20 2> /dev/null`
			if [ -n "$fort_file" ] ; then
				input_file_f9=$input_tmp_folder/fort.20
				cp -f  $input_file_f9  ${output_file%.*}.f9
				echo "$input_file_f9 saved as ${output_file%.*}.f9"
			else
				echo -e "\033[33mWarning:\033[0m $input_tmp_folder/fort.20 file not exist"
			fi
		fi
	
		if [ -d "$input_optinfo_folder" ] ; then	
			optinfo_file=`ls $input_optinfo_folder/OPT* 2> /dev/null`
			if [ -n "$optinfo_file" ] ; then
				input_file_optinfo=$(ls $input_optinfo_folder/OPT* | sort | tail -1)
				cp -f  $input_file_optinfo ${output_file%.*}.optinfo
				echo "$input_file_optinfo saved as ${output_file%.*}.optinfo"
			else
				echo -e "\033[33mWarning:\033[0m $input_optinfo_folder/OPTINFO.DAT file not exist"
			fi
		else
			optinfo_file=`ls $input_tmp_folder/OPTINFO.DAT 2> /dev/null`
			if [ -n "$optinfo_file" ] ; then
				input_file_optinfo=$input_tmp_folder/OPTINFO.DAT
				cp -f  $input_file_optinfo ${output_file%.*}.optinfo
				echo "$input_file_optinfo saved as ${output_file%.*}.optinfo"
			else
				echo -e "\033[33mWarning:\033[0m $input_tmp_folder/OPTINFO.DAT file not exist"
			fi
		fi
	fi
else
	opt_file=`ls $input_tmp_folder/opt*$3 2> /dev/null`
	if [ -n "$opt_file" ]; then
	        input_file_gui=$opt_file
	        cp -f  $input_file_gui ${output_file%.*}.gui
	        echo "$input_file_gui saved as ${output_file%.*}.gui"
	else
	        echo -e "\033[31mError:\033[0m $input_tmp_folder/opt*$3 file not exist"
	fi
	if [ -d "$input_fort_folder" ] ; then
	        fort_file=`ls $input_fort_folder/fort.20-*$3 2> /dev/null`
	        if [ -n "$fort_file" ] ; then
	                input_file_f9=$fort_file
	                cp -f  $input_file_f9  ${output_file%.*}.f9
	                echo "$input_file_f9 saved as ${output_file%.*}.f9"
	        else
	                echo -e "\033[33mWarning:\033[0m $input_fort_folder/fort.20 file not exist"
	        fi
	else
		 echo -e "\033[33mWarning:\033[0m FORT directory not exist!"
	fi
	if [ -d "$input_optinfo_folder" ] ; then
	        optinfo_file=`ls $input_optinfo_folder/OPT*$3 2> /dev/null`
	        if [ -n "$optinfo_file" ] ; then
	                input_file_optinfo=$optinfo_file
	                cp -f  $input_file_optinfo ${output_file%.*}.optinfo
	                echo "$input_file_optinfo saved as ${output_file%.*}.optinfo"
	        else
	                echo -e "\033[33mWarning:\033[0m $input_optinfo_folder/OPTINFO.DAT file not exist"
	        fi
	else
		echo -e "\033[33mWarning:\033[0m OPTINFO directory not exist!"
	fi
fi
echo "====================================="
