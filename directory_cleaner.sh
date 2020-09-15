#!/bin/bash

echo "Do you want to clean the directory? (y/n)"
read choice

if [ $choice == 'y' ] ; then
	echo "====================================="
	echo "In process..."
	echo "..."
	shopt -s extglob
	rm -rf $PWD/tmp-*/fort.79
	echo "tmp-*/fort.79 removed"
	rm -rf $PWD/tmp-*/fort.20
	echo "tmp-*/fort.20 removed"
	rm -rf $PWD/tmp-*/FORT
	echo "tmp-*/FORT removed"
	rm -rf $PWD/tmp-*/OPTINFO
	echo "tmp-*/OPTINFO removed"
	rm -rf $PWD/tmp-*/OPTINFO.DAT
	echo "tmp-*/OPTINFO.DAT removed"
	rm -rf $PWD/tmp-*/HESSOPT.DAT
	echo "tmp-*/HESSOPT.DAT removed"
	rm -rf $PWD/*.f98
	echo "*.f98 removed"
	last_input_file=`ls -tr *.d12 | tail -1`
	last_input_file_first_part=${last_input_file%.*}
	delete_list="f20 f9"  # Here you can change what files you want to delete (write file extension)
	for i in $delete_list ; do
		ls -t $PWD/*.$i >/dev/null
		if [ $? -eq 0 ] ; then
        		file_count=`ls -t $PWD/*.$i | wc -l`
			file_count1=`expr $file_count - 1`
			last_file=`ls -tr *.$i | tail -1`
			last_file_first_part=${last_file%.*}
			if [ "$last_file_first_part" == "$last_input_file_first_part" ] ; then
				delete_items=`ls -t $PWD/*.$i | tail -$file_count1`
				ls -t $PWD/*.$i | tail -$file_count1 | xargs rm -rf
				for iii in $delete_items ; do
					echo "$iii removed" 
				done
			else
				delete_items=`ls -t $PWD/*.$i`
				ls -t $PWD/*.$i | xargs rm -rf
				for iii in $delete_items ; do
					echo "$iii removed"
				done
			fi
		fi
	done
	if [ -e "${last_input_file_first_part}.f20" ] ; then
		if [ -e "${last_input_file_first_part}.f9" ] ; then
			rm -rf $last_input_file_first_part.f9
			echo "$last_input_file_first_part.f9 removed"
		fi
	fi
	find *.optstory -type d >/dev/null
	if [ $? -eq 0 ]; then
		optstory_list=`find *.optstory -type d`
		for ii in $optstory_list ; do
			optstory_first_part=${ii%.*}
			rm -rf tmp-$optstory_first_part
			echo "tmp-$optstory_first_part removed"
		done
	fi
	echo "====================================="
else
	echo "====================================="
	echo "Script terminated"
	echo "====================================="
fi


