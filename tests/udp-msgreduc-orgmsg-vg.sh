#!/bin/bash
# check if valgrind violations occur. Correct output is not checked.
# added 2011-03-01 by Rgerhards
# This file is part of the rsyslog project, released  under GPLv3

uname
if [ `uname` = "FreeBSD" ] ; then
   echo "This test currently does not work on FreeBSD."
   exit 77
fi

echo ===============================================================================
echo \[udp-msgreduc-orgmsg-vg.sh\]: testing msg reduction via udp, with org message
. $srcdir/diag.sh init
generate_conf
add_conf '
$ModLoad ../plugins/imudp/.libs/imudp
$UDPServerRun 13514
$RepeatedMsgReduction on
$RepeatedMsgContainsOriginalMsg on

$template outfmt,"%msg:F,58:2%\n"
*.*  ./rsyslog.out.log;outfmt
'
startup_vg
. $srcdir/diag.sh wait-startup
. $srcdir/diag.sh tcpflood -t 127.0.0.1 -m 4 -r -Tudp -M "\"<133>2011-03-01T11:22:12Z host tag msgh ...\""
. $srcdir/diag.sh tcpflood -t 127.0.0.1 -m 1 -r -Tudp -M "\"<133>2011-03-01T11:22:12Z host tag msgh ...x\""
shutdown_when_empty # shut down rsyslogd when done processing messages
wait_shutdown_vg
if [ "$RSYSLOGD_EXIT" -eq "10" ]
then
	echo "udp-msgreduc-orgmsg-vg.sh FAILED"
	exit 1
fi
exit_test
