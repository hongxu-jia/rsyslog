#!/bin/bash
# add 2018-06-29 by Pascal Withopf, released under ASL 2.0
. $srcdir/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="13514" ruleset="ruleset1")

$ErrorMessagesToStderr off
$EscapeControlCharacterTab off

template(name="outfmt" type="string" string="%msg%\n")

ruleset(name="ruleset1") {
	action(type="omfile" file="rsyslog.out.log"
	       template="outfmt")
}

'
startup
. $srcdir/diag.sh tcpflood -m1 -M "\"<167>Mar  6 16:57:54 172.20.245.8 test: before HT	after HT (do NOT remove TAB!)\""
shutdown_when_empty
wait_shutdown

echo ' before HT	after HT (do NOT remove TAB!)' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  error_exit  1
fi;

exit_test
