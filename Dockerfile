FROM ikeyasu/opengl:cuda8.0-cudnn5-devel-ubuntu16.04
MAINTAINER ikeyasu <ikeyasu@gmail.com>

ENV DEBIAN_FRONTEND oninteractive

############################################
# Basic dependencies
############################################
RUN apt-get update --fix-missing && apt-get install -y \
      python3-numpy python3-matplotlib python3-dev \
      python3-opengl python3-pip \
      cmake zlib1g-dev libjpeg-dev xvfb libav-tools \
      xorg-dev libboost-all-dev libsdl2-dev swig \
      git  wget\
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

############################################
# Change the working directory
############################################
WORKDIR /opt

############################################
# OpenAI Gym and Keras
# It seems that keras always use the module installed last. 
# https://github.com/fchollet/keras/issues/6997
############################################
RUN pip3 install --upgrade pip
RUN pip3 install h5py keras future chainer cupy 'gym[atari]' 'gym[box2d]' 'gym[classic_control]'

############################################
# Roboschool
############################################
RUN apt-get update && apt-get install -y \
      git cmake ffmpeg pkg-config \
      qtbase5-dev libqt5opengl5-dev libassimp-dev \
      libpython3.5-dev libboost-python-dev libtinyxml-dev \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && git clone --depth 1 https://github.com/olegklimov/bullet3 -b roboschool_self_collision \
    && git clone --depth 1 https://github.com/openai/roboschool

ENV ROBOSCHOOL_PATH /opt/roboschool

RUN mkdir -p /opt/bullet3/build \
    && cd /opt/bullet3/build \
    && cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 \
       -DCMAKE_INSTALL_PREFIX:PATH=${ROBOSCHOOL_PATH}/roboschool/cpp-household/bullet_local_install \
       -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF \
       -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF \
       -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF \
       -DBUILD_OPENGL3_DEMOS=OFF .. \
    && make \
    && make install \
    && pip3 install -e ${ROBOSCHOOL_PATH} \
    && ldconfig \
    && make clean

############################################
# Deep Reinforcement Learning
#    OpenAI Baselines
#    Keras-RL
#    ChainerRL
############################################
RUN pip3 install keras-rl chainerrl

# Installing dependency manually insted of pip3 install -e baselines
# because baselines.git has a dependency of mujoco
RUN git clone --depth 1 https://github.com/openai/baselines.git \
    && pip3 install scipy tqdm joblib zmq dill azure==1.0.3 progressbar2 mpi4py

############################################
# Tensorflow (GPU)
# If tensorflow and tensorflow-gpu are installed simultaneously,
# keras selects tensorflow (CPU). So, I uninstall the cpu version,
# and install the gpu version at the end.
############################################
RUN pip3 install tensorflow-gpu==1.2.1

############################################
# locate, less, lxterminal, and vim
############################################
RUN apt-get update && apt-get install -y mlocate less vim lxterminal mesa-utils\
    && updatedb\
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENV APP "lxterminal -e bash"
