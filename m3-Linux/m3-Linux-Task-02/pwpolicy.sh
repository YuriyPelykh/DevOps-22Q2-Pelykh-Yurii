#!/usr/bin/env bash

PWLENGTH=8
PWEXPIRE=90
PWREPEAT=3
NLOWCASE=-1
NUPCASE=-1
NDIGITS=-1
NSPECIAL=0


while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--provisioning)
      PROVISION=TRUE
      shift # past argument
      ;;
    --le|--pwlength)
      PWLENGTH="$2"
      shift # past argument
      shift # past value
      ;;
    --ex|--pwexpire)
      PWEXPIRE="$2"
      shift # past argument
      shift # past value
      ;;
    --re|--pwrepeat)
      PWREPEAT="$2"
      shift # past argument
      shift # past value
      ;;
    --nl|--nlowcase)
      NLOWCASE="$2"
      shift # past argument
      shift # past value
      ;;
    --nu|--nupcase)
      NUPCASE="$2"
      shift # past argument
      shift # past value
      ;;
    --nd|--ndigits)
      NDIGITS="$2"
      shift # past argument
      shift # past value
      ;;
    --ns|--nspecial)
      NSPECIAL="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--userconf)
      USERCONF=TRUE
      shift # past argument
      ;;
    --un|--username)
      USERNAME=$2
      shift # past argument
      shift # past value
      ;;
    --em|--useremail)
      USEREMAIL=$2
      shift # past argument
      shift # past value
      ;;
    --cr|--createuser)
      CREATEUSER=TRUE
      shift # past argument
      ;;
    --rm|--rmuser)
      RMUSER=TRUE
      shift # past argument
      ;;
    --du|--disbluser)
      DISABLEUSER=TRUE
      shift # past argument
      ;;
    --fl|--firstlogin)
      FIRSTLOGIN=TRUE
      shift # past argument
      ;;
    --su|--allowsudo)
      ALLOWSUDO=TRUE
      shift # past argument
      ;;
    --dl|--deletelogs)
      DELETELOGS=TRUE
      shift # past argument
      ;;
    --it|--iptables)
      IPTABLES=TRUE
      shift # past argument
      ;;
    --rl|--readlogs)
      DENYREADLOGS=TRUE
      shift # past argument
      ;;
    -f|--firewall)
      FIREWALL=TRUE
      shift # past argument
      ;;
    --ip|--ipaddress)
      IPADDRESS=$2
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo -e "\nScript allows to configure password settings\nfor users, grant rights to execute iptables without\na sudo and grant access to read log files.\n"
      echo -e "-p or --provisioning\t - Make of global pasword settings provisioning:"
      echo -e "    --le or --pwlength\t - Set a length for pasword (default - 8)."
      echo -e "    --ex or --pwlexpire\t - Set a period of expiration for pasword (default - 90 days)."
      echo -e "    --re or --pwrepeats\t - Number of last passwords in memory (default - 3)."
      echo -e "    --nl or --nlowcase\t - Minial number of lowercase letters in password (default - 1)."
      echo -e "    --nu or --nupcase\t - Minial number of uppercase letters in password (default - 1)."
      echo -e "    --nd or --ndigits\t - Minial number of digits in password (default - 1)."
      echo -e "    --ns or --nspecial\t - Minial number of special characters in password (default - 0)."
      echo -e "-u or --userconf\t - Make user configuration:"
      echo -e "    --un or --username\t - Spesify user name. Obligatory parameter."
      echo -e "    --em or --useremail\t - User E-mail."
      echo -e "    --cr or --createuser - Create user."
      echo -e "    --rm or --rmuser\t - Delete user."
      echo -e "    --du or --disbluser\t - Disable user temporary."
      echo -e "    --fl or --firstlogin - Disable password change during first login. Will be asked by default."
      echo -e "    --su or --allowsudo\t - Allow executing ’sudo su -’ and ‘sudo -s’. Disabled by default."
      echo -e "    --dl or --deletelogs - Allow removal of /var/log/auth.log (Debian) or /var/log/secure (RedHat). Prohibited by default."
      echo -e "    --it or --iptables\t - Deny execute ‘iptables’. Allowed by default."
      echo -e "    --rl or --readlogs\t - Deny access to read log-files. Allowed by default."
      echo -e "-f or --firewall\t - Add a firewall rule to restrict connections from specified IP address."
      echo -e "    --ip or --ipaddress\t - IP address to block. Format: ddd.ddd.ddd.ddd/mm. Obligatory parameter."
      echo -e "-h or --help\t - Show help.\n"
      exit 0
      ;;
    *)
      echo "Unknown option $1. Type -h or --help for help"
      exit 1
      ;;
  esac
done

