# This dockerfile expects proxies to be set via --build-arg if needed
# It also expects to be contained in the /navigation2 root folder for file copy
#
# Example build command where pwd is this here:
# export ROS_DISTRO=crystal
# docker build \
#   --tag nav2:${ROS_DISTRO} \
#   --build-arg FROM_IMAGE=ros:${ROS_DISTRO} \
#   --build-arg CMAKE_BUILD_TYPE=Debug \
#   --file Dockerfile ../../.

ARG FROM_IMAGE=ros:crystal
FROM $FROM_IMAGE

# install ROS2 dependencies
RUN apt-get update && apt-get install -q -y \
      build-essential \
      cmake \
      git \
      python3-colcon-common-extensions \
      python3-vcstool \
      wget \
    && rm -rf /var/lib/apt/lists/*

# copy ros package repo
ENV NAV2_WS /opt/nav2_ws
RUN mkdir -p $NAV2_WS/src
WORKDIR $NAV2_WS/src
COPY ./ navigation2/

# delete ignore files so rosdep may resolve dependencies
RUN rm $NAV2_WS/src/navigation2/nav2_system_tests/COLCON_IGNORE

# install navigation2 package dependencies
WORKDIR $NAV2_WS
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    apt-get update && \
    rosdep install -q -y \
      --from-paths \
        src \
      --ignore-src \
    && rm -rf /var/lib/apt/lists/*

# build navigation2 package source
ARG CMAKE_BUILD_TYPE=Release
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build \
      --symlink-install \
      --cmake-args \
        -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE

# source navigation2 workspace from entrypoint
RUN sed --in-place --expression \
      '$isource "$NAV2_WS/install/setup.bash"' \
      /ros_entrypoint.sh
