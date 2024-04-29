#
# Copyright 2024 RapidFort Inc. All Rights Reserved.
#
have_tty()
{
    # return success if both stdin and stdout are tty
    if [ ! -p /dev/stdin ] && [ -t 0 ] && [ -t 1 ] ; then
        return 0
    fi
    return 1
}

# some colors
if have_tty ; then
    __red='\033[0;31m'
    __yellow='\033[0;33m'
    __green='\033[0;32m'
    __bold='\033[1m'
    __color_off='\033[0m'
else
    __red=""
    __yellow=""
    __green=""
    __bold=""
    __color_off=""
fi

now()
{
    date +"%F %T"
}

log_error()
{
    echo -e "${__red}$(now): ${*}${__color_off}"
}

log_warn()
{
    echo -e "${__yellow}$(now): ${*}${__color_off}"
}

log_info()
{
    echo -e "${__green}$(now): ${*}${__color_off}"
}

rapidfort_which()
{
    which "$1" 2>/dev/null || command -v "$1" 2>/dev/null
}

check_directory_in_path() 
{
    target_dir="${1}"
    path_dirs=$(echo "$PATH" | tr ':' '\n')

    for dir in $path_dirs; do
        if [ "$dir" = "$target_dir" ] ; then
            echo -n 0
            return
        fi
    done
    echo -n 1
}

rapidfort_root_dir()
{
  case $1 in
  /*)   _rapidfort_path=$1
        ;;
  */*)  _rapidfort_path=$PWD/$1
        ;;
  *)    _rapidfort_path=$(rapidfort_which "$1")
        case $_rapidfort_path in
        /*) ;;
        *)  _rapidfort_path=$PWD/$_rapidfort_path ;;
        esac
        ;;
  esac
  _rapidfort_dir=0
  while :
  do
    while _rapidfort_link=$(readlink "$_rapidfort_path")
    do
      case $_rapidfort_link in
      /*) _rapidfort_path=$_rapidfort_link ;;
      *)  _rapidfort_path=$(dirname "$_rapidfort_path")/$_rapidfort_link ;;
      esac
    done
    case $_rapidfort_dir in
    1)  break ;;
    esac
    if [ -d "${_rapidfort_path}" ]; then
      break
    fi
    _rapidfort_dir=1
    _rapidfort_path=$(dirname "$_rapidfort_path")
  done
  while :
  do  case $_rapidfort_path in
      */)     _rapidfort_path=$(dirname "$_rapidfort_path/.")
              ;;
      */.)    _rapidfort_path=$(dirname "$_rapidfort_path")
              ;;
      */bin)  dirname "$_rapidfort_path"
              break
              ;;
      *)      echo "$_rapidfort_path"
              break
              ;;
      esac
  done
}

order_python_no_check()
{
    selected_version=""
    for python_version in "$@"
    do
        if [ -z "$selected_version" ]; then
            if rapidfort_which "$python_version" > /dev/null; then
                selected_version=$python_version
            fi
        fi
    done
    if [ -z "$selected_version" ]; then
        selected_version=python
    fi
    echo "$selected_version"
}

order_python()
{
    selected_version=""
    for python_version in "$@"
        do
            if [ -z "$selected_version" ]; then
                if "$python_version" -c "import sys; sys.exit(0 if ((3,8) <= (sys.version_info.major, sys.version_info.minor) <= (3,12)) else 1)" > /dev/null 2>&1; then
                    selected_version=$python_version
                fi
            fi
        done
    echo "$selected_version"
}

setup_rapidfort_python()
{
    CLI_PYTHON=$(order_python python3 python python3.12 python3.11 python3.10 python3.9 python3.8)
    if [ -z "$CLI_PYTHON" ]; then
      CLI_PYTHON=$(order_python_no_check python3 python)
    fi
    if [ -z "${CLI_PYTHON}" ]; then
        log_error "ERROR: To use the RapidFort CLI, you must have Python installed and on your PATH."
        exit 1
    fi
}

check_tools()
{
    _needed_tools="curl tar sed chown getent stat mkdir rm id ln tr"
    _have_all_tools=1
    for tool in $_needed_tools ; do
        if [ ! -x "$(rapidfort_which "$tool")" ]; then
            log_error "ERROR: $tool command not accessible."
            _have_all_tools=0
        fi
    done

    if [ "$_have_all_tools" = 0 ] ; then
        log_error "ERROR: To install the RapidFort CLI, you must have the following installed and in your PATH."
        log_error "       $_needed_tools"
        exit 1
    fi

    container_engines="docker podman"
    for engine in $container_engines; do
        if [ -x "$(rapidfort_which "$engine")" ]; then
            CONTAINER_ENGINE="$engine"
            break
        fi
    done
    
    if [ -z "${CONTAINER_ENGINE}" ]; then
        log_error "ERROR: you must have docker or podman installed and in your PATH."
        exit 1
    fi
}

patch_elf_file()
{
    patchelf_dir="$1"
    interp_path="$2"
    elf_file="$3"
    lock_dir="${elf_file}".rfp    # create this dir so scripts know it's already patched

    if [ ! -s "$elf_file" ] ; then
        log_error "ERROR: '$elf_file' is not accessible for patching." >&2
        exit 1
    fi

    mkdir -p "$lock_dir" 2>/dev/null
    err="$?"

    if [ "$err" = 0 ] ; then           # not patched yet. proceed
        "${patchelf_dir}"/patchelf --set-interpreter "${interp_path}" "${elf_file}"
        err="$?"
        if [ "$err" != 0 ] ; then
            log_error "ERROR: Cannot patch $elf_file."
            exit 1
        fi
        echo "0" > "${lock_dir}"/ret
        echo "$interp_path" > "${lock_dir}"/interp
    else
        log_error "ERROR: Could not install and update $elf_file."
        exit 1
    fi
    return 0
}

patch_bins()
{
    tools_dir="$1"
    install_dir="/.rapidfort_RtmF/tmp/tools"

    patch_elf_file "${tools_dir}" "${install_dir}"/rpmbins/ld-linux-x86-64.so.2 "${tools_dir}"/rpmbins/rpm
    patch_elf_file "${tools_dir}" "${install_dir}"/rpmbins/ld-linux-x86-64.so.2 "${tools_dir}"/rpmbins/rpmdb
    patch_elf_file "${tools_dir}" "${RAPIDFORT_ROOT_DIR}"/tools/lib/ld-musl-x86_64.so.1 "${tools_dir}"/rf_make_dockerfiles
}

curl_status_check()
{
    status="${1}"
    output="${2}"

    if [ "$status" -ne 0 ]; then
        case $1 in
            6)
                log_error "ERROR: curl failed to resolve host: ${RF_APP_HOST}"
                exit "$status"
                ;;
            28)
                log_error "ERROR: curl timed out for host: ${RF_APP_HOST}"
                exit "$status"
                ;;
            *)
                log_error "ERROR: curl command encountered an error with exit code $1 for host: ${RF_APP_HOST}"
                log_error "$output"
                exit "$status"
                ;;
        esac
    fi
}

check_curl_progress_bar()
{
    # curl 7.71.1 and later versions support progress-bar
    curl_version=$(curl --version | awk 'NR==1{print $2}')

    major=$(echo "$curl_version" | cut -d. -f1)
    minor=$(echo "$curl_version" | cut -d. -f2)
    patch=$(echo "$curl_version" | cut -d. -f3)

    if [ "$major" -gt 7 ] ; then
        return 0
    elif [ "$major" -eq 7 ] && [ "$minor" -gt 70 ] ; then
        return 0
    elif [ "$major" -eq 7 ] && [ "$minor" -eq 71 ] && [ "$patch" -gt 0 ] ; then
        return 0
    else
        return 1
    fi
}

log_info "Welcome to the RapidFort CLI installation!"

setup_rapidfort_python
check_tools

#
#  RAPIDFORT_ROOT_DIR           absolute installation root dir
#  INSTALLER                    installer file name
#  EXISTING_INSTALL_VERSION     optional if installed
#  NEW_INSTALL_VERSION          new installer version
#  INSTALL_USER_HOME
#

export RF_APP_HOST=us01.rapidfort.com

INSTALLER=rapidfort_cli-1.2.1772.tar.gz
INSTALL_USER_HOME=

# Parse command line arguments
for arg in "$@"; do
  shift
  case "$arg" in
    '--help')    set -- "$@" '-h'   ;;
    '--prefix')  set -- "$@" '-p'   ;;
    *)           set -- "$@" "$arg" ;;
  esac
done

print_usage()
{
    echo "${0}"
    echo "  -h, --help"
    echo "  -p, --prefix    RapidFort CLI install location"
}

# Set install path
# 1st precedence: Custom location for installation

