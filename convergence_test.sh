#!/bin/bash
 
shrink="1 3 4 5 6"
tolinteg="5 6 7 8" 

cat <<EOF
*************************************************************************
*********************** The format of the script: ***********************
$0 inputfile.d12
*************************************************************************
EOF


input_file=$1
gui_file=${input_file%.*}.gui
fort_file=${input_file%.*}.f9
opt_file=${input_file%.*}.optinfo

if [[ -z $1 ]] ; then
	echo -e "\033[31mERROR:\033[0m Missing file operand! Please identify the name of inputfile.d12"
	exit 1
fi

echo -e "Which function do you want to use?\n1: SHRINK_TEST\n2: TOLINTEG_TEST\n3: JOB_KILL"
read function_choose


shrink_test_generator () {
	echo "Set the submission script"
	read script_submission
	local i
	for i in $shrink ; do
	    work_dir=shrink_${i}
	    if [ ! -d $work_dir ] ; then
	        mkdir $work_dir
	    else
	        rm -rf $work_dir/*
	    fi
	    sed -e "/SHRINK/{n;s/[^)]*/$i $i/;}" $input_file > $work_dir/$input_file
	    [[ -e $gui_file ]] && cp -f $gui_file $work_dir/$gui_file
	    [[ -e $fort_file ]] && cp -f $fort_file $work_dir/$fort_file
	    [[ -e $opt_file ]] && cp -f $opt_file $work_dir/$opt_file
	    cp -f $script_submission $work_dir/$script_submission
	    cd $work_dir
	    echo "qsub $script_submission"
	    qsub $script_submission
	    cd ..
	done
}

tolinteg_test_generator (){
	echo "Set the submission script"
	read script_submission
	local i
        for i in $tolinteg ; do
            work_dir=tol_${i}
            if [ ! -d $work_dir ] ; then
                mkdir $work_dir
            else
                rm -rf $work_dir/*
            fi
	    sed -e "/TOLINTEG/{n;s/[^)]*/$i $i $i $i $(($i * 2))/;}" $input_file > $work_dir/$input_file
            [[ -e $gui_file ]] && cp -f $gui_file $work_dir/$gui_file
            [[ -e $fort_file ]] && cp -f $fort_file $work_dir/$fort_file
            [[ -e $opt_file ]] && cp -f $opt_file $work_dir/$opt_file
	    cp -f $script_submission $work_dir/$script_submission
            cd $work_dir
	    echo "qsub $script_submission"
            qsub $script_submission
            cd ..
        done
}

job_kill () {
	local i
	local directory_list
	local PBS_ID
	local PBS_ID_NUMBER
	directory_list=`ls -d shrink*/ 2>/dev/null || ls -d tol*/`
	for i in $directory_list ; do
		STATUS_TEST=`grep '.gadi-pbs' $i/${input_file%.*}.out 2>/dev/null`
		if [[ -n $STATUS_TEST ]] ; then
			PBS_ID_NUMBER=`grep '.gadi-pbs' $i/${input_file%.*}.out | cut -d '/' -f 3 | wc -l`
			PBS_ID=`grep '.gadi-pbs' $i/${input_file%.*}.out | cut -d '/' -f 3`
			if [[ $PBS_ID_NUMBER -eq 2 ]] ; then
				echo "$i job finished"
			else
				echo "qdel $PBS_ID"
				qdel $PBS_ID
			fi
		else
			echo "$i job not started!"
		fi
	done
}

case "$function_choose" in
	1)	shrink_test_generator ;;
	2)	tolinteg_test_generator ;;
	3)	job_kill ;;
esac
