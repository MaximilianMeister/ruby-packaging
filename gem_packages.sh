#!/bin/bash
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -o dEf -l default-gem:,build-root:,gem-name:,gem-version:,gem2rpm-config: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

eval set -- "$options"

otheropts="--local -t /usr/lib/rpm/gem_packages.template" 
defaultgem=
buildroot=
gemfile=
gemname=
gemversion=

while [ $# -gt 0 ]
do
    case $1 in
    --default-gem) defaultgem=$2 ; shift;;
    --gem-name) gemname="$2" ; shift;;
    --gem-version) gemversion="$2" ; shift;;
    --build-root) buildroot=$2; shift;;
    --gem2rpm-config) gem_config=$2; shift;;
    (--) ;;
    (-*) otheropts="$otheropts $1";;
    (*) gemfile=$1; otheropts="$otheropts $1"; break;;
    esac
    shift
done

if [ "x$gem_config" = "x" ] ; then 
  gem_config=$(find $RPM_SOURCE_DIR -name "*gem2rpm.yml")
  if [ "x$gem_config" != "x" ] ; then 
    otheropts="$otheropts --config=$gem_config"
  fi
fi

if [ "x$gemfile" = "x" ] ; then 
  gemfile=$(find . -maxdepth 2 -type f -name "$defaultgem")
  # if still empty, we pick the sources
  if [ "x$gemfile" = "x" ] ; then
    gemfile=$(find $RPM_SOURCE_DIR -name "$defaultgem")
  fi
  otheropts="$otheropts $gemfile"
fi

set -x
for ruby in /usr/bin/ruby.* ; do
  gemrpm="/usr/bin/gem2rpm${ruby#/usr/bin/ruby}"
  $gemrpm $otheropts
done
