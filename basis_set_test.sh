#!/bin/bash
#Using this script your basis sets directories must have same prefix, such BASIS1, BASIS2, BASIS3 ...
#The name of your input files in each directory must be same.

DIR_NAME_PREFIX='BASIS'

shopt -s extglob
DIR_LIST=`ls -d $DIR_NAME_PREFIX*/`

NUMBER_OF_DIR=`ls -d $DIR_NAME_PREFIX*/ | wc -l`

for i in $DIR_LIST ; do
	i=`echo $i | awk -F '/' '{print $1}'`
	ORIGINAL_INPUT_FILE=`ls $i/*d12 | head -1`
	DIR_CHECK_LIST=`ls -d $DIR_NAME_PREFIX*/ | ls -d !($i)`
	for ii in $DIR_CHECK_LIST ; do
		COMPARED_INPUT_FILE=`ls $ii/*d12 | head -1`
		DIFFERENCE=`diff $ORIGINAL_INPUT_FILE $COMPARED_INPUT_FILE`
		if [[ -z $DIFFERENCE ]] ; then
			echo -e "\033[33mSAME\033[0m basis sets between $ii and $i"
		#else
		#	echo "DIFFERENT basis sets between $ii and $i"
		fi
	done
done


#for ((i=1;i<$NUMBER_OF_DIR;i++)) ; do
#	i=`printf "%02d" $i`
#	ORIGINAL_BASIS_SET_DIR=$DIR_NAME_PREFIX${i}/
#	ORIGINAL_INPUT_FILE=`ls $ORIGINAL_BASIS_SET_DIR/*d12 | head -1`
#	DIR_LIST=`ls -d $DIR_NAME_PREFIX*/ | tail -$((NUMBER_OF_DIR - i))`
#	for ii in $DIR_LIST ; do
#		if [[ $ii != $ORIGINAL_BASIS_SET_DIR ]] ; then
#			COMPARED_INPUT_FILE=`ls $ii/*d12 | head -1`
#			DIFFERENCE=`diff $ORIGINAL_INPUT_FILE $COMPARED_INPUT_FILE`
#			if [[ -z $DIFFERENCE ]] ; then
#				echo -e "\033[33mSAME\033[0m basis sets between $ii and $ORIGINAL_BASIS_SET_DIR"
#			else
#				echo "DIFFERENT basis sets between $ii and $ORIGINAL_BASIS_SET_DIR"
#			fi
#		fi
#	done
#done

