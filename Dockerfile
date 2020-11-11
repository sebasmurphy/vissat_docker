FROM nvidia/cuda:10.0-devel

RUN apt-get update && apt-get install -y \
  git \
  cmake \
  build-essential \
  vim 

RUN apt-get update && apt-get install -y \
  libboost-program-options-dev \
  libboost-filesystem-dev \
  libboost-graph-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-test-dev \
  libeigen3-dev \
  libsuitesparse-dev \
  libfreeimage-dev \
  libgoogle-glog-dev \
  libgflags-dev \
  libglew-dev

RUN apt-get update && apt-get install -y \
  qtbase5-dev \
  libqt5opengl5-dev \
  libcgal-dev \
  libcgal-qt5-dev

RUN mkdir /tools

# install ceres-solver

WORKDIR /tools
RUN apt-get update && apt-get install -y libatlas-base-dev libsuitesparse-dev
RUN git clone --branch 1.14.0 https://github.com/ceres-solver/ceres-solver.git
# RUN git clone https://ceres-solver.googlesource.com/ceres-solver
WORKDIR /tools/ceres-solver
# RUN git checkout $(git describe --tags)

RUN mkdir build
WORKDIR /tools/ceres-solver/build
RUN cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
RUN make -j4 && make install

# symlink to fix looking for gcc
# RUN ln -s /usr/bin/gcc /usr/bin/gcc-6 
# RUN ln -s /usr/bin/g++ /usr/bin/g++-6

WORKDIR /tools
RUN git clone https://github.com/Kai-46/ColmapForVisSat
WORKDIR /tools/ColmapForVisSat
RUN mkdir build
WORKDIR /tools/ColmapForVisSat/tools
RUN CC=/usr/bin/gcc CXX=/usr/bin/g++ cmake ..
RUN make -j4 && make install

#install python 3 requirements
RUN apt-get update && apt-get install -y \
  python3-pip \ 
  python3-setuptools \ 
  software-properties-common

RUN pip3 install wheel

# Vis Satellite Stereo
WORKDIR /tools
RUN git clone https://github.com/sebasmurphy/VisSatSatelliteStereo.git
WORKDIR /tools/VisSatSatelliteStereo
RUN pip3 install -r requirements.txt

# install GDAL
RUN add-apt-repository ppa:ubuntugis/ppa
RUN apt-get update && apt-get install -y \ 
  gdal-bin \
  libgdal-dev
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
RUN pip3 install GDAL==2.4.2

WORKDIR /tools/VisSatSatelliteStereo
CMD ["/usr/bin/python3", "stereo_pipeline.py", "--config_file", "/input/config.json"]
