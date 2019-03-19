#!/bin/bash

path=${1}
proname=${2}
args=${3}
ret=0


# Check if the directory exists
if [ -d $path ]
then
    cd $path
else
    echo "The directory <$path> is not exist"
    echo
    echo "END OF BASICCHECK: 4"
    exit 4
fi
#--------------------------------------------------------------------


# Checking if the makefile exists and compilation success
if [ -f Makefile ] || [ -f makefile ]
then
    # Rebuild
    make clean
    make

    # Checking compilation success
    if [ $? -ne 0 ]
    then
        echo "Compilation error, please check the Makefile"
        echo
        echo "END OF BASICCHECK: 4"
        exit 4
    fi

    if ! [ -x $proname ]
    then
        echo "The argument name does not equal the name of the application"
        echo
        echo "END OF BASICCHECK: 4"
        exit 4
    fi
            
else
    echo "The Makefile does not exist"
    echo
    echo "END OF BASICCHECK: 4"
    exit 4
fi
#--------------------------------------------------------------------

echo
echo

# Checking the leak memory
echo "Start leak check----------------------------------------------------------"
valgrind --leak-check=yes --error-exitcode=1 ./main $args 2>&1
if [ $? -eq 1 ]
then
    ret=$(( $ret | 2 )) # leak-check error
fi
echo "End leak check------------------------------------------------------------"
#--------------------------------------------------------------------

echo
echo

# Checking the thread errors
echo "Start thread check--------------------------------------------------------"
valgrind --tool=helgrind --error-exitcode=1 ./main $args 2>&1
if [ $? -eq 1 ]
then
    ret=$(( $ret | 1 )) # thread error
fi
echo "End thread check----------------------------------------------------------"
#--------------------------------------------------------------------

echo
echo "END OF BASICCHECK: $ret"


exit $ret