#!/usr/bin/env bash

PROVISION=FALSE
PWLENGTH=8
PWEXPIRE=90
PWREPEAT=3
NLOWCASE=-1
NUPCASE=-1
NDIGITS=-1
NSPECIAL=0
USERCONF=FALSE
USERNAME=0
FIRSTLOGIN=TRUE
DENYSUDO=TRUE
DENYRM=TRUE
IPTABLES=FALSE
READLOGS=FALSE


POSITIONAL_ARGS=()

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
    --fl|--firstlogin)
      FIRSTLOGIN=FALSE
      shift # past argument
      ;;
    --su|--allowsudo)
      DENYSUDO=FALSE
      shift # past argument
      ;;
    --rm|--denyrm)
      DENYRM=FALSE
      shift # past argument
      ;;
    -it)
      IPTABLES=TRUE
      shift # past argument
      ;;
    -rl)
      READLOGS=TRUE
      shift # past argument
      ;;
    -h|--help)
      echo -e "\nScript allows to configure password settings\nfor users, grant rights to execute iptables without\na sudo and grant access to read log files\n"
      echo -e "-p or --provisioning\t - Make of global pasword settings provisioning:"
      echo -e "    --le or --pwlength\t - Set a length for pasword (default - 8)"
      echo -e "    --ex or --pwlexpire\t - Set a period of expiration for pasword (default - 90 days)"
      echo -e "    --re or --pwrepeats\t - Number of last passwords in memory (default - 3)"
      echo -e "    --nl or --nlowcase\t - Minial number of lowercase letters in password (default - 1)"
      echo -e "    --nu or --nupcase\t - Minial number of uppercase letters in password (default - 1)"
      echo -e "    --nd or --ndigits\t - Minial number of digits in password (default - 1)"
      echo -e "    --ns or --nspecial\t - Minial number of special characters in password (default - 1)"
      echo -e "-u or --userconf\t - Make user configuration:"
      echo -e "    --un or --username\t - Spesify user name. Obligatory parameter."
      echo -e "    --cu or --createuser - Create user."
      echo -e "    --du or --deleteuser - Delete user"
      echo -e "    --lf or --firstlogin - Disable password change during first login"
      echo -e "    --su or --allowsudo\t - Allow executing ’sudo su -’ and ‘sudo -s’. It will be disabled by default."
      echo -e "    --rm or --allowrm\t - Allow removal of /var/log/auth.log (Debian) or /var/log/secure (RedHat). It will be disabled by default."
      echo -e "    --it or --iptables\t - Allow execute ‘iptables’. It will be disabled by default."
      echo -e "    --rl or --readlogs\t - Grant access to read log-files. It will be disabled by default."
      echo -e "-h or --help\t - Show help.\n"
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

distrib=""
if [[ $(cat /proc/version | grep -qi -E "centos|red hat|redhat|rhel|fedora"; echo $?) -eq 0 ]]; then
    distrib=redhat
elif [[ $(cat /proc/version | grep -qi -E "ubuntu|debian|mint"; echo $?) -eq 0 ]]; then
    distrib=redhat
else
    echo "Unknown system distributor"
    exit 1
fi
echo "Distrib: $distrib"


function change-config-file() {
#Changes config in specified file
while IFS='' read -r a
    do
    if [[ $(echo $a | grep -q $2 ; echo $?) != 0 ]]; then
        echo "${a//$1/$1 $2=$4}"
    else
        set -x
        if [[ $distrib == "redhat" ]]; then
            r=$(echo $a | grep -oP "$2[ =\t]-*[0-9]+" | cut -d' ' -f1,2 --output-delimiter=$'\t')
        else
            r=$(echo $a | grep -oP "#* *$2 = -*[0-9]+")
        echo -e "${a//$r/$2$3$4}"
        set +x
        fi
    fi
    done < $5 > $5.t
mv $5{.t,}
}

function change-config-file-red() {
#Changes config in specified file
while IFS='' read -r a
    do
    if [[ $(echo $a | grep -q $2 ; echo $?) != 0 ]]; then
        echo "${a//$1/$1 $2=$4}"
    else
        set -x
        r=$(echo $a | grep -oP "$2[ =\t]-*[0-9]+" | cut -d' ' -f1,2 --output-delimiter=$'\t')
        echo -e "${a//$r/$2$3$4}"
        set +x
    fi
    done < $5 > $5.t
mv $5{.t,}
}


if [[ ${PROVISION} ]] ; then
    if [[ $distrib == "debian" ]]; then

        #Install libpam-cracklib (pam_cracklib.so) if not installed yet:
        if [[ $(dpkg -s libpam-cracklib > /dev/null; echo $?) != 0  ]]; then
            apt-get install libpam-cracklib -y
        fi


        #Change passwd length:
        change-config-file "pam_cracklib.so" "minlen" "=" ${PWLENGTH} "/etc/pam.d/common-password"
        #Change count of last remembered passwords:
        change-config-file "pam_cracklib.so" "remember" "=" ${PWREPEAT} "/etc/pam.d/common-password"
        #Change passwd expire:
        change-config-file "PASS_MAX_DAYS" "PASS_MAX_DAYS" "\t" ${PWEXPIRE} "/etc/login.defs"
        #Change upper case letter credit:
        change-config-file "pam_cracklib.so" "ucredit" "=" ${NUPCASE} "/etc/pam.d/common-password"
        #Change lower case letter credit:
        change-config-file "pam_cracklib.so" "lcredit" "=" ${NLOWCASE} "/etc/pam.d/common-password"
        #Change digits credit:
        change-config-file "pam_cracklib.so" "dcredit" "=" ${NDIGITS} "/etc/pam.d/common-password"
        #Change special characters credit:
        change-config-file "pam_cracklib.so" "ocredit" "=" ${NSPECIAL} "/etc/pam.d/common-password"

        echo "Debian password config finished"

    elif [[ $distrib == "redhat" ]]; then

        set -x
        change-config-file "" "minlen" "=" ${PWLENGTH} "./pwquality.conf"
        set +x

        #authconfig --passminlen=${PWLENGTH} --update
        #authconfig --enablereqlower --update
        #authconfig --enablerequpper --update
        #authconfig --enablereqdigit --update

        echo "RedHat password config finished"
    fi
fi

#sudo apt-get install libpam-cracklib -y

#sudo chage -M 90 user1
#sudo chage -d 0 user1
