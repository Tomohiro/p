#!/bin/sh

set -e

bin_name=$(basename $0)


# Display usage

    usage() {
      echo "Usage: $bin_name COMMAND [args]"
      echo
      echo 'Commands:'
      echo '  update                # Retrieve new lists of packages'
      echo '  outdated              # List package that have an updated version available'
      echo '  installed <package>   # List all installed packages for package(or all install packages with no arguments)'
      echo '  search <package>      # Search for package in all avairable packages'
      echo '  info <package>        # Print info for package'
      echo '  depends <package>     # List dpendencies for package'
      echo '  install <package>     # Install new packages'
      echo '  reinstall <package>   # ReInstall packages'
      echo '  upgrade <package>     # Install newer version of outdated packages'
      echo '  remove <package>      # Remove packages'
      echo '  purge  <package>      # Remove packages and config files'
      echo '  clean                 # Erase downloaded archive files'
      echo '  autoclean             # Erase old downloaded archive files'
      echo "  commands              # List '$bin_name' all commands"
    }


# For OSX: Homebrew

  osx() {
    local command=$1
    shift

    # https://github.com/mxcl/homebrew/wiki/The-brew-command
    case $command in
         update) brew update ;;
       outdated) brew outdated $@;;
      installed) brew list $@ ;;
         search) brew search $@ ;;
           info) brew info $@ ;;
        depends) brew deps $@ ;;
        install) brew install $@ ;;
      reinstall) echo "Not found: '$command', see https://github.com/mxcl/homebrew/issues/12511" ;;
        upgrade) brew upgrade $@ ;;
         remove) brew remove $@ ;;
          purge) echo "Not found: '$command', use 'remove'" ;;
          clean) echo "Not found: '$command', use 'autoclean'" ;;
      autoclean) brew cleanup ;;
              *) command_not_found $command
    esac
  }


# For RedHat Linux, CentOS, Oracle Linux: Yum

  redhat() {
    local command=$1
    shift

    case $command in
         update) yum check-update ;;
       outdated) yum check-update ;;
      installed) repoquery -a $@ ;;
         search) yum search $@ ;;
           info) yum info $@ ;;
        depends) yum deplist $@ ;;
        install) sudo yum install $@ ;;
      reinstall) sudo yum reinstall $@ ;;
        upgrade) sudo yum update $@ ;;
         remove) sudo yum erase $@ ;;
          purge) echo "Not found: '$command', use 'remove'" ;;
          clean) sudo yum clean ;;
      autoclean) sudo yum clean ;;
              *) command_not_found $command
    esac
  }


# For Debian, Ubuntu: Apt

  debian() {
    local command=$1
    shift

    # http://wiki.debian.org/Apt
    # http://wiki.debian.org/AptCLI
    # http://wiki.debian.org/AptTools
    case $command in
         update) sudo apt-get update $@ ;;
       outdated) apt-get upgrade -s | grep Inst ;;
      installed) dpkg -l $@;;
         search) apt-cache search $@ ;;
           info) apt-cache show $@ ;;
        depends) apt-cache depends $@ ;;
        install) sudo apt-get install $@ ;;
      reinstall) sudo apt-get install --reinstall $@ ;;
        upgrade) sudo apt-get upgrade $@ ;;
         remove) sudo apt-get remove $@ ;;
          purge) sudo apt-get --purge remove $@ ;;
          clean) sudo apt-get clean ;;
      autoclean) sudo apt-get autoclean ;;
              *) command_not_found $command
    esac
  }


# List commands

    commands() {
      local commands='update outdated installed search info depends install reinstall upgrade remove purge clean autoclean'
      for command in $(echo $commands); do
        echo $command
      done
    }


# Command not found error

  command_not_found() {
    local command=$1
    echo "$bin_name: Could not find command '$command'."
    echo "See '$bin_name help' for more information on a specific command"
    exit 1
  }


case $1 in
  help|--help|-h)
    usage
    exit 0
    ;;
  command|commands)
    commands
    exit 0
    ;;
esac

if [ Darwin = $(uname) ]; then
  osx $@
elif [ -f /etc/debian_version ]; then
  debian $@
elif [ -f /etc/redhat_release ]; then
  redhat $@
fi