#!/usr/bin/env sh
# Utility for automating using certbot with haproxy.
#
# Author: Dave Voutila <dave@sisu.io> or <dave.voutila@neo4j.com>
# Inspired by: https://serversforhackers.com/c/letsencrypt-with-haproxy
##############################################################################

INSTALL_ROOT="/etc/ssl/"
LETSENCRYPT_ROOT="/etc/letsencrypt/live/"
CERTBOT_PORT=8888
HAPROXY_USER=haproxy
HAPROXY_GROUP=haproxy

usage() {
	printf "usage: letsencrypt.sh [certonly|renew] [options]\n" 1>&2;
	printf "    New certificates  --> certonly [domain] [email]\n" 1>&2;
	printf "    Renewing existing --> renew [domain]\n" 1>&2;
	exit 1;
}

# HAProxy requires a single PEM file with the fullchain certificate and the
# private key appended at the end. We install it to a deterministic path
# and set permissions on the file so it's not globally readable.
install_cert() {
	domain=$1
	dest=$(realpath "${INSTALL_ROOT}/${domain}");
	certpath=$(realpath "${LETSENCRYPT_ROOT}/${domain}");
	if ! mkdir -p "${dest}"
	then
		exit 1
	fi
	cat "${certpath}/fullchain.pem" "${certpath}/privkey.pem" > "${dest}/${domain}.pem";
	chown "${HAPROXY_USER}:${HAPROXY_GROUP}" "${dest}/${domain}.pem";
	chmod 0600 "${dest}/${domain}.pem";
}

certonly() {
	domain=$1
	email=$2
	certbot-auto certonly -q -n -d "${domain}" --standalone --http-01-address=127.0.0.1 "--http-01-port:${CERTBOT_PORT}" --agree-tos -m "${email}"
	install_cert "${domain}"
}

renew() {
	domain=$1
	email=$2
	certbot-auto renew -q --standalone --http-01-address=127.0.0.1 "--http-01-port=${CERTBOT_PORT}"
	install_cert "${domain}"
}

if [ $# -eq 3 ]; then
	case $1 in
		certonly)
			certonly "$2" "$3";
			exit 0;
			;;
	esac
elif [ $# -eq 2 ]; then
	case $1 in
		renew)
			renew "$2" "$3";
			exit 0;
			;;
	esac
fi
usage;
