#!/usr/bin/env bash

set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ALL_ARGS=$@
CLEAN=false
UPDATE=false
SHOW_HELP=false
VERBOSE=false
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --clean|-c)
    CLEAN=true
    shift
    ;;
    --update|-u)
    UPDATE=true
    shift
    ;;
    --help|-h)
    SHOW_HELP=true
    break
    ;;
    --verbose)
    VERBOSE=true
    shift
    ;;
    *)
    shift
    ;;
  esac
done

if $SHOW_HELP; then
  cat <<EOF
Post installer.

Usage:
  `readlink -f $0` [flags]

Flags:
  -u, --update                                       Will download and install/reinstall even if the tools are already installed
      --verbose                                      Show verbose output
  -h, --help                                         This help
EOF
  exit 0
fi

if $VERBOSE; then
  echo Running `basename "$0"` $ALL_ARGS
  echo Update is $UPDATE
fi

sudo -E $BASEDIR/install-root-pkgs.sh $ALL_ARGS
$BASEDIR/install-user-pkgs.sh $ALL_ARGS

if $CLEAN; then
  echo -e "\e[34mCleanning up packages.\e[0m"
  sudo apt-get autoremove -y
else
  if $VERBOSE; then
    echo "Not auto removing with APT."
  fi
fi

if ! [[ `locale -a` =~ 'en_US.utf8' ]]; then
  echo -e "\e[34mGenerate location.\e[0m"
  sudo locale-gen en_US.UTF-8
else
  if $VERBOSE; then
    echo "Not generating location, it is already generated."
  fi
fi

PIP_PKGS_INSTALLED=`pip3 list --user --format columns | tail -n +3 | awk '{print $1}'`
PIP_PKGS_TO_INSTALL="powerline-status
xlsx2csv"
PIP_PKGS_NOT_INSTALLED=`comm -23 <(echo "$PIP_PKGS_TO_INSTALL") <(echo "$PIP_PKGS_INSTALLED")`
if [ "$PIP_PKGS_NOT_INSTALLED" != "" ]; then
  echo -e "\e[34mInstall packages "$PIP_PKGS_NOT_INSTALLED" with Pip.\e[0m"
  pip3 install --user $PIP_PKGS_NOT_INSTALLED
else
  if $VERBOSE; then
    echo "Not installing Pip packages, they are already installed."
  fi
fi

# .NET Tools
DOTNET_TOOLS=$HOME/.dotnet/tools
if ! [ -f $DOTNET_TOOLS/pwsh ] || $UPDATE; then
  echo -e "\e[34mInstall PowerShell.\e[0m"
  dotnet tool update --global PowerShell
