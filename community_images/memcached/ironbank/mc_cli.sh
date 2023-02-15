#!/usr/bin/env expect

# shellcheck disable=SC1091
set env(HOME) /usr/local/bin
set env(SHELL) /bin/bash
set env(TERM) xterm
set timeout 3

# Destination IP address
set HOST [lindex ${argv} 0]

# Destination Port
set PORT [lindex ${argv} 1]

# Memcached commands
set COMMAND [lindex ${argv} 2]

# Usage instructions if no arguments supplied.
if { ${argc} < 1 } {
	send_user "Usage: ${argv0} <host> <port> \[command\]\n"
	send_user "e.g.   ${argv0} 127.0.0.1 11211 \"stats settings\"\n"
	send_user "       ${argv0} 127.0.0.1 11211 \"set key_name 0 60 10\"$'\\n'\"0123456789\"\n"
	send_user "       ${argv0} 127.0.0.1 11211 \"get key_name\"\n\n"
	exit 1
}

if {
	[info exists PORT]
	&& "${PORT}" == ""
} {
	set PORT "11211"
}

if {
	[info exists COMMAND]
	&& "${COMMAND}" == ""
} {
	set COMMAND "stats"
}

log_user 0
spawn telnet ${HOST} ${PORT}
expect {
	default {
		send_user "ERROR: Unable to connect to ${HOST} ${PORT}\n"
		exit 1
	}
	"'^]'." {
		log_user 1
		send "${COMMAND}\n"
		expect {
			-re "(?:DELETED|END|ERROR|NOT_FOUND|STORED|VERSION \[0-9\]+\.\[0-9\]+\.\[0-9\]+)" {
				send "quit\n"
			}
		}
		expect eof
	}
}
