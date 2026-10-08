#
# Customization script for the Magisk Module ???
#
# History
#   15.05.2025 /bs
#     initial release
#   07.07.2025 /bs
#     the script now sets the variable INSTALL_MODE to "update" if the module is already installed
#   29.07.2025 /bs
#     rewrote the code to detect a module update
#   10.08.2025 /bs
#     added initial code to support KernelSU (and KernelSU-Next)
#   11.08.2025 /bs
#     added code to check the tool used for the installation (the magisk binary or the Magisk GUI)
#   14.08.2025 /bs
#     fixed a type in the line :  INSTALL_PROGRAM="Magisk GUI"
#     added the function myprintf
#   03.09.2025 /bs
#     removed not used debug code
#     fixed the code to check wether the Magisk Module is installed via GUI or via Magisk binary
#   11.09.2025 /bs
#     fixed the code to check if this is a Module update
#   24.09.2025 /bs
#     added the function ReadVolumeKeys
#  29.08.2026 /bs
#     STDERR from the grep command to read the file module.prop is now redirected to /dev/null
#
#
#
# Notes:
#
# This Magisk Module contains files for arm64 CPUs
#
# Documentation for creating Magisk Modules: https://topjohnwu.github.io/Magisk/guides.html
#
# Environment variables that can be used:
#
#    MAGISK_VER (string): the version string of current installed Magisk (e.g. v20.0)
#    MAGISK_VER_CODE (int): the version code of current installed Magisk (e.g. 20000)
#    BOOTMODE (bool): true if the module is being installed in the Magisk app
#    MODPATH (path): the path where your module files should be installed
#    TMPDIR (path): a place where you can temporarily store files
#    ZIPFILE (path): your module’s installation zip
#    ARCH (string): the CPU architecture of the device. Value is either arm, arm64, x86, or x64
#    IS64BIT (bool): true if $ARCH is either arm64 or x64
#    API (int): the API level (Android version) of the device (e.g. 21 for Android 5.0)
#
# Additional environment variables if running in KernelSU or KernelSU-Next:
#
#    KSU (bool): a variable to mark that the script is running in the KernelSU environment, and the value of this variable will always be true. 
#    
# You can use it to distinguish between KernelSU and Magisk.
#
#    KSU_VER (string): the version string of currently installed KernelSU (e.g. v0.4.0).
#    KSU_VER_CODE (int): the version code of currently installed KernelSU in userspace (e.g. 10672).
#    KSU_KERNEL_VER_CODE (int): the version code of currently installed KernelSU in kernel space (e.g. 10672).
#
# Notes:
#
# In KernelSU, MAGISK_VER_CODE is always 25200, and MAGISK_VER is always v25.2. 
# Please don't use these two variables to determine whether KernelSU is running or not.
#
# (Source: https://kernelsu.org/guide/module.html)
# 
# Use the Magisk util function "abort" to abort the installation of the module; the synatx for this function is:
#     abort "error message"
#
# -----------------------------------------------------------------------------

DISCLAIMER="
to be written
"

# -----------------------------------------------------------------------------

# define constants
#
__TRUE=0
__FALSE=1


# -----------------------------------------------------------------------------
# init global variables
#

MODULE_VERSION="$( grep "^version=" $MODPATH/module.prop 2>/dev/null | cut -f2 -d "=" )"

MODULE_NAME="$( grep "^id=" $MODPATH/module.prop 2>/dev/null | cut -f2 -d "=" )"

MODULE_DESC="${MODULE_NAME} ${MODULE_VERSION}"


# -----------------------------------------------------------------------------
#
if [ 0 = 1 -o -r /data/local/tmp/debug ] ; then
  LOGFILE="/data/local/tmp/${MODULE_NAME}_customize.log"

  ui_print "Writing all messages to the log file ${LOGFILE}"
  exec 1>${LOGFILE} 2>&1

  if [ 0 = 1 -o -r /data/local/tmp/trace ] ; then
    set -x
  fi
fi

# -----------------------------------------------------------------------------
#

# -----------------------------------------------------------------------------
# functions
#

function LogMsg {
  ui_print "$*"
}

function LogInfo {
  LogMsg "INFO: $*"
}

function LogWarning {
  LogMsg "WARNING: $*"
}

function LogError {
  LogMsg "ERROR: $*"
}

# use printf only if the module is installed via the magisk binary
# 
function myprintf {
  if  [  "${INSTALL_PROGRAM}"x = "magisk binary"x ] ; then
    printf "$*"
  fi
}