fi
if ! [ -f $DOTNET_TOOLS/dotnet-dump ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Dump.\e[0m"
  dotnet tool update --global dotnet-dump
fi
if ! [ -f $DOTNET_TOOLS/dotnet-gcdump ] || $UPDATE; then
  echo -e "\e[34mInstall .NET GC Dump.\e[0m"
  dotnet tool update --global dotnet-gcdump
fi
if ! [ -f $DOTNET_TOOLS/dotnet-counters ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Counters.\e[0m"
  dotnet tool update --global dotnet-counters
fi
if ! [ -f $DOTNET_TOOLS/dotnet-trace ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Trace.\e[0m"
  dotnet tool update --global dotnet-trace
fi
if ! [ -f $DOTNET_TOOLS/dotnet-script ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Script.\e[0m"
  dotnet tool update --global dotnet-script
fi
if ! [ -f $DOTNET_TOOLS/dotnet-suggest ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Suggest.\e[0m"
  dotnet tool update --global dotnet-suggest
fi
if ! [ -f $DOTNET_TOOLS/tye ] || $UPDATE; then
  echo -e "\e[34mInstall Tye.\e[0m"
  dotnet tool update --global Microsoft.Tye --version "0.2.0-alpha.20258.3"
fi
if ! [ -f $DOTNET_TOOLS/dotnet-aspnet-codegenerator ] || $UPDATE; then
  echo -e "\e[34mInstall ASP.NET Code Generator.\e[0m"
  dotnet tool update --global dotnet-aspnet-codegenerator
fi
if ! [ -f $DOTNET_TOOLS/dotnet-delice ] || $UPDATE; then
  echo -e "\e[34mInstall Delice.\e[0m"
  dotnet tool update --global dotnet-delice
fi
if ! [ -f $DOTNET_TOOLS/dotnet-interactive ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Interactive.\e[0m"
  dotnet tool update --global Microsoft.dotnet-interactive
fi
if ! [ -f $DOTNET_TOOLS/dotnet-sos ] || $UPDATE; then
  echo -e "\e[34mInstall .NET SOS.\e[0m"
  dotnet tool update --global dotnet-sos
fi
if ! [ -f $DOTNET_TOOLS/dotnet-symbol ] || ! [ -d $HOME/.dotnet/sos ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Symbol.\e[0m"
  dotnet tool update --global dotnet-symbol
  $HOME/.dotnet/tools/dotnet-sos install
fi
if ! [ -f $DOTNET_TOOLS/dotnet-try ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Try.\e[0m"
  dotnet tool update --global dotnet-try
fi
if ! [ -f $DOTNET_TOOLS/httprepl ] || $UPDATE; then
  echo -e "\e[34mInstall .NET HttpRepl.\e[0m"
  dotnet tool update --global Microsoft.dotnet-httprepl
fi
if ! [ -f $DOTNET_TOOLS/nukeeper ] || $UPDATE; then
  echo -e "\e[34mInstall .NET Nukeeper.\e[0m"
  dotnet tool update --global nukeeper
fi
if ! [ -f $DOTNET_TOOLS/git-istage ] || $UPDATE; then
  echo -e "\e[34mInstall Git Istage.\e[0m"
  dotnet tool update --global git-istage
fi

# node
export N_PREFIX=$HOME/.n
if ! hash node 2>/dev/null && ! [ -f $HOME/.n/bin/node ] || $UPDATE; then
  echo -e "\e[34mInstall Install latest Node version through n.\e[0m"
  $BASEDIR/tools/n/bin/n install latest
else
  if $VERBOSE; then
    echo "Not installing latest Node.js version."
  fi
fi
export PATH="$N_PREFIX/bin:$PATH"
#npm tools
export NG_CLI_ANALYTICS=ci
NPM_PKGS_INSTALLED_NOT_ORGS=$(ls `npm prefix -g`/lib/node_modules | grep -v @)
NPM_PKGS_INSTALLED_ORGS=''
for ORG_DIR in $(ls -d `npm prefix -g`/lib/node_modules/* | grep --color=never @); do
  for PKG in `ls $ORG_DIR`; do
    NPM_PKGS_INSTALLED_ORGS+=$'\n'`basename $ORG_DIR`/$PKG
  done
done
NPM_PKGS_INSTALLED_ORGS=`echo "$NPM_PKGS_INSTALLED_ORGS" | tail -n +2`
NPM_PKGS_INSTALLED=`echo "$NPM_PKGS_INSTALLED_NOT_ORGS"$'\n'"$NPM_PKGS_INSTALLED_ORGS" | sort`
NPM_PKGS_TO_INSTALL=`echo "@angular/cli
bash-language-server
bats
bower
cross-env
diff-so-fancy
eslint
express-generator
gist-cli
gitignore
glob-tester-cli
grunt-cli
gulp
http-server
karma-cli
license-checker
loadtest
madge
mocha
nodemon
npmrc
pm2
tldr
trash-cli
typescript
vtop
yaml-cli
yarn" | sort`
NPM_PKGS_NOT_INSTALLED=`comm -23 <(echo "$NPM_PKGS_TO_INSTALL") <(echo "$NPM_PKGS_INSTALLED")`
if [ "$NPM_PKGS_NOT_INSTALLED" != "" ] || $UPDATE; then
  echo -e "\e[34mInstall packages "$NPM_PKGS_NOT_INSTALLED" with npm.\e[0m"
  npm install -g $NPM_PKGS_NOT_INSTALLED
else
  if $VERBOSE; then
    echo "Not installing Npm packages, they are already installed."
  fi
fi

# deno
if ! hash deno 2>/dev/null && ! [ -f $HOME/.deno/bin/deno ] || $UPDATE; then
  echo -e "\e[34mInstall Deno.\e[0m"
  curl -fsSL https://deno.land/x/install/install.sh | sh
else
  if $VERBOSE; then
    echo "Not installing Deno, it is already installed."
  fi
fi

# rbenv
if ! [ -f $BASEDIR/tools/rbenv/shims/ruby ] || $UPDATE; then
  echo -e "\e[34mInstall ruby-build and install Ruby with rbenv.\e[0m"
  git clone https://github.com/rbenv/ruby-build.git $BASEDIR/tools/rbenv/plugins/ruby-build
  $HOME/.rbenv/bin/rbenv install 2.7.1
  $HOME/.rbenv/bin/rbenv global 2.7.1
else
  if $VERBOSE; then
    echo "Not installing Rbenv and generating Ruby, it is already installed."
  fi
fi

if ! [ -f /etc/sudoers.d/10-cron ]; then
  echo -e "\e[34mAllow cron to start without su.\e[0m"
  echo "#allow cron to start without su
%sudo ALL=NOPASSWD: /etc/init.d/cron start" | sudo tee /etc/sudoers.d/10-cron
  sudo chmod 440 /etc/sudoers.d/10-cron
else
  if $VERBOSE; then
    echo "Not generating sudoers file for Cron, it is already there."
  fi
fi

function setAlternative() {
  NAME=$1
  EXEC_PATH=`which $2`
  if [ `update-alternatives --display $NAME | sed -n 's/.*link currently points to \(.*\)$/\1/p'` != $EXEC_PATH ]; then
    sudo update-alternatives --set $NAME $EXEC_PATH
  else
    if $VERBOSE; then
      echo "Not updating alternative to $NAME, it is already set."
    fi
  fi
}

if $WSL; then
  if hash wslview 2>/dev/null; then
    setAlternative x-www-browser wslview
  else
    if $VERBOSE; then
      echo "Not setting browser to wslview, wslview is not available."
    fi
  fi
fi

setAlternative editor /usr/bin/vim.basic
