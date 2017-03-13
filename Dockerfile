FROM ubuntu:16.04

MAINTAINER Matteo Bachetti <matteo@matteobachetti.it>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update -y && apt-get update -y

RUN apt-get install -y  ftp \
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
    wget http://www.fftw.org/fftw-3.3.6-pl1.tar.gz && \
    wget http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio_latest.tar.gz && \
    wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz && \
    wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz && \
    mkdir fftw-3 cfitsio psrcat_tar pgplot && \
    tar zxvf fftw-3.3.6-pl1.tar.gz -C /home/pulsar/pulsar_software/fftw-3 --strip-components=1 && \
    tar zxvf cfitsio_latest.tar.gz -C /home/pulsar/pulsar_software/cfitsio --strip-components=1 && \
    tar zxvf psrcat_pkg.tar.gz -C /home/pulsar/pulsar_software/psrcat_tar --strip-components=1 && \
    tar zxvf pgplot5.2.tar.gz -C /home/pulsar/pulsar_software/pgplot --strip-components=1 && \
    rm *.tar.gz

RUN cd /home/pulsar/pulsar_software && \
    git clone -v https://bitbucket.org/psrsoft/tempo2.git && \
    git clone -v git://github.com/scottransom/presto.git && \
    git clone -v git://git.code.sf.net/p/psrchive/code psrchive && \
    git clone -v git://git.code.sf.net/p/tempo/tempo && \
    git clone -v git://git.code.sf.net/p/dspsr/code dspsr && \
    git clone -v https://github.com/SixByNine/sigproc.git

ENV ASTROSOFT /home/pulsar/pulsar_software

RUN cd /home/pulsar/pulsar_software/fftw-3 && \
    ./configure --prefix=$ASTROSOFT --enable-float --enable-threads --enable-shared CFLAGS=-fPIC FFLAGS=-fPIC && \
    make && make check && make install && make clean && \
    ./configure --prefix=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC && \
    make && make check && make install && make clean

RUN cd /home/pulsar/pulsar_software/cfitsio && \
    ./configure --prefix=$ASTROSOFT CFLAGS=-fPIC FFLAGS=-fPIC && \
    make shared && \
    make install && \
    make clean

RUN cd /home/pulsar/pulsar_software/psrcat_tar && source makeit && cp psrcat $ASTROSOFT/bin/

CMD [ "/bin/bash" ]
