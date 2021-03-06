#!/bin/bash

#	Autor: Levi Barroso Menezes
#	Data de criação: 26/03/2019
#	Versão: 0.08
#	Samba
	
#	Variável do servidor:
	NOME="smb01"
	DOMINIO="thz.intra"
	FQDN="$NOME.$DOMINIO"

#	Variáveis de Rede
	INTERFACE0="enp0s3"
	DHCP0v4="false"
	IP0v4="172.20.0.10"
	MASCARA0v4="/16"
	GATEWAY0v4="172.20.0.1"
	DHCP0v6="true"
	INTERFACE1="enp0s8"
	DHCP1v4="false"
	IP1v4="10.0.0.20"
	MASCARA1v4="/8"
	GATEWAY1v4="10.10.0.1"
	DHCP1v6="true"
	DNSEX0="8.8.8.8"
	DNSEX1="4.4.8.8"
	DNSEX2="208.67.222.222"
	DNSEX3="208.67.222.220"
#	variáveis do script
	HORAINICIAL=`date +%T`
	LOG="/var/log/$(echo $0 | cut -d'/' -f2)"

#	Variáveis do Samba
	USUARIO="supremo"
	SENHA="P@ssword"
	REINO="THZ.INTRA"
	DNSBE="BIND9_DLZ"
	REGRA="dc"
	LEVEL="2008_R2"
	SMBDOMINIO="THZ"
	DNSENCAMINHADO="8.8.8.8"

#	Variaáveis do DNS
	ARPA="20.172.in-addr.arpa"
	ARPAIP="10.0"
	ZONANOME='"smb01"'
	ZONADOMINIO='"thz.intra"'
	ZONAFQDN='"$NOME.$DOMINIO"'
	ZONADIRFILE='"etc/bind/db.thz.intra"'
	ZONAREVFILE='"etc/bind/db.20.172.in-addr.arpa"'
	ZONAARPA='""20.172.in-addr.arpa""'

#	Exportando o recurso de Noninteractive:
	export DEBIAN_FRONTEND="noninteractive"

#	Registrar inicio dos processos:
	rm $LOG &> $LOG
	echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG

#	Configurar interfaces de rede:
	mv /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bkp
	printf "
network:
    version: 2
    renderer: networkd
    ethernets:
        $INTERFACE0:
            dhcp4: $DHCP0v4
            dhcp6: $DHCP0v6
            addresses: [$IP0v4$MASCARA0v4]
            gateway4: $GATEWAY0v4
            nameservers:
                addresses: [$IP0v4, $DNSEX0, $DNSEX1]
                search: [$DOMINIO]
        $INTERFACE1:
            dhcp4: $DHCP1v4
            dhcp6: $DHCP1v6
            addresses: [$IP1v4$MASCARA1v4]
            gateway4: $GATEWAY1v4
            nameservers:
                addresses: [$IP1v4, $DNSEX0, $DNSEX1]
                search: [$DOMINIO]
#	" > /etc/netplan/01-netcfg.yaml
	netplan --debug apply &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Configurações de rede ..."
	sleep 1

#	Auterar nome do servidor (hostname):
	rm /etc/hostname
	printf "$NOME" > /etc/hostname
	echo -e "[ \033[0;32m OK \033[0m ] Nome do servidor ..."
	sleep 1
	
#	Auterar resolução de nome interna (hosts):
	rm /etc/hosts
	printf "
#IP versão 4
$IP0v4			$FQDN	$NOME
127.0.1.1		$FQDN	$NOME
127.0.0.1		localhost.localdomain	localhost

#IP versão 6
$IP0v6			$FQDN	$NOME
fe00::0			ip6-localnet
ff02::1			ip6-allnodes
ff02::2			ip6-allrouters
ff02::3			ip6-allhosts
::1				localhost	ip6-localhost	ip6-loopback

#	" > /etc/hosts
	echo -e "[ \033[0;32m OK \033[0m ] Resolução de nome interna ..."
	sleep 1
	
#	Auterar resolução de nomes externa (resolv.conf):
	rm /etc/resolv.conf
	printf "
nameserver $IP0v4
#nameserver 127.0.0.53
#options edns0
search $DOMINIO
domain $DOMINIO
#	" > /etc/resolv.conf
	echo -e "[ \033[0;32m OK \033[0m ] Resolução de nome externa ..."
	sleep 1

#	Padronização:
	bash base.sh
	bash extra.sh

#	Instalar python
	apt -y -q install python-all-dev python-crypto python-dbg python-dev python-dnspython python3-dnspython python-gpg python3-gpg python-markdown python3-markdown python3-dev &>> $LOG
#	apt -y -q install python-dev  python-dnspython &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Python ..."
	sleep 1

#	Instalar perl
	apt -y -q install perl perl-modules libparse-yapp-perl libjson-perl &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Perl ..."
	sleep 1
	
#	Instalar winbind
	apt -y -q install winbind libnss-winbind libpam-winbind &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Winbind ..."
	sleep 1

#	Instalar recursos usados pelo samba
	apt -y -q install acl attr autoconf figlet debconf-utils bison build-essential debhelper dnsutils docbook-xml docbook-xsl flex gdb xsltproc lmdb-utils pkg-config ldb-tools unzip kcc tree &>> $LOG
#	apt -y -q install acl attr figlet debconf-utils build-essential gdb pkg-config docbook-xsl dnsutils ldb-tools unzip kcc tree &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Recursos usados pelo samba ..."
	sleep 1

#	Instalar bibliotecas:	
	apt -y -q install libsystemd-dev libacl1-dev libaio-dev libarchive-dev libattr1-dev libcap-dev libcups2-dev libgnutls28-dev libgpgme-dev zlib1g-dev liblmdb-dev libjansson-dev libldap2-dev libncurses5-dev libpam0g-dev libpopt-dev libreadline-dev nettle-dev libblkid-dev libbsd-dev libjansson-dev &>> $LOG
#	apt -y -q install libpam0g-dev libacl1-dev libattr1-dev libblkid-dev libgnutls28-dev libreadline-dev libpopt-dev libldap2-dev libbsd-dev &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Bibliotécas ..."
	sleep 1
	
#	Instalar bind9
	apt -y -q install bind9utils &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Bind9 ..."
	sleep 1
	
#	Configurar Bind9
	mv /etc/bind/named.conf.options /etc/bind/named.conf.options.bkp
	printf " 
	options {
		directory "/var/cache/bind";
		forwarders {
			DNSEX0;
			DNSEX1;
			DNSEX2;
			DNSEX3;
		};
		dnssec-validation auto;
		auth-nxdomain yes;
		empy-zones-enable no;
		listen-on-v6 { any; };
	};	
	" > /etc/bind/named.conf.options
	
	mv /etc/bind/named.conf.local /etc/bind/named.conf.local.bkp
	printf "
	zone $ZONADOMINIO{
			type master;
			file $ZONADIRFILE;
	};	
	zone $ZONAARPA{
			type master;
			file $ZONAREVFILE;
	};	
	" > /etc/bind/named.conf.local
	echo -e "[ \033[0;32m OK \033[0m ] Configuração bind9 ..."
	sleep 1
	
#	Criar zona direta do dominio
	printf ";
	$TTL    604800
	@       	IN      SOA     $FQDN.		admin.$DOMINIO.	 (
								2					; Serial
								604800        		; Refresh
								86400         		; Retry
								2419200         	; Expire
								604800 )       		; Negative Cache TTL
	;
	@       	IN      NS      $FQDN.
	@       	IN      A       $IP0v4
	$NOME		IN		A		$IP0v4
	@       	IN      AAAA    ::1
	" > etc/bind/db.thz.intra
	echo -e "[ \033[0;32m OK \033[0m ] Zona direta do dominio ..."
	sleep 1

#	Criar zona reversa do dominio
	printf ";
	$TTL    604800
	@       	IN      SOA     $FQDN.		admin.$DOMINIO.	 (
								1809201402			; Serial
								604800        		; Refresh
								86400         		; Retry
								2419200         	; Expire
								604800 )       		; Negative Cache TTL
	;
	@       	IN      NS      $NOME.
	$ARPAIP    	IN      PTR		$DOMINIO.
	$ARPAIP    	IN      PTR		$FQDN.
	" > etc/bind/db.20.172.in-addr.arpa
	systemctl restart bind9.service
	echo -e "[ \033[0;32m OK \033[0m ] Zona reversa do dominio ..."
	sleep 1
	
#	Incluir samba no bind
	printf "
	include "/etc/bind/named.conf.options";
	include "/etc/bind/named.conf.local";
	include "/etc/bind/named.conf.default-zones";
	include "/usr/share/samba/setup/named.conf.dlz";
	" > /etc/bind/named.conf
	echo -e "[ \033[0;32m OK \033[0m ] Samba incluso no bind9 ..."
	sleep 1
	
#	Instalar e configurar kerberos:
	mv /etc/krb5.conf /etc/krb5.conf.bkp
	debconf-show krb5-config &>> $LOG
	apt -y -q install krb5-user krb5-kdc krb5-config &>> $LOG
	echo "krb5-config krb5-config/default_realm string $REINO" | debconf-set-selections
	echo "krb5-config krb5-config/kerberos_servers string $FQDN" | debconf-set-selections
	echo "krb5-config krb5-config/admin_server string $FQDN" | debconf-set-selections
	echo "krb5-config krb5-config/add_servers_realm string $REINO" | debconf-set-selections
	echo "krb5-config krb5-config/add_servers boolean true" | debconf-set-selections
	echo "krb5-config krb5-config/read_config boolean true" | debconf-set-selections
	echo -e "[ \033[0;32m OK \033[0m ] Kerberos ..."
	sleep 1

#	Configurar kerberos:
	printf "
[libdefaults]
# 	Realm padrão
	default_realm = $REINO
 
#	Opções utilizadas pela SAMBA4
	dns_lookup_realm = false
	dns_lookup_kdc = true
 
#	Confguração padrão do Kerneros
	krb4_config = /etc/krb.conf
	krb4_realms = /etc/krb.realms
	kdc_timesync = 1
	ccache_type = 4
	forwardable = true
	proxiable = true
	v4_instance_resolve = false
	v4_name_convert = {
		host = {
			rcmd = host
			ftp = ftp
		}
		plain = {
			something = something-else
		}
	}
	fcc-mit-ticketflags = true
 
#	Reino padrão
[realms]
	$REINO = {
		# Servidor de geração de KDC
		kdc = $FQDN
		#
		# Servidor de Administração do KDC
		admin_server = $FQDN
		#
		# Domínio padrão
		default_domain = $DOMINIO
	}
 
#	Domínio Realm
[domain_realm]
	.$DOMINIO = $REINO
	$DOMINIO = $REINO
 
#	Geração do Tickets
[login]
	krb4_convert = true
	krb4_get_tickets = false
 
#	Log dos tickets do Kerberos
[logging] 
	default = FILE:/var/log/krb5libs.log 
	kdc = FILE:/var/krb5/krb5kdc.log 
	admin_server = FILE:/var/log/krb5admin.log
	" > /etc/krb5.conf
	echo -e "[ \033[0;32m OK \033[0m ] Configuração kerberos ..."
	sleep 1

#	Configurar ponte nsswitch:
	mv /etc/nsswitch.conf /etc/nsswitch.conf.bkp
	printf "
#	Habilitar os recursos de files (arquivos) e winbind (integração) SAMBA+GNU/Linux
passwd:         files compat systemd winbind
group:          files compat systemd winbind
shadow:         files compat systemd winbind
gshadow:        files
passwd_compat:	nis
group_compat:	nis
shadow_compat:	nis


#	Configuração de resolução de nomes
#	Habilitar o recursos de dns depois de files (arquivo hosts)
hosts:          nis [NOTFOUND=return] files	dns	mdns4_minimal [NOTFOUND=return]

#	Configurações padrão.
services:   	nis 	[NOTFOUND=return] files
networks:   	nis 	[NOTFOUND=return] files
protocols:  	nis 	[NOTFOUND=return] files
rpc:        	nis 	[NOTFOUND=return] files
ethers:     	nis 	[NOTFOUND=return] files
netmasks:   	nis 	[NOTFOUND=return] files
netgroup:   	nis 	[NOTFOUND=return] files
bootparams: 	nis 	[NOTFOUND=return] files
publickey:  	nis 	[NOTFOUND=return] files
automount:  	files
aliases:    	nis 	[NOTFOUND=return] files
	" > /etc/nsswitch.conf
	echo -e "[ \033[0;32m OK \033[0m ] Nsswitch ..."
	sleep 1

#	Instalar SAMBA4:
	apt -y -q install samba samba-common smbclient samba-vfs-modules samba-testsuite samba-dsdb-modules &>> $LOG
	apt -y -q install samba samba-common smbclient samba-testsuite &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Samba4 ..."
	sleep 1

#	Provisionar controlador de domínio do active directory:
	systemctl stop samba-ad-dc.service smbd.service nmbd.service &>> $LOG
	mv /etc/samba/smb.conf /etc/samba/smb.conf.old
	sleep 1
	samba-tool domain provision --realm=$REINO --domain=$SMBDOMINIO --server-role=$REGRA --dns-backend=$DNSBE --option="dns forwarder = $IP0v4" --adminpass=$SENHA --function-level=$LEVEL --site=$REINO --host-ip=$IP --use-rfc2307 --use-ntvfs --option="server signing = auto" --option="client use spnego = no" --option="use spnego = no" --option="client use spnego principal = no" &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Provisionamento do controlador de domínio ..."
	
#	Configurar SAMBA4:
	mv /etc/samba/smb.conf /etc/samba/smb.bkp
	printf "
# Global parameters
[global]
        allow dns updates = nonsecure and secure
        bind interfaces only = Yes
        dns forwarder = $IP0v4
        interfaces = lo $INTERFACE0 $INTERFACE1
        netbios name = $NOME
        realm = $REINO
        server role = active directory domain controller
        server signing = if_required
        winbind enum groups = Yes
        winbind enum users = Yes
        winbind refresh tickets = Yes
        winbind use default domain = Yes
        workgroup = $SMBDOMINIO
        idmap_ldb:use rfc2307 = yes
        map acl inherit = Yes
        store dos attributes = Yes
        vfs objects = acl_xattr
#		logon home = \\%L\%U\.profiles
#		logon path = \\%L\profiles\%U
#		hosts allow = 192.168.1. EXCEPT 192.168.1.20

[netlogon]
        path = /var/lib/samba/sysvol/thz.intra/scripts
        read only = No

[sysvol]
        path = /var/lib/samba/sysvol
        read only = No

[profiles]
		path = /var/profiles
		writeable = Yes
		browseable = No
		create mask = 0600
		directory mask = 0700

[impressoras]
		comment = Todas as Impressoras
		path = /var/spool/samba
		guest ok = yes
		public = yes
		printable = yes
		browseable = yes
		use client driver = yes

[arquivos]
		path = /arquivos/arquivos
		available = yes
		writable = no

[publico]
		comment = Pasta Pública
		path = /arquivos/samba_publico
		available = yes
		browseable = yes
		writable = yes
	" > smb.conf
	systemctl unmask samba-ad-dc.service &>> $LOG
	systemctl enable samba-ad-dc.service smbd.service nmbd.service &>> $LOG
	systemctl restart samba-ad-dc.service smbd.service nmbd.service &>> $LOG
	systemctl disable nmbd.service smbd.service winbind.service &>> $LOG
	systemctl mask nmbd.service smbd.service winbind.service &>> $LOG
	
	samba-tool dns zonecreate $FQDN $ARPA -U Administrator --password=$SENHA &>> $LOG
	samba-tool dns add $DOMINIO $ARPA $ARPAIP PTR $FQDN -U Administrator --password=$SENHA &>> $LOG
	samba_dnsupdate --use-file=/var/lib/samba/private/dns.keytab --all-names &>> $LOG
	net rpc rights grant '$SMBDOMINIO\Domain Admins' SeDiskOperatorPrivilege -U $USUARIO%$SENHA &>> $LOG
	samba-tool dbcheck --cross-ncs --fix --yes
	echo -e "[ \033[0;32m OK \033[0m ] Configuração do Controlador de Domínio ..."
	sleep 1
	
#	Criar usuário no dominio:
	samba-tool user create $USUARIO $SENHA --login-shell=/bin/sh --uid-number="10000" --gid-number="10000" --nis-domain=$DOMINIO --unix-home=//smb01/profiles/$USUARIO
	samba-tool group addmembers administrators "$USUARIO"
	samba-tool user setexpiry $USUARIO --noexpiry &>> $LOG
	echo -e "[ \033[0;32m OK \033[0m ] Usuário no Domínio ..."
	sleep 1
	
#	Finalizar
	HORAFINAL=$(date +%T)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	echo -e "Tempo de execução $0: $TEMPO"
	echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
	echo -e "Acesso ao banco de dados: $IP:5432"
	echo -e "\033[0;31m Pode ser nescesario reiniciar o servidor !!! \033[0m" &>> $LOG
	echo -e "Pressione \033[0;32m <Enter> \033[0m para reiniciar ou \033[0;33m <CTRL> + C \033[0m para finalizar o processo."
	read
	reboot 0
exit 1
