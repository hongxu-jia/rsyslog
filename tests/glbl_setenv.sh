#!/bin/bash
# This is part of the rsyslog testbench, licensed under ASL 2.0
. $srcdir/diag.sh init
generate_conf
add_conf '
global(environment="http_proxy=http://127.0.0.1")

set $!prx = getenv("http_proxy");

template(name="outfmt" type="string" string="%$!prx%\n")
:msg, contains, "msgnum:" action(type="omfile" template="outfmt"
			         file="rsyslog.out.log")
'
startup
. $srcdir/diag.sh injectmsg  0 1
shutdown_when_empty # shut down rsyslogd when done processing messages
wait_shutdown    # we need to wait until rsyslogd is finished!

echo 'http://127.0.0.1' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid content seen, rsyslog.out.log is:"
  cat rsyslog.out.log
  error_exit 1
fi;

exit_test
