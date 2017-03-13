FROM ubuntu:16.04

MAINTAINER Matteo Bachetti <matteo@matteobachetti.it>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update -y && apt-get update -y

RUN apt-get install -qq ftp \
                        wget \
                        csh \
                        build-essential \
                        gfortran \
                        libpng12-dev \
                        libgd2-xpm-dev \
                        cvs \
                        autoconf \
                        automake \
                        libtool \
                        m4 \
                        git \
                        gsl-bin \
                        libgsl0-dev \
                        flex \
                        bison \
                        fort77 \
                        libglib2.0-dev \
                        gnuplot \
                        gnuplot-x11 \
                        python-dev \
                        python-numpy \ 
                        python-scipy \ 
                        python-matplotlib \ 
                        ipython \ 
                        python-sympy \
                        python-nose \ 
                        swig \
                        libltdl-dev \
                        libltdl7 \
                        dkms \
                        htop \
                        screen \
                        xterm \
                        emacs \
                        gpicview \
                        xpdf \
                        cmake \
                        default-jre \
                        default-jdk \
                        libblas3 \
                        liblapack3 \
                        libblas-dev \
                        liblapack-dev \
                        libxext-dev \
                        libx11-dev \
                        libopenmpi-dev \ 
                        openmpi-bin \ 
                        libhdf5-openmpi-dev \
                        mpich \ 
                        libmpich-dev \ 
                        libhdf5-mpich-dev \
                        sudo \
                        imagemagick

RUN useradd -m pulsar && echo "pulsar:pulsar" | chpasswd && adduser pulsar sudo

USER pulsar

COPY .bashrc /home/pulsar/.bashrc

RUN cd /home/pulsar && pwd && id && . /home/pulsar/.bashrc && mkdir pulsar_software && cd pulsar_software

RUN cd /home/pulsar/pulsar_software && \
    wget -q http://www.fftw.org/fftw-3.3.6-pl1.tar.gz && \
    wget -q http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio_latest.tar.gz && \
    wget -q http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz && \
    wget -q ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz && \
    mkdir fftw-3 cfitsio psrcat_tar pgplot && \
    tar zxf fftw-3.3.6-pl1.tar.gz -C /home/pulsar/pulsar_software/fftw-3 --strip-components=1 && \
    tar zxf cfitsio_latest.tar.gz -C /home/pulsar/pulsar_software/cfitsio --strip-components=1 && \
    tar zxf psrcat_pkg.tar.gz -C /home/pulsar/pulsar_software/psrcat_tar --strip-components=1 && \
    tar zxf pgplot5.2.tar.gz -C /home/pulsar/pulsar_software/pgplot --strip-components=1 && \
    rm *.tar.gz

RUN cd /home/pulsar/pulsar_software && \
    git clone https://bitbucket.org/psrsoft/tempo2.git && \
    git clone git://github.com/scottransom/presto.git && \
    git clone git://git.code.sf.net/p/psrchive/code psrchive && \
    git clone git://git.code.sf.net/p/tempo/tempo && \
    git clone git://git.code.sf.net/p/dspsr/code dspsr && \
    git clone https://github.com/SixByNine/sigproc.git

ENV ASTROSOFT /home/pulsar/pulsar_software

RUN cd /home/pulsar/pulsar_software/fftw-3 && \
    ./configure --prefix=$ASTROSOFT --enable-float --enable-threads --enable-shared CFLAGS=-fPIC FFLAGS=-fPIC > configure.log && \
    make > build.log && make check > check.log && make install > install.log && make clean  > clean.log && \
    ./configure --prefix=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC && \
    make > build2.log && make check > check2.log && make install > install2.log && make clean > clean2.log

RUN cd /home/pulsar/pulsar_software/cfitsio && \
    ./configure --prefix=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC > configure.log && \
    make shared > shared.log && \
    make install > install.log && \
    make clean > clean.log

RUN cd /home/pulsar/pulsar_software/psrcat_tar && /bin/bash -c "source makeit" && cp psrcat $ASTROSOFT/bin/

RUN cd /home/pulsar/pulsar_software/ && mkdir pgplot_build

COPY pgplot_drivers.list /home/pulsar/pulsar_software/pgplot_build/drivers.list

COPY pgplot_makefile /home/pulsar/pulsar_software/pgplot_build/makefile

COPY pgplot_grexec.f $ASTROSOFT/pgplot_build/grexec.f

RUN cd $ASTROSOFT/pgplot_build && make > build.log && make clean > clean.log && make cpg > cpg.log && \
    ld -shared -o libcpgplot.so --whole-archive libcpgplot.a

ENV PGPLOT_DIR $ASTROSOFT/pgplot_build

RUN cd $ASTROSOFT/tempo && ./prepare && \
    ./configure F77=gfortran --prefix=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC > configure.log && \
    make > build.log && make install > install.log

RUN cd $ASTROSOFT/tempo2 && ./bootstrap && sleep 1 && \
    ./configure F77=gfortran --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT \
        --with-fftw3-dir=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC \
        CXXFLAGS="-I$ASTROSOFT/include -I$PGPLOT_DIR" LDFLAGS=-L$PGPLOT_DIR > configure.log && \
    make > build.log && make install > install.log && \
    make plugins > plugins.log && make plugins-install > plugins-install.log && \
    make unsupported > unsupported.log && make clean > clean.log

RUN cd $ASTROSOFT/psrchive && ./bootstrap && sleep 1 && \
    ./configure F77=gfortran --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT --with-fftw3-dir=$ASTROSOFT \
        --enable-shared CFLAGS=-fPIC FFLAGS=-fPIC > configure.log && \
    make >build.log && make install >install.log && make clean > clean.log

RUN cd $ASTROSOFT/sigproc && ./bootstrap && sleep 1 && \
    ./configure --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT \
        --with-fftw-dir=$ASTROSOFT F77=gfortran CFLAGS=-fPIC \
        FFLAGS=-fPIC CPPFLAGS=-I$ASTROSOFT/include \
        LDFLAGS="-L$ASTROSOFT/lib -L$PGPLOT_DIR -L/usr/lib/x86_64-linux-gnu" \
        LIBS="-lX11 -ltempo2pred -lpng" > configure.log && \
    make > build.log && make install > install.log && make clean > clean.log

RUN cd $ASTROSOFT/dspsr && \
    echo apsr asp bcpm bpsr caspsr cpsr2 cpsr dummy fits gmrt guppi kat lbadr64 lbadr lump lwa mark4 mark5 maxim mwa pdev pmdaq s2 sigproc spda1k spigot vdif > backends.list && \
    ./bootstrap && sleep 1 && \
    ./configure --prefix=$ASTROSOFT --with-cfitsio-dir=$ASTROSOFT \
        F77=gfortran CFLAGS=-fPIC FFLAGS=-fPIC LDFLAGS=-L$PGPLOT_DIR > configure.log && \
    make > build.log && make install > install.log && make clean > clean.log

CMD [ "/bin/bash" ]
