#!/bin/bash
#./template.sh AppName

message (){
  echo ''
  echo "$1"
  echo ''  
}

command_exists (){
  command_string=$(type $1 2>/dev/null)
  if [[ $command_string != "" ]]; then
    retval="DETECTED"
  else 
    retval="NOT DETECTED"
  fi
  echo "$retval"
}

create_menu (){
  echo ''
  echo "$1"
  count=1
  for menu_item in $2; do
    echo "<$count> $menu_item"
    count=$((count+1))
  done
  read -p 'Enter Your Option: ' selected_option
  echo ''

  var1="$(cut -d'|' -f$selected_option <<<"$3")"

  rails_options="$rails_options $var1" 
  echo "$rails_options" 
  echo "$selected_option"
}

create_menu 'Select Application : ' 'WEBAPP API' '|--api' 
create_menu 'Select Database : ' 'SQLITE POSTGRES' '|-d postgresql'
create_menu 'Select Webpack : ' 'NONE REACT ANGULAR VEU' '|--webpack=react|--webpack=angular|--webpack=veu'

myapp=$1
template_file=$PWD/template/template.rb


mkdir $myapp 2>/dev/null
cd $myapp


rbenv_configure () {
  detect_rbenv=$( command_exists 'rbenv' )
  if [[ "$detect_rbenv" == "DETECTED" ]]; then
    touch ".ruby-version"
    echo "ruby-2.4.1" > ".ruby-version"
    touch ".ruby-gemset"
    echo $myapp"_gemset" > ".ruby-gemset"
    echo "RBENV DETECTED"
    echo $(rbenv version)
    echo $(rbenv gemset active)
  else
    echo "Need to configure RBENV"
    # sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
    # git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    # echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    # echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    # source ~/.bashrc
    # type rbenv
    # git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    # rbenv install -l
    # rbenv install 2.4.1
    # rbenv global 2.4.1
    # git clone git://github.com/jf/rbenv-gemset.git ~/.rbenv/plugins/rbenv-gemset
  fi
}

rvm_configure () {
  detect_rvm=$( command_exists 'rvm' )
  if [[ "$detect_rvm" == "DETECTED" ]]; then
    source ~/.rvm/scripts/rvm
    echo "RVM DETECTED"
    rvm use ruby-2.4.1@$myapp --rvmrc --create
  else
    echo "Need to configure RVM"
  fi
}

message 'Configure Ruby Version'
rbenv_configure
rvm_configure

message 'Install Rails'
gem install rails
gem install byebug

message 'Create New Rails App'
echo "rails new $PWD -m $template_file $rails_options"
rails new $PWD -m $template_file $rails_options
