FROM matteobachetti/basecontainer

MAINTAINER Matteo Bachetti <matteo@matteobachetti.it>

USER pulsar

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
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

# PRESTO - excerpt from mserylak
ENV PRESTO $ASTROSOFT/presto
ENV PATH $PATH:$PRESTO/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PRESTO/lib
ENV PYTHONPATH $PYTHONPATH:$PRESTO/lib/python
WORKDIR $PRESTO/src
# RUN make makewisdom
RUN make prep && mv Makefile Makefile.bak
RUN cat Makefile.bak | sed -e 's/.ffast-math/-ffast-math -lm/' > Makefile
RUN make FFTINC="-I$(ASTROSOFT)/include" FFTLINK="-L$(ASTROSOFT)/lib -lfftw3f" CFITSIOINC="-I$(ASTROSOFT)/include" \
        CFITSIOLINK="-L$(ASTROSOFT)/lib -lcfitsio" FFLAGS='-g -fPIC'
WORKDIR $PRESTO/python/ppgplot_src
RUN mv _ppgplot.c _ppgplot.c_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/ppgplot/_ppgplot.c
WORKDIR $PRESTO/python
RUN make FFTINC="-I$(ASTROSOFT)/include" FFTLINK="-L$(ASTROSOFT)/lib -lfftw3f" CFITSIOINC="-I$(ASTROSOFT)/include" \
        CFITSIOLINK="-L$(ASTROSOFT)/lib -lcfitsio" FFLAGS='-g -fPIC'

CMD [ "/bin/bash" ]
