#!/bin/bash
# addd 2016-05-13 by RGerhards, released under ASL 2.0

. $srcdir/diag.sh init
generate_conf
add_conf '
$MaxMessageSize 128
global(processInternalMessages="on"
	oversizemsg.input.mode="accept")
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="13514")

action(type="omfile" file="rsyslog.out.log")
'
startup
. $srcdir/diag.sh tcpflood -m1 -M "\"<120> 2011-03-01T11:22:12Z host tag: this is a way too long message that has ab
9876543210 cdefghijklmn test8 test9 test10 test11 test12 test13 test14 test15 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk tag: testtesttesttesttesttesttesttesttest\""
shutdown_when_empty
wait_shutdown

grep "Framing Error in received" rsyslog.out.log > /dev/null
if [ $? -ne 0 ]; then
        echo
        echo "FAIL: expected error message from imtcp not found. rsyslog.out.log is:"
        cat rsyslog.out.log
        error_exit 1
fi

grep "9876543210cdefghijklmn test8 test9 test10 test11 test12 test13 test14 test15 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk tag: testtestt" rsyslog.out.log > /dev/null
if [ $? -ne 0 ]; then
        echo
        echo "FAIL: expected date from imtcp not found. rsyslog.out.log is:"
        cat rsyslog.out.log
        error_exit 1
fi

exit_test
