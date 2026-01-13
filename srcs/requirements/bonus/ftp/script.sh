#!/bin/sh

# secret
ftp_passwd=$(cat /run/secrets/ftp_passwd)

if ! id "$ftp_user" &>/dev/null; then

    echo "ftp: creating user"

    adduser -u 1000 -h /var/www/html -s /bin/sh -D "$ftp_user"
    # will set starting dir, and assign a default sh
fi

# set the password
echo "$ftp_user:$ftp_passwd" | chpasswd

# start the server
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
