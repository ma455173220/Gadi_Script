#!/bin/bash
#Submission script generator. It can also give warning when the memory exceeds 4 times of the number of cpu.
#Format of using: script inputfile.d12 SUBMISSION_FILE (PS:the SUBMISSION_FILE is optional)

SCRIPT_DIR=~/runscript


INPUT_FILE=$1
SUBMISSION_FILE=$2

cat <<EOF
*************************************************************************
*********************** The format of the script: ***********************
$0 inputfile.d12 (submission file)
*************************************************************************
EOF

editor_check () {
        if [ $EDITOR_CHOICE -eq '1' ] ; then
                vi $PWD/$SUB_SCRIPT
        elif [ $EDITOR_CHOICE -eq '2' ] ; then
                nano $PWD/$SUB_SCRIPT
        fi
}


if [ -z "$1" ] ; then
	echo -e "\033[31mERROR:\033[0m Missing file operand! Please identify the name of inputfile.d12"
	exit 1
fi

echo -e "Enter the name of the new submission script"
read SUB_SCRIPT
if [ -z "$2" ] ; then
        cp -f $SCRIPT_DIR $PWD/$SUB_SCRIPT
else
        cp -f $2 $PWD/$SUB_SCRIPT
fi

sub_script_first_part=${SUB_SCRIPT%-*}
sub_script_number=`echo "$SUB_SCRIPT" | awk -F '-' '{print $NF}'`
next_sub_script_number=$(printf "%02d\n" $(expr $sub_script_number + 1))
next_sub_script=$sub_script_first_part-$next_sub_script_number

sed -i "0,/ep0/s//$PROJECT/" $SUB_SCRIPT
sed -i "s/TMPFOLDER=\"[^)]*\"/TMPFOLDER=\"tmp-${1%.*}\"/" $SUB_SCRIPT
sed -i "s/JOBNAME=\"[^)]*\"/JOBNAME=\"${1%.*}\"/" $SUB_SCRIPT
sed -i "s/SCRIPTNAME=\"[^)]*\"/SCRIPTNAME=\"$SUB_SCRIPT\"/" $SUB_SCRIPT
sed -i "s/NEXT_SCRIPTNAME=\"[^)]*\"/NEXT_SCRIPTNAME=\"$next_sub_script\"/" $SUB_SCRIPT


echo -e "Which text editor are you using?\n1 vi/vim\n2 nano"
read EDITOR_CHOICE

editor_check

CPU_NUMBER=`grep '#PBS -l ncpus' $SUB_SCRIPT | awk -F '=' '{print $NF}'`
CPU_NUMBER_4TIMES=`expr $CPU_NUMBER \* 4`
MEMORY=`grep '#PBS -l mem' $SUB_SCRIPT | awk -F '=' '{print $(NF)}' | tr -cd "[0-9]"`
while [ $MEMORY -gt $CPU_NUMBER_4TIMES ] ; do
	echo "========================================"
	echo -e "\033[31mWARNING:\033[0m The memory you applied has exceeded 4 times the number of cpus! Do you want to continue or re-edit the submission script?\n1 Continue\n2 Re-edit"
	read CONTINUE_OR_EDIT_CHOICE
	if [ $CONTINUE_OR_EDIT_CHOICE -eq '1' ] ; then
		break
	elif [ $CONTINUE_OR_EDIT_CHOICE -eq '2' ] ; then
		editor_check
	fi
	CPU_NUMBER=`grep '#PBS -l ncpus' $SUB_SCRIPT | awk -F '=' '{print $NF}'`
	CPU_NUMBER_4TIMES=`expr $CPU_NUMBER \* 4`
	MEMORY=`grep '#PBS -l mem' $SUB_SCRIPT | awk -F '=' '{print $(NF)}' | tr -cd "[0-9]"`
done

echo -e "Do you want to submit the script?\n1 YES\n2 NO"
read SUBMIT_CHOICE
if [ $SUBMIT_CHOICE -eq '1' ] ; then
	echo -e "\n========================================\nSubmission in process, please wait...\n..."
	echo "qsub $SUB_SCRIPT"
	/opt/pbs/default/bin/qsub $SUB_SCRIPT && echo -e "\nJob submitted!\n========================================"
else
	echo -e "\n========================================\nDone!\n========================================"
fi