OPTIND=1
while getopts "p:h" opt; do
  case "$opt" in
    'h') print_usage; exit 0 ;;
    'p')
        RAPIDFORT_ROOT_DIR="${OPTARG}"
        # POSIX compatible absolute path check
        case "${RAPIDFORT_ROOT_DIR}" in
            /*)
                : # do nothing
                ;;
            *)
                log_error "ERROR: Installation path must be an absolute path. given: ${RAPIDFORT_ROOT_DIR}"
                exit 1
                ;;
        esac
        ;;
    '?') print_usage >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ $(id -u) != 0 ]; then
    log_warn "WARNING: Installation as root is recommended for system-wide installation."
    INSTALL_USER_HOME="${HOME}"
    SUDO_USER=$(id -un)  #may not work if /etc/password does not have id

else
    if [ -z "${SUDO_USER}" ]; then
        SUDO_USER=root
    fi

    INSTALL_USER_HOME=$(getent passwd "${SUDO_USER}" | cut -d ':' -f6)
fi

if [ -z "${RAPIDFORT_ROOT_DIR}" ] ; then
    EXISTING_INSTALL_PATH=$(rapidfort_which rflogin)
    if [ -f "${EXISTING_INSTALL_PATH}" ]; then
        # 2nd precedence: Install same place as existing install
        log_info "Your current RapidFort CLI location is: ${__bold}$(rapidfort_root_dir "${EXISTING_INSTALL_PATH}")"
        log_info "Your current RapidFort CLI version is: ${__bold}$("${EXISTING_INSTALL_PATH}" --version)"
        RAPIDFORT_ROOT_DIR=$(rapidfort_root_dir "${EXISTING_INSTALL_PATH}")
        EXISTING_INSTALL_USER=$(id -un "$(stat -c %u "${RAPIDFORT_ROOT_DIR}")")
        if [ "${EXISTING_INSTALL_USER}" != "${SUDO_USER}" ]; then
            log_error "ERROR: You are trying to install as ${SUDO_USER} but the existing install is owned by ${EXISTING_INSTALL_USER}."
            log_error "Please run the installer as ${EXISTING_INSTALL_USER} or remove the existing install."
            exit 1
        fi
    elif [ "$(id -u)" = 0 ]; then
        # 3rd precedence:
        RAPIDFORT_ROOT_DIR=/usr/local/bin/rapidfort
    else
        # 4th precedence: install location is same location wherever installer is executed
        RAPIDFORT_ROOT_DIR=$(rapidfort_root_dir "$0")/rapidfort
    fi
fi

export RAPIDFORT_ROOT_DIR

INSTALLER_VERSION=$(curl -k -s --connect-timeout 10 https://"${RF_APP_HOST}"/cli/VERSION)
err=$?
curl_status_check $err

if [ -z "${INSTALLER_VERSION}" ]; then
    log_error "ERROR: Failed to get the RapidFort CLI version from the server. Exiting..."
    exit 1
fi
log_info New RapidFort CLI version is: "${__bold}${INSTALLER_VERSION}"
log_info "RapidFort CLI installation path is: ${__bold}${RAPIDFORT_ROOT_DIR}"

log_info "${__bold}Downloading CLI tools..."
if check_curl_progress_bar ; then
    output=$(curl -k --connect-timeout 10 --progress-meter "https://$RF_APP_HOST/cli/${INSTALLER}" -o "${INSTALLER}")
    err=$?
    curl_status_check $err "$output"
else
    output=$(curl -k -s --connect-timeout 10 "https://$RF_APP_HOST/cli/${INSTALLER}" -o "${INSTALLER}")
    err=$?
    curl_status_check $err "$output"
fi

log_info "${__bold}Installing CLI tools..."

if [ -d "${RAPIDFORT_ROOT_DIR}"/tools/rf_make_dockerfiles.rfp ]; then
    rm -rf "${RAPIDFORT_ROOT_DIR}"/tools/rf_make_dockerfiles.rfp
fi

mkdir -p "${RAPIDFORT_ROOT_DIR}"
err=$?
if [ "$err" -ne 0 ]; then
    log_error "ERROR: Failed to create installation directory ${RAPIDFORT_ROOT_DIR}. Exiting..."
    exit 1
fi

if [ ! -w "${RAPIDFORT_ROOT_DIR}" ]; then
    log_error "ERROR: Installation path ${RAPIDFORT_ROOT_DIR} is not writable."
    exit 1
fi

tar -xzpf "${INSTALLER}" -C "${RAPIDFORT_ROOT_DIR}"

patch_bins "${RAPIDFORT_ROOT_DIR}"/tools

rm "${INSTALLER}"

log_info "Setting up RapidFort platform host to ${RF_APP_HOST}"
mkdir -p "${INSTALL_USER_HOME}"/.rapidfort
if [ -f "${INSTALL_USER_HOME}"/.rapidfort/credentials ] ; then
    sed -i.bak "s/api_root_url.*=*$/rf_root_url=https:\/\/${RF_APP_HOST}/" "${INSTALL_USER_HOME}"/.rapidfort/credentials
    sed -i.bak "s/rf_root_url.*=*$/rf_root_url=https:\/\/${RF_APP_HOST}/" "${INSTALL_USER_HOME}"/.rapidfort/credentials
else
    echo "[rapidfort-user]" > "${INSTALL_USER_HOME}"/.rapidfort/credentials
    echo "rf_root_url = https://${RF_APP_HOST}" >> "${INSTALL_USER_HOME}"/.rapidfort/credentials
fi

chown -R "${SUDO_USER}" "${INSTALL_USER_HOME}"/.rapidfort

update_symlinks_or_prompt_path_update()
{
    parent_rapidfort_root_dir=$(dirname "${RAPIDFORT_ROOT_DIR}")
    in_path=$(check_directory_in_path "${parent_rapidfort_root_dir}")
    if [ -w "${parent_rapidfort_root_dir}" ] && [ "$in_path" -eq 0 ]; then
        entrypoints="rfcat rfconfigure rfharden rfinfo rfjobs rflens rflogin rfls rfrbom rfsbom rfscan rfstub"
        for entrypoint in $entrypoints; do
            ln -sf "${RAPIDFORT_ROOT_DIR}"/"${entrypoint}" "${parent_rapidfort_root_dir}"/"${entrypoint}"
        done
    else
        log_info "Add ${__bold}${RAPIDFORT_ROOT_DIR} to your PATH to use the RapidFort CLI tools."
    fi
}

update_symlinks_or_prompt_path_update