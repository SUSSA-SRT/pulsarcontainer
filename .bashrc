# Set shell prompt
export PS1='\h:\W \$ '

# shell aliases
alias ls="ls -G --color=auto"
alias lr="ls -FlArt"
alias lrh="lr -h"
alias la="ls -al"
alias lh="la -h"
alias ll="ls -l"
alias pu="rm *~"
alias emacs="emacs -nw"
alias open="xdg-open"

# ---------------------------------
# http://www.ljtwebdevelopment.com/pulsarref/pulsar-software-install-ubuntu.html
# Path to the pulsar software installation directory eg:
export ASTROSOFT=/home/pulsar/pulsar_software

# OSTYPE
export OSTYPE=linux

# PSRCAT
export PSRCAT_RUNDIR=$ASTROSOFT/psrcat_tar
export PSRCAT_FILE=$ASTROSOFT/psrcat_tar/psrcat.db

# Tempo
export TEMPO=$ASTROSOFT/tempo

# Tempo2
export TEMPO2=$ASTROSOFT/tempo2/T2runtime

# PGPLOT
export PGPLOT_DIR=$ASTROSOFT/pgplot_build
export PGPLOT_DEV=/xwindow

# PRESTO
export PRESTO=$ASTROSOFT/presto

# MULTINEST
export MULTINEST_DIR=$ASTROSOFT/TempoNest/MultiNest

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu:$PGPLOT_DIR:$ASTROSOFT/lib:$PRESTO/lib:$PRESTO/lib64:$MULTINEST_DIR

# PATH
# Some Presto executables match sigproc executables so keep separate -
# all other executables are found in $ASTROSOFT/bin
export PATH=$PATH:$ASTROSOFT/bin:$PRESTO/bin:$PGPLOT_DIR

# PYTHON PATH eg.
export PYTHONPATH=$PRESTO/lib/python:$PRESTO/lib64/python:/usr/lib/python2.7/site-packages/:/usr/lib64/python2.7/site-packages:$ASTROSOFT/lib/python2.7/site-packages
