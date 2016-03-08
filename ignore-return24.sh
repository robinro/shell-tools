#!/bin/bash

# this script is a wrapper for rsnapshot to ignore output of "files vanished"
# rsnapshot uses rsync for the transfer ans rsync fails with code 24 when files "vanish" during the transfer
# in most setups this is harmless and can therefore be ignored
# there is a wrapper for rsync itself: https://bugzilla.samba.org/show_bug.cgi?id=10356

# the workflow of this script is
# - run the argument (assumed: rsnapshot)
# - catch output and exit code
# - if exit code 2 and all lines contain "vanished" or exit code 0, all output is suppressed
# - otherwise pass through the original output and exit code

# usage:
# ignore-return24.sh rsnapshot hourly 
# or whatever arguemnt you'd like to use

tmplog=`mktemp`
"$@" >&${tmplog}
status=$?
if (( "$status" == 2 )); then
	# rsnapshot return code 2 corresponds to "warning"
	# happens when rsync returns 24
	if ! grep -v vanished ${tmplog} >& /dev/null ; then
		# make sure only lines containing "vanished" are in the output
		rm ${tmplog}; exit 0
	else
		cat ${tmplog}; rm ${tmplog}; exit $status
	fi

elif (( "$status" == 0 )); then
	# successful run
	rm ${tmplog}; exit 0
fi
cat ${tmplog}; rm ${tmplog}; exit $status

