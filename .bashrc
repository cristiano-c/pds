# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#my menu
function mymenu () {
	echo "menu dei miei comandi:"
	echo "   [compileuser] - esegue bmake solo per i programmi utente (dentro userland)"
	echo "   [compilekernel] - compila il kernel e lancia os161"
	echo "   [compilekernel_v] - compila il kenerl a stadi"
	echo "   [kcompile] - compila il kernel a stadi senza mai uscire"
}

#my own function
function compileuser () {
	echo "compilazione del programma utente nella directory attuale"
	bmake
	bmake install
	bmake clean
	echo "compilazione eseguita"
	nautilus '/home/pds/pds-os161/root'
}

#compile the os161 kernel
function compilekernel () {
	# kernel di default = DUMBVM
	configStr="DUMBVM"
	
	# ho definito un kernel come argomento?
	if [ $# -eq 1 ];
	then configStr=$1 # si -> usalo
	else configStr="DUMBVM" # no -> usa quello di default
	fi 


	echo "riconfigurazione di $configStr" ;

	# configura i codici sorgente (fase di precompilazione)
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;
	cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;

	# esegui la compilazione vera e propria del kernel
	bmake depend;
	bmake;
	bmake install;

	# lancia il kernel in modalita normale (senza debug)
	cd /home/pds/pds-os161/root;
	sys161 kernel;
}

#La funzione compila il kernel a stadi e per ogni stadio chiede se continuare o chiudere il terminale.
function compilekernel_v () {
	
	# definizione costanti
	configStr="DUMBVM"
	
	# compilazione del kernel in modalità verbose

	# verifica degli argomenti (quale kernel compilare?)
	# il kernel di default e' "DUMBVM"
        # ho definito un kernel come argomento?
        if [ $# -eq 1 ];
        	then configStr=$1 # si -> usalo
		cd /home/pds/os161/os161-base-2.0.2/kern/compile;
		rm -rf configStr;
        	else configStr="DUMBVM" # no -> usa quello di default
		cd /home/pds/os161/os161-base-2.0.2/kern/compile;
		rm -rf *;
        fi


	# inizio compilazione

	# esecuzione della fase C1
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;


	while true; do
    		read -p "Procedere con la fase C2? [y/n]" yn
    		case $yn in
        		[Yy]* ) break;;
        		[Nn]* ) exit;;
        		* ) echo "Please answer yes or no.";;
    		esac
	done

	# esecuzione della fase C2
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;
	cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
	bmake depend;


        while true; do
                read -p "Procedere con la fase C3? [y/n]" yn
                case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) exit;;
                        * ) echo "Please answer yes or no.";;
                esac
        done

	# esecuzione della fase C3
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;
	cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
	bmake depend;
	bmake;


        while true; do
                read -p "Procedere con la fase C4? [y/n]" yn
                case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) exit;;
                        * ) echo "Please answer yes or no.";;
                esac
        done

	# esecuzione della fase C4
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;
	cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
	bmake depend;
	bmake;
	bmake install;
	cd /home/pds/pds-os161/root;
	sys161 kernel;

	# compilazione finita
	echo "la compilazione e' finita"
}



#La funziona compila il kernel a stadi e non esce mai (esce solo quando ha finito)

function kcompile () {
	
	# definizione costanti
	configStr="DUMBVM"
	
	# compilazione del kernel in modalità verbose

	# verifica degli argomenti (quale kernel compilare?)
	# il kernel di default e' "DUMBVM"
        # ho definito un kernel come argomento?
        if [ $# -eq 1 ];
        	then configStr=$1 # si -> usalo
		cd /home/pds/os161/os161-base-2.0.2/kern/compile;
		rm -rf configStr;
        	else configStr="DUMBVM" # no -> usa quello di default
		cd /home/pds/os161/os161-base-2.0.2/kern/compile;
		rm -rf *;
        fi


	# inizio compilazione

	# esecuzione della fase C1
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;


	while true; do
    		read -p "Procedere con la fase C2? [y/n]" yn
    		case $yn in
        		[Yy]* ) break;;
        		[Nn]* ) exit;;
        		* ) echo "Please answer yes or no.";;
    		esac
	done

	# esecuzione della fase C2


        while true; do

		cd /home/pds/os161/os161-base-2.0.2/kern/conf;
		./config $configStr;
		cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
		bmake depend;

                read -p "Procedere con la fase C3? [y/n]" yn
                case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) ;;
                        * ) echo "Please answer yes or no.";;
                esac
        done

	# esecuzione della fase C3
	

        while true; do

	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;
	cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
	bmake depend;
	bmake;

                read -p "Procedere con la fase C4? [y/n]" yn
                case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) ;;
                        * ) echo "Please answer yes or no.";;
                esac
        done

	# esecuzione della fase C4
	cd /home/pds/os161/os161-base-2.0.2/kern/conf;
	./config $configStr;
	cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
	bmake depend;
	bmake;
	bmake install;
	cd /home/pds/pds-os161/root;
	sys161 kernel;

	# compilazione finita
	echo "la compilazione e' finita"
}

