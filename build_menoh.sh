#!/bin/sh

MKLDNN_TAG="v0.14"
#MKLDNN_TAG="master"
#MKLDNN_COMMIT="a46b870"
MENOH_TAG="v1.0.3"
PROTOBUF_TAG="v3.6.0"

# MKL_VERSION="2018.2.199"
# MKL_VERSION2="18.0.2-199-18.0.2-199"
# MKL_VERSION3="2018.2-199-2018.2-199"
# MKL_VERSION4="2018-2018.2-199"

MKL_VERSION="2018.3.222"
MKL_VERSION2="18.0.3-222-18.0.3-222"
MKL_VERSION3="2018.3-222-2018.3-222"
MKL_VERSION4="2018-2018.3-222"

JOBS="8"

TEST=true

set -ev

sudo yum-config-manager --enable epel
sudo yum -y install gcc64-c++ cmake3 libtool


cd $HOME

if [ ! -d protobuf ]; then
  git clone --branch $PROTOBUF_TAG --depth=1 https://github.com/google/protobuf.git
  cd protobuf && ./autogen.sh && ./configure --with-pic --disable-shared && make -j$JOBS && sudo make install && sudo ldconfig
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
  #git checkout $MKLDNN_COMMIT
  #git apply $HOME/menoh-aws-lambda/mkl-dnn-static.patch
  git apply $HOME/menoh-aws-lambda/mkl-dnn-static_0_14.patch
  mkdir build && cd build
  cmake3 ..
  make -j$JOBS && sudo make install
  if $TEST ; then make test ; fi
  cd $HOME
fi

if [ ! -d menoh ]; then
  #git clone --branch $MENOH_TAG --depth=1 https://github.com/pfnet-research/menoh.git
  git clone --branch skip_flatten --depth=1 https://github.com/playertwo/menoh.git
  cd menoh
  if $TEST ; then
    mkdir data
    sudo env "PATH=$PATH" pip install --upgrade pip
    sudo env "PATH=$PATH" pip install chainer
    python gen_test_data.py
  fi

  git apply $HOME/menoh-aws-lambda/menoh-static.patch
  mkdir build && cd build
  cmake3 -DENABLE_EXAMPLE=0 -DENABLE_TOOL=0 -DENABLE_TEST=1 ..
  make -j$JOBS
  zip -9 -q -r ~/deps.zip menoh/libmenoh.so
  if $TEST ; then ./test/menoh_test ; fi
  cd $HOME
fi
