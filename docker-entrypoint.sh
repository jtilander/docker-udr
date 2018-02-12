#!/bin/sh
set -e

export VERBOSE=${VERBOSE:-1}
export REMOTEPORT=${REMOTEPORT:-2222}
export REMOTE_UDT=${REMOTE_UDT:-9000}
export LOCAL_UDT=${LOCAL_UDT:-9000}
export SSHD_PORT=${SSHD_PORT:-2222}

cat > /etc/udrd.conf <<EOM
address = 0.0.0.0
server port = ${LOCAL_UDT}
start port = ${REMOTE_UDT}
end port = ${REMOTE_UDT}
log file = /tmp/udr.log
pid file = /tmp/udr.pid
log level = DEBUG
udr = /bin/udr
rsyncd conf = /etc/rsyncd.conf
uid = root
gid = root
EOM

cat > /etc/rsyncd.conf <<EOM
use chroot = yes
numeric ids = yes
read only = no
EOM

cat > /etc/supervisord.conf <<EOM
[unix_http_server]
file=/run/supervisord.sock

[supervisord]
logfile=/var/log/supervisord.log
logfile_maxbytes=50MB
logfile_backups=10
loglevel=info
pidfile=/run/supervisord.pid
nodaemon=true

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///run/supervisord.sock

[program:sshd]
command=/usr/sbin/sshd -D -e -p ${SSHD_PORT}
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true

[program:udrd]
command=/usr/bin/python -u /udr/udrserver.py -v -c /etc/udrd.conf foreground
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
EOM


if [ "$1" = "udr" ]; then
	shift
	REMOTEHOST=$1

cat > /root/.ssh/config <<EOM
Host ${REMOTEHOST}
	HostName ${REMOTEHOST}
	Port ${REMOTEPORT}
	User root
	UserKnownHostsFile /dev/null
	StrictHostKeyChecking no
EOM

	exec /bin/udr -a ${LOCAL_UDT} -b ${REMOTE_UDT} -c /bin/udr -P ${REMOTEPORT} -v -l root rsync -avz /workspace ${REMOTEHOST}:/workspace/
fi

if [ "$1" = "daemon" ]; then
	shift

	# Get the keys from URL
	mkdir -p /root/.ssh
	curl -SsL -o /root/.ssh/authorized_keys "${KEYS_URL}"
	chmod 0744 /root/.ssh/authorized_keys

	ssh-keygen -A

	exec /usr/bin/supervisord -n -c /etc/supervisord.conf
fi

exec "$@"
