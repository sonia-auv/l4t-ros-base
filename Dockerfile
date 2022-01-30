
ARG L4T_IMG_TAG=r32.4.2
FROM nvcr.io/nvidia/l4t-base:${L4T_IMG_TAG}

# Highly inspired on
# https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/ros-core/Dockerfile
# https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/ros-base/Dockerfile
# https://github.com/osrf/docker_images/blob/master/ros/noetic/ubuntu/focal/robot/Dockerfile

ARG BUILD_DATE
ARG VERSION
ARG TARGET_ROS_META_PACKAGE=robot

LABEL maintainer="club.sonia@etsmtl.net"
LABEL net.etsmtl.sonia-auv.base_img.build-date=${BUILD_DATE}
LABEL net.etsmtl.sonia-auv.base_img.version=${VERSION}

# System Specific
ENV DEBIAN_FRONTEND=noninteractive

# ROS Specific
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO=noetic


# ROS Install Start
# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# Setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

# Install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    dirmngr \
    gnupg2 \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    && rosdep init  \
    && rosdep update --rosdistro ${ROS_DISTRO} \
    && rm -rf /var/lib/apt/lists/*

# Install ROS packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-ros-base=1.5.0-1* \
    ros-${ROS_DISTRO}-${TARGET_ROS_META_PACKAGE}=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
