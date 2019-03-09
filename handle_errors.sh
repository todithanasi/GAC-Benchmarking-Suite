#!/bin/bash
# ------------------------------------------------------------------------------
# 
# Todi THANASI
#
# handle_errors.sh
#
# Parameters:
# Error Codes
#   0   = no error
#   1   = wrong parameter value
#   2   = invalid path
#   3   = wrong file format
#   *   = other errors are from command line processors
#
#
# Description:
# This script is used to print the Returncode and a Error message.
#
# This Script can called by another!
#




# clean parameters
set --


# ------------------------------------------------------------------------------
# Error handling
# ------------------------------------------------------------------------------
echo ""
echo "************************************************************************"
echo "*                                                                      *"
echo "*                      Script was not successful                       *"
echo "*                                                                      *"
echo "************************************************************************"
echo "Returncode: $BENCH_ERROR"
echo "Message   : $BENCH_ERRORMSG"
exit $BENCH_ERROR


# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
