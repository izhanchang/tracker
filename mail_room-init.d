#!/bin/bash
### BEGIN INIT INFO
# Provides:          abtt_mail_room
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: initscript for abtt's background email pulling service
# Description:       This file should be placed in /etc/init.d and added to system startup with update-rc.d abtt_mail_room defaults
### END INIT INFO

NAME=abtt_mail_room

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

start() {
  if [ -f $ABTT_DIR/tmp/pids/email.pid ]; then
    local pids=$(cat $ABTT_DIR/tmp/pids/email.pid)
    if [ -n "$pids" ]; then
      if kill -0 $pids > /dev/null 2>&1; then
        echo "$NAME (pid $pids) is already running"
        return 0
      fi
    fi
  fi
  echo -n "Starting $NAME: "
  BUNDLE_GEMFILE=$ABTT_DIR/Gemfile RAILS_ENV=production nohup /usr/local/rvm/wrappers/abtt/bundle exec rake -f $ABTT_DIR/Rakefile email:idle >> $ABTT_DIR/log/email.log 2>&1 &
  RETVAL=$?
  PID=$!
  echo $PID > $ABTT_DIR/tmp/pids/email.pid
  echo "done"
  return $RETVAL
}

stop() {
  if [ -f $ABTT_DIR/tmp/pids/email.pid ]; then
    local pids=$(cat $ABTT_DIR/tmp/pids/email.pid)
    if [ -n "$pids" ]; then
      echo -n "Stopping $NAME: "
      kill -15 $(cat $ABTT_DIR/tmp/pids/email.pid) && rm -f $ABTT_DIR/tmp/pids/email.pid

      RETVAL=$?

      echo "done"
      return 0
    fi
  fi
  
  echo "$NAME is not running"
  return 0
}

reload() {
    stop
        start
}

# See how we were called.
case "$1" in
  start)
                start
                ;;
  stop)
                stop
                ;;
  status)
    status $prog
                exit $?
        ;;
  restart)
                stop
                start
        ;;
  *)
        echo $"Usage: $prog {start|stop|restart}"
        exit 2
esac
