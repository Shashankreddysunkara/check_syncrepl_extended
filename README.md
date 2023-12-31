NOTE: This is an updated repo with my applied fix on "sizelimit exceeded" error which is mis-handled in original repo https://gitea.zionetrix.net/bn8/check_syncrepl_extended. 

# Script to check LDAP syncrepl replication state between two servers
This script check LDAP syncrepl replication state between two servers.
One server is consider as provider and the other as consumer.

This script can check replication state with two method :
 - by the fisrt, entryCSN of all entries of LDAP directory will be compare between two servers
 - by the second, all values of all atributes of all entries will be compare between two servers.

In all case, contextCSN of servers will be compare and entries not present in consumer or in provider will be notice. You can decide to disable contextCSN verification by using argument *--no-check-contextCSN*.

This script is also able to *"touch"* LDAP object on provider to force synchronisation of this object. This mechanism consist to add *'%%TOUCH%%'* value to an attribute of this object and remove it just after. The
touched attribute is specify by parameter *--touch*. Of course, couple of DN and password provided, must have write right on this attribute.

If your prefer, you can use *--replace-touch* parameter to replace value of touched attribute instead of adding the touched value. Use-ful in case of single-value attribute.

To use this script as an Icinga (or Nagios) plugin, use *-n* argument

## Requirement

A single couple of DN and password able to connect to both server and without restriction to retrieve objects from servers.

## Dependencies

* python 3 (for python 2.7 compatibility, see python2.7 branch)
* python-ldap

## Installation

### If you plan to use it with NRPE
```
apt install -y python3-ldap git
git clone https://gitea.zionetrix.net/bn8/check_syncrepl_extended.git /usr/local/src/check_syncrepl_extended
mkdir -p /usr/local/lib/nagios/plugins
ln -s /usr/local/src/check_syncrepl_extended/check_syncrepl_extended /usr/local/lib/nagios/plugins/
cat << EOF > /etc/nagios/nrpe.d/ldap-syncrepl.cfg
command[check_syncrepl_extended]=/usr/local/lib/nagios/plugins/check_syncrepl_extended --nagios --attributes --provider ldaps://ldapmaster.foo --consumer ldaps://ldapslave.foo --basedn o=example -D uid=nagios,ou=sysaccounts,o=example -P secret
EOF
service nagios-nrpe-server reload
```

### Otherwise
```
apt install python3-ldap git
git clone https://gitea.zionetrix.net/bn8/check_syncrepl_extended.git /usr/local/src/check_syncrepl_extended
ln -s /usr/local/src/check_syncrepl_extended/check_syncrepl_extended /usr/local/bin/
```

## Usage
```
usage: check_syncrepl_extended [-h] [-v] [-p PROVIDER] [-c CONSUMER]
                               [-i SERVERID] [-T] [-D DN] [-P PWD] [-b BASEDN]
                               [-f FILTERSTR] [-d] [-n] [-q]
                               [--no-check-certificate]
                               [--no-check-contextCSN] [-a]
                               [--exclude-attributes EXCL_ATTRS]
                               [--touch TOUCH] [--replace-touch]
                               [--remove-touch-value] [--page-size PAGE_SIZE]

Script to check LDAP syncrepl replication state between two servers.

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         show program's version number and exit
  -p PROVIDER, --provider PROVIDER
                        LDAP provider URI (example:
                        ldaps://ldapmaster.foo:636)
  -c CONSUMER, --consumer CONSUMER
                        LDAP consumer URI (example: ldaps://ldapslave.foo:636)
  -i SERVERID, --serverID SERVERID
                        Compare contextCSN of a specific master. Useful in
                        MultiMaster setups where each master has a unique ID
                        and a contextCSN for each replicated master exists. A
                        valid serverID is a integer value from 0 to 4095
                        (limited to 3 hex digits, example: '12' compares the
                        contextCSN matching '#00C#')
  -T, --starttls        Start TLS on LDAP provider/consumers connections
  -D DN, --dn DN        LDAP bind DN (example:
                        uid=nagios,ou=sysaccounts,o=example
  -P PWD, --pwd PWD     LDAP bind password
  -b BASEDN, --basedn BASEDN
                        LDAP base DN (example: o=example)
  -f FILTERSTR, --filter FILTERSTR
                        LDAP filter (default: (objectClass=*))
  -d, --debug           Debug mode
  -n, --nagios          Nagios check plugin mode
  -q, --quiet           Quiet mode
  --no-check-certificate
                        Don't check the server certificate (Default: False)
  --no-check-contextCSN
                        Don't check servers contextCSN (Default: False)
  -a, --attributes      Check attributes values (Default: check only entryCSN)
  --exclude-attributes EXCL_ATTRS
                        Don't check this attribut (only in attribute check
                        mode)
  --touch TOUCH         Touch attribute giving in parameter to force resync a
                        this LDAP object from provider. A value '%TOUCH%' will
                        be add to this attribute and remove after. The user
                        use to connect to the LDAP directory must have write
                        permission on this attribute on each object.
  --replace-touch       In touch mode, replace value instead of adding.
  --remove-touch-value  In touch mode, remove touch value if present.
  --page-size PAGE_SIZE
                        Page size: if defined, paging control using LDAP v3
                        extended control will be enabled.

# Author: Benjamin Renard <brenard@easter-eggs.com>
# Reference Source (Without applied fix): https://gitea.zionetrix.net/bn8/check_syncrepl_extended
#
# Author: Shashank Reddy Sunkara <https://shashankreddysunkara.github.io/blog/contact.html>
# Source (Applied fix): https://github.com/Shashankreddysunkara/check_syncrepl_extended/blob/main/check_syncrepl_extended
```

## Copyright

Copyright (c) 2017 Benjamin Renard

## License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