#if [[ -n $1 ]]; then
#     echo "Last line of file specified as non-opt/last argument:"
#     tail -1 "$1"
# fi

distrib=""
if [[ $(cat /proc/version | grep -qi -E "centos|red hat|redhat|rhel|fedora"; echo $?) -eq 0 ]]; then
    distrib=redhat
elif [[ $(cat /proc/version | grep -qi -E "ubuntu|debian|mint"; echo $?) -eq 0 ]]; then
    distrib=debian
else
    echo "Unknown system distributor"
    exit 1
fi
echo "Distrib: $distrib"


#Changes config in specified configuration file:
function change-config-file() {
while IFS='' read -r a
    do
    if [[ $(echo $a | grep -q $2 ; echo $?) != 0 ]]; then
        echo "${a//$1/$1 $2=$4}"
    else
        if [[ $(expr index "$a" $'\t' > /dev/null; echo $?) == 0  ]]; then
            r=$(echo $a | grep -oP "(# )*$2[ =\t]{1,3}-*[0-9]+" | cut -d' ' -f1,2 --output-delimiter=$'\t')
        else
            r=$(echo $a | grep -oP "(# )*$2[ =\t]{1,3}-*[0-9]+")
        fi
        echo -e "${a//$r/$2$3$4}"
    fi
    done < $5 > $5.t
mv $5{.t,}
}


#Installs some package depending on OS distrib:
function install_package() {
    if [[ $distrib == "debian" ]]; then
        if [[ $(dpkg -s $1 > /dev/null; echo $?) != 0  ]]; then
            apt-get install $1 -y 1>/dev/null
        fi
    elif [[ $distrib == "redhat" ]]; then
        if [[ $(yum list installed $1 1>/dev/null; echo $?) != 0  ]]; then
            yum install $1 -y 1>/dev/null
        fi
    fi
}


# Configure general policy for user passwords:
if [[ ${PROVISION} ]] ; then
    if [[ $distrib == "debian" ]]; then

        #Install libpam-cracklib (pam_cracklib.so) if not installed yet:
        if [[ $(dpkg -s libpam-cracklib > /dev/null; echo $?) != 0  ]]; then
            apt-get install libpam-cracklib -y
        fi

        #Make backup of config files:
        cp /etc/pam.d/common-password /etc/pam.d/common-password.bak.$(date +%Y%m%d_%H:%M)
        cp /etc/login.defs /etc/login.defs.bak.$(date +%Y%m%d_%H:%M)

        #Change passwd length:
        change-config-file "pam_cracklib.so" "minlen" "=" ${PWLENGTH} "/etc/pam.d/common-password"
        #Change count of last remembered passwords:
        change-config-file "pam_cracklib.so" "remember" "=" ${PWREPEAT} "/etc/pam.d/common-password"
        #Change upper case letter credit:
        change-config-file "pam_cracklib.so" "ucredit" "=" ${NUPCASE} "/etc/pam.d/common-password"
        #Change lower case letter credit:
        change-config-file "pam_cracklib.so" "lcredit" "=" ${NLOWCASE} "/etc/pam.d/common-password"
        #Change digits credit:
        change-config-file "pam_cracklib.so" "dcredit" "=" ${NDIGITS} "/etc/pam.d/common-password"
        #Change special characters credit:
        change-config-file "pam_cracklib.so" "ocredit" "=" ${NSPECIAL} "/etc/pam.d/common-password"
        #Change passwd expire global:
        change-config-file "PASS_MAX_DAYS" "PASS_MAX_DAYS" "\t" ${PWEXPIRE} "/etc/login.defs"

        echo "Debian password policy config finished"

    elif [[ $distrib == "redhat" ]]; then

        #Make backup of config files:
        cp /etc/pam.d/system-auth /etc/pam.d/system-auth.bak.$(date +%Y%m%d_%H:%M)
        cp /etc/login.defs /etc/login.defs.bak.$(date +%Y%m%d_%H:%M)

        #Change passwd length:
        change-config-file "" "minlen" "=" ${PWLENGTH} "/etc/pam.d/system-auth"
        #Change count of last remembered passwords:
        change-config-file "pam_unix.so" "remember" "=" ${PWREPEAT} "/etc/pam.d/system-auth"
        #Change upper case letter credit:
        change-config-file "" "ucredit" "=" ${NUPCASE} "/etc/security/pwquality.conf"
        #Change lower case letter credit:
        change-config-file "" "lcredit" "=" ${NLOWCASE} "/etc/security/pwquality.conf"
        #Change digits credit:
        change-config-file "" "dcredit" "=" ${NDIGITS} "/etc/security/pwquality.conf"
        #Change special characters credit:
        change-config-file "" "ocredit" "=" ${NSPECIAL} "/etc/security/pwquality.conf"
        #Change passwd expire global:
        change-config-file "PASS_MAX_DAYS" "PASS_MAX_DAYS" "\t" ${PWEXPIRE} "/etc/login.defs"

        #authconfig --passminlen=${PWLENGTH} --update
        #authconfig --enablereqlower --update
        #authconfig --enablerequpper --update
        #authconfig --enablereqdigit --update
        #authconfig --enablereqother --update

        echo "RedHat password policy config finished"
    fi
