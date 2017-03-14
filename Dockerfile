FROM matteobachetti/basecontainer

MAINTAINER Matteo Bachetti <matteo@matteobachetti.it>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update -y && apt-get update -y
ENV ASTROSOFT /home/pulsar/pulsar_software
ENV PGPLOT_DIR $ASTROSOFT/pgplot_build

WORKDIR $ASTROSOFT/tempo
RUN ./prepare && \
    ./configure F77=gfortran --prefix=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC > configure.log && \
    make > build.log && make install > install.log

WORKDIR $ASTROSOFT/tempo2
# Workaround for Text file busy error - from mserylak's pulsar_docker
ENV TEMPO2 $ASTROSOFT/tempo2/T2runtime
RUN sync && perl -pi -e 's/chmod \+x/#chmod +x/' bootstrap
RUN ./bootstrap && \
    ./configure F77=gfortran --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT \
        --with-fftw3-dir=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC \
        CXXFLAGS="-I$ASTROSOFT/include -I$PGPLOT_DIR" LDFLAGS=-L$PGPLOT_DIR > configure.log && \
    make > build.log && make install > install.log && \
    make plugins > plugins.log && make plugins-install > plugins-install.log && \
    make clean > clean.log

WORKDIR $ASTROSOFT/psrchive
RUN sync && perl -pi -e 's/chmod \+x/#chmod +x/' bootstrap
RUN ./bootstrap && \
    ./configure F77=gfortran --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT --with-fftw3-dir=$ASTROSOFT \
        --enable-shared CFLAGS=-fPIC FFLAGS=-fPIC > configure.log && \
    make >build.log && make install >install.log && make clean > clean.log

WORKDIR $ASTROSOFT/sigproc
RUN sync && perl -pi -e 's/chmod \+x/#chmod +x/' bootstrap
RUN ./bootstrap && \
    ./configure --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT \
        --with-fftw-dir=$ASTROSOFT F77=gfortran CFLAGS=-fPIC \
        FFLAGS=-fPIC CPPFLAGS=-I$ASTROSOFT/include \
        LDFLAGS="-L$ASTROSOFT/lib -L$PGPLOT_DIR -L/usr/lib/x86_64-linux-gnu" \
        LIBS="-lX11 -ltempo2pred -lpng" > configure.log && \
    make > build.log && make install > install.log && make clean > clean.log

WORKDIR $ASTROSOFT/dspsr
RUN echo apsr asp bcpm bpsr caspsr cpsr2 cpsr dummy fits gmrt guppi kat lbadr64 lbadr lump lwa mark4 mark5 maxim mwa pdev pmdaq s2 sigproc spda1k spigot vdif > backends.list && \
    ./bootstrap && sleep 1 && \
    ./configure --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT \
        F77=gfortran CFLAGS=-fPIC FFLAGS=-fPIC LDFLAGS=-L$PGPLOT_DIR > configure.log && \
    make > build.log && make install > install.log && make clean > clean.log

CMD [ "/bin/bash" ]
