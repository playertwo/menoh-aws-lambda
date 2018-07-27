#!/bin/sh

MKLDNN_TAG="v0.15"
MENOH_TAG="v1.0.3"
PROTOBUF_TAG="v3.6.0"
MKL_VERSION="2018.3.222"
MKL_VERSION2="18.0.3-222-18.0.3-222"
MKL_VERSION3="2018.3-222-2018.3-222"
MKL_VERSION4="2018-2018.3-222"

set -ev

#sudo yum –y install epel-release
sudo yum-config-manager --enable epel
sudo yum -y install gcc48-c++ cmake3 libtool
#sudo yum -y upgrade
#sudo yum -y groupinstall "Development Tools"
#sudo update-alternatives --set gcc /usr/bin/gcc48

cd $HOME

if [ ! -d protobuf ]; then
  git clone --branch $PROTOBUF_TAG --depth=1 https://github.com/google/protobuf.git
  cd protobuf && ./autogen.sh && ./configure --with-pic --disable-shared && make -j4 && sudo make install && sudo ldconfig
  cd $HOME
fi

if [ ! -f mkl.tgz ]; then
  curl -o mkl.tgz $1
  tar -xzf mkl.tgz
  cd l_mkl_$MKL_VERSION/rpm
  sudo yum -y install intel-openmp-$MKL_VERSION2.x86_64.rpm \
                      intel-mkl-common-$MKL_VERSION3.noarch.rpm \
                      intel-mkl-core-rt-$MKL_VERSION3.x86_64.rpm \
                      intel-mkl-core-$MKL_VERSION3.x86_64.rpm \
                      intel-comp-nomcu-vars-$MKL_VERSION2.noarch.rpm \
                      intel-mkl-doc-$MKL_VERSION4.noarch.rpm \
                      intel-comp-l-all-vars-$MKL_VERSION2.noarch.rpm \
                      intel-mkl-common-c-$MKL_VERSION3.noarch.rpm

  sudo cp -r /opt/intel/compilers_and_libraries_$MKL_VERSION/linux/mkl/lib/intel64/*.a /usr/local/lib
  sudo cp -r /opt/intel/compilers_and_libraries_$MKL_VERSION/linux/mkl/include/* /usr/local/include
  sudo cp -r /opt/intel/compilers_and_libraries_$MKL_VERSION/linux/compiler/lib/intel64/*.a /usr/local/lib
  cd $HOME
fi

if [ ! -d mkl-dnn ]; then
  git clone --branch $MKLDNN_TAG --depth=1 https://github.com/intel/mkl-dnn.git
  cd mkl-dnn
  git apply $HOME/menoh-aws-lambda/mkl-dnn-static.patch
  mkdir build && cd build
  cmake3 ..
  make -j4 && sudo make install
  cd $HOME
fi

if [ ! -d menoh ]; then
  sudo yum -y install gcc64-c++
  git clone --branch $MENOH_TAG --depth=1 https://github.com/pfnet-research/menoh.git
  cd menoh
  git apply $HOME/menoh-aws-lambda/menoh-static.patch
  mkdir build && cd build
  cmake3 -DENABLE_EXAMPLE=0 -DENABLE_TOOL=0 ..
  make -j4
  zip -9 -q -r ~/deps.zip menoh/libmenoh.so
  cd $HOME
fi
