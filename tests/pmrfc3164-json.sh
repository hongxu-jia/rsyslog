#!/bin/bash
# add 2017-12-12 by Rainer Gerhards, released under ASL 2.0
. $srcdir/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="13514" ruleset="rs")
template(name="outfmt" type="string" string="%msg%---%rawmsg%\n")

ruleset(name="rs") {
	action(type="omfile" template="outfmt" file="rsyslog.out.log")
}
'
startup
. $srcdir/diag.sh tcpflood -m1 -M "\"{ \\\"c1\\\":1 }\""
. $srcdir/diag.sh tcpflood -m1 -M "\"   { \\\"c2\\\":2 }\""
. $srcdir/diag.sh tcpflood -m1 -M "\"   [{ \\\"c3\\\":3 }]\""
shutdown_when_empty
wait_shutdown
EXPECTED='{ "c1":1 }---{ "c1":1 }
   { "c2":2 }---   { "c2":2 }
   [{ "c3":3 }]---   [{ "c3":3 }]'
echo "$EXPECTED" | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  printf "expected was\n"
  echo "$EXPECTED"
  error_exit  1
fi;

exit_test