# ---------------------------------------------------------------------
# ReadVolumeKeys - read the status of the volume keys
#
# Usage: ReadVolumeKeys [timeout]
#
# Parameter:
#        timeout - timeout in seconds to wait; the default value is 10 seconds
#
# returns:
#        0 - no volume key pressed
#        1 - volume up pressed
#        2 - volume down pressed
#
function ReadVolumeKeys {
  typeset __FUNCTION="ReadVolumeKeys"

  typeset THISRC=0

  typeset DEFAULT_TIMEOUT=10

  typeset TIMEOUT="${DEFAULT_TIMEOUT}"
  typeset MESSAGE=""

  typeset dev=""
  typeset type=""
  typeset code=""
  typeset value=""

  typeset RESULT=""

  if [ $# -eq 1 ] ; then
    TIMEOUT=$1
    shift
  fi

# the variables dev, type, code, and value can not be used here because the "while" statement is running a separate session
#
  RESULT=$( timeout ${TIMEOUT} getevent -ql | while read dev type code value; do
    if [ "$code" = "KEY_VOLUMEUP" ] && [ "$value" = "DOWN" ]; then
      echo 1
      break
    elif [ "$code" = "KEY_VOLUMEDOWN" ] && [ "$value" = "DOWN" ]; then
      echo 2
      break
    fi
  done )

  [ "${RESULT}"x != ""x ] && THISRC="${RESULT}"

  return ${THISRC}
}


# -----------------------------------------------------------------------------
#

ps | grep  "^[[:space:]]*$$[[:space:]]"  | grep /debug_ramdisk/.magisk/busybox/busybox >/dev/null
if [ $? -eq 0 ] ; then
  LogMsg "The Module installation is done via the magisk binary"
  INSTALL_PROGRAM="magisk binary"
else
  LogMsg "The Module installation is done via the Magisk GUI"
  INSTALL_PROGRAM="Magisk GUI"
fi


# -----------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------
#
if [ -d "/data/adb/modules/${MODULE_NAME}" ] ; then
  if [ -d "/data/adb/modules/${MODULE_NAME}/common" ] ; then
    LogMsg "This is an update of an already installed module"
    INSTALL_MODE="update"
  else
    LogMsg "This is a new installation of this module"
    INSTALL_MODE="install"
  fi
else
  LogMsg "This is a new installation of this module"
  INSTALL_MODE="install"
fi


# -----------------------------------------------------------------------------

#For convenience, you can also declare a list of folders you want to replace in the variable name REPLACE. The module installer script will create the .replace file into the folders listed in REPLACE. For example:
# 
# REPLACE="
# /system/app/YouTube
# /system/app/Bloatware
# "

# If using Magisk v28.0 or newer:
#
# The list above will result in the following files being created: $MODPATH/system/app/YouTube/.replace and $MODPATH/system/app/Bloatware/.replace.
# 
# For convenience, you can also declare a list of files/folders you want to remove in the variable name REMOVE. The module installer script will create the corresponding dummy devices. For example:
# 
# REMOVE="
# /system/app/YouTube
# /system/fonts/Roboto.ttf
# "
# 

# -----------------------------------------------------------------------------

LogMsg "The version of the installed Magisk is \"${MAGISK_VER}\" (${MAGISK_VER_CODE})"

LogMsg "The current environment for this installation is:"

LogMsg "BOOTMODE is \"${BOOTMODE}\" "
LogMsg "MODPATH is \"${MODPATH}\" "
LogMsg "TMPDIR is \"${TMPDIR}\" "
LogMsg "ZIPFILE is \"${ZIPFILE}\" "
LogMsg "ARCH is \"${ARCH}\" "
LogMsg "IS64BIT is \"${IS64BIT}\" "
LogMsg "API is \"${API}\" "

# -----------------------------------------------------------------------------
#
if [ "${KSU}"x = "true"x ] ; then
  LogMsg ""
  LogMsg "Running in KernelSU "
  LogMsg ""
  LogMsg "KSU_VER is \"${KSU_VER}\" "
  LogMsg "KSU_VER_CODE is \"${KSU_VER_CODE}\" "
  LogMsg "KSU_KERNEL_VER_CODE is \"${KSU_KERNEL_VER_CODE}\" "
fi


# -----------------------------------------------------------------------------

# example output for the variables:


#  The version of the installed Magisk is "25.0" (25000)
#  INFO: BOOTMODE is "true" 
#  INFO: MODPATH is "/data/adb/modules_update/PlayStore_for_MicroG" 
#  INFO: TMPDIR is "/dev/tmp" 
#  INFO: ZIPFILE is "/data/user/0/com.topjohnwu.magisk/cache/flash/install.zip" 
#  INFO: ARCH is "arm64" 
#  INFO: IS64BIT is "true" 
#  INFO: API is "32"


# -----------------------------------------------------------------------------

LogMsg "Installing the Magisk Module with ${MODULE_NAME} for Android \"${MODULE_VERSION}\" ..."

LogMsg "Checking the OS configuration ..."

ERRORS_FOUND=${__FALSE}

MACHINE_TYPE="$( uname -m )"

# check the current CPU
#
LogMsg "Checking the type of the CPU used in this device ...."

LogMsg "The CPU in this device is a ${ARCH} CPU"
LogMsg "The machine type reported by \"uname -m\" is \"${MACHINE_TYPE}\" "


if [ "${ARCH}"x != "arm64"x ] ; then
  abort "This Magisk module is for arm64 CPUs only"
fi

# ---------------------------------------------------------------------

LogMsg "Installing the Magisk Module ??? ..."

LogMsg "Correcting the permissions for the new files ..."

cd "${MODPATH}"

# first the directories with data and config files 
# 
for i in etc include usr lib/android-gcc-cross ; do

  [[ $i != /\* ]] && CUR_ENTRY="${MODPATH}/system/$i" || CUR_ENTRY="$i"

  [ ! -d "${CUR_ENTRY}" ] && continue

  LogMsg "Processing the files in the directory ${CUR_ENTRY} ..."
  set_perm_recursive "${CUR_ENTRY}" 0 0 0755 0644 u:object_r:system_file:s0
  chcon -R -h u:object_r:system_file:s0 "${CUR_ENTRY}"
done


# now the directories with binaries
# 
for i in bin lib lib64 usr/bin usr/clang${CLANG_VERSION}/bin usr/clang${CLANG_VERSION}/libexec lib/android-gcc-cross/bin  gcc/bin/gcc-toolchain ; do

  [[ $i != /\* ]] && CUR_ENTRY="${MODPATH}/system/$i" || CUR_ENTRY="$i"
	
  [ ! -d "${CUR_ENTRY}" ] && continue

  LogMsg "Processing the files in the directory ${CUR_ENTRY} ..."

  set_perm_recursive "${CUR_ENTRY}" 0 0 0755 0755 u:object_r:system_file:s0

  chcon -R -h  u:object_r:system_file:s0 "${CUR_ENTRY}"
done