fi

#User configuration part:
if [[ ${USERCONF} ]]; then
    tmp_pswd=$(chmod +x pswd-gen.py; ./pswd-gen.py -t a4%-%A4%-%d4%)
    if [[ ! ${USERNAME} ]]; then
        echo "Username must be specified: --un <username> or --username <username>"
        exit 1
    fi
    if [[ ${CREATEUSER} ]]; then
        # Create user and assign randomly generated password:
        if [[ $(cat /etc/passwd | cut -d: -f1 | grep -q ${USERNAME}; echo $?) != 0 ]]; then
            echo -e "$tmp_pswd\n$tmp_pswd\n" | adduser --quiet ${USERNAME} &>/dev/null
        else
            echo "Error! User ${USERNAME} already exists. Try with another name."
            exit 1
        fi

        #Check if any mail agent is installed:
        if [[ $distrib == "debian" ]]; then
            #Install mail util if has not been installed yet:
            if [[ $(dpkg -s mailutils &> /dev/null; echo $?) != 0  ]]; then
                debconf-set-selections <<< "postfix postfix/mailname string vm2.rocca-nb.local"
                debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
                apt-get install -y mailutils
            fi
        elif [[ $distrib == "redhat" ]]; then
            install_package mailx
        fi

        #Send a mail with a temporary password to the user:
        if [[ ${USEREMAIL} ]]; then
            echo "User ${USERNAME} was successfuly created on host $(hostname). Temporary password for log-in: ${tmp_pswd}" | mail -s "New user created" ${USEREMAIL}
        fi

        #Config sudo:
        permissions=""
        if [[ ! ${ALLOWSUDO} ]]; then
            permissions+="NOEXEC: /bin/sudo -s, /bin/sudo su -, "
        fi
        if [[ ! ${IPTABLES} ]]; then
            permissions+="NOPASSWD: /usr/sbin/iptables"
        fi
        echo "${USERNAME} ALL=(ALL) $permissions" | sudo EDITOR='tee -a' visudo

        #Add alias for iptables:
        su ${USERNAME} -c "echo \"alias iptables='sudo iptables'\" >> ~/.bashrc"

        #Prevention of accidental removal of auth log files:
        if [[ ! ${DELETELOGS} ]]; then
            if [[ $distrib == "debian" ]]; then
                chattr +a /var/log/auth.log
            elif [[ $distrib == "redhat" ]]; then
                chattr +a /var/log/secure
            fi
        fi

        #Grant access to read log-files:
        if [[ ! ${DENYREADLOGS} ]]; then
            install_package acl
            if [[ $distrib == "debian" ]]; then
                setfacl -m u:${USERNAME}:r /var/log/syslog
            elif [[ $distrib == "redhat" ]]; then
                setfacl -m u:${USERNAME}:r /var/log/messages
            fi
        fi

        # Ask password change during first login:
        chage -d 0 ${USERNAME}

        echo -e "User ${USERNAME} successfuly created and configured.\nTemporary password: $tmp_pswd was sent to e-mail: ${USEREMAIL}."
    fi

    # Remove or temporary disable user:
    if [[ ${RMUSER} || ${DISABLEUSER} ]]; then
        if [[ $(cat /etc/passwd | cut -d: -f1 | grep -q ${USERNAME}; echo $?) == 0 ]]; then
            if [[ ${RMUSER} ]]; then
                if [[ $(deluser --quiet --remove-home ${USERNAME} ; echo $?) == 0 ]]; then
                    echo "User ${USERNAME} was removed successfuly."
                fi
            else
                if [[ $(passwd -l --quiet ${USERNAME}; echo $?) == 0 ]]; then
                    echo "User ${USERNAME} was disabled successfuly."
                fi
            fi
        else
            echo "Error! User with name ${USERNAME} was not found."
        fi
    fi
fi


#Add blocking rule to iptables to restrict access to the server from specified IP:
if [[ ${FIREWALL} ]]; then
    if [[ ! ${IPADDRESS} ]]; then
        echo "IP address must be specified: --ip <ip_address/mask> or --ipaddress <ip_address/mask>"
        exit 1
    fi
    if [[ $(iptables -t filter -A INPUT -s ${IPADDRESS} -j DROP; echo $?) == 0 ]]; then
        iptables-save 1>/dev/null
        echo "IP address ${IPADDRESS} was blocked successfuly."
    fi
fi
