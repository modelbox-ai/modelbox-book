#!/bin/sh

USE_CN_MIRROR=0
PIP_CN_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
NPM_CN_MIRROR="https://registry.npmmirror.com"
UBUNTU_APT_MIRROR="http://mirrors.huaweicloud.com/ubuntu"
UBUNTU_APT_PORTS_MIRROR="http://mirrors.huaweicloud.com/ubuntu-ports"
DEBIAN_APT_MIRROR="http://mirrors.huaweicloud.com/debian"
DEBIAN_SECURITY_APT_MIRROR="http://mirrors.huaweicloud.com/debian-security"

MODELBOX_GIT_GITHUB_REPO="https://github.com/modelbox-ai/modelbox.git"
MODELBOX_GIT_GITEE_REPO="https://gitee.com/modelbox/modelbox.git"
MODELBOX_GIT_REPO="${MODELBOX_GIT_GITHUB_REPO}"

MINDSPORE_VER="1.7.0"
JOB_NUMBER=2

OSARCH="$(uname -m)"

setup_cn_mirror()
{
    if [ "${USE_CN_MIRROR}" = "0" ]; then
        return 
    fi

    echo "setup cn mirror"
    MODELBOX_GIT_REPO="${MODELBOX_GIT_GITEE_REPO}"
    CMAKE_CN_MIRROR_FLAG="-DUSE_CN_MIRROR=yes"
    PIP_MIRROR_FLAGS="-i ${PIP_CN_MIRROR}"

    OS="$(cat /etc/os-release  | grep ^ID= | awk -F= '{print $2}')"

    if [ "${OS}" = "debian" ]; then
        grep "${DEBIAN_APT_MIRROR}" /etc/apt/sources.list 2>&1 > /dev/null
        if [ $? -ne 0 ]; then
            cp /etc/apt/sources.list /etc/apt/sources.list.origin
            sed "s@http://deb.debian.org/debian@${DEBIAN_APT_MIRROR}@g" -i /etc/apt/sources.list
            if [ $? -ne 0 ]; then
                echo "setup apt source failed."
                return 1
            fi

            sed "s@http://security.debian.org/debian-security@${DEBIAN_SECURITY_APT_MIRROR}@g" -i /etc/apt/sources.list
            if [ $? -ne 0 ]; then
                echo "setup apt security source failed."
                return 1
            fi 
        fi
    elif [ "${OS}" = "ubuntu" ]; then
        REPOTYPE="http://ports.ubuntu.com/ubuntu-ports"
        REPOMIRROR="${UBUNTU_APT_PORTS_MIRROR}"
        if [ "${OSARCH}" = "x86" ] || [ "${OSARCH}" = "x86_64" ]; then
            REPOTYPE="http://archive.ubuntu.com/ubuntu"
            REPOMIRROR="${UBUNTU_APT_MIRROR}"
        fi 

        grep "${REPOMIRROR}" /etc/apt/sources.list 2>&1 > /dev/null
        if [ $? -ne 0 ]; then
            cp /etc/apt/sources.list /etc/apt/sources.list.origin
            sed "s@${REPOTYPE}@${REPOMIRROR}@g" -i /etc/apt/sources.list
            if [ $? -ne 0 ]; then
                echo "setup apt source failed."
                return 1
            fi
        fi  
    fi
}

setup_env() 
{
    export DEBIAN_FRONTEND=noninteractive
    setup_cn_mirror
}

install_packages() 
{
    apt-get update
    apt-get -y install cmake git wget build-essential npm curl \
        python3 python3-pip python-is-python3 \
        libssl-dev libcpprest-dev libopencv-dev libgraphviz-dev python3-dev \
        libavfilter-dev libavdevice-dev libavcodec-dev
    
    if [ $? -ne 0 ]; then
        echo "install package failed."
        return 1
    fi

    if [ "${USE_CN_MIRROR}" = "1" ]; then
        npm config set registry ${NPM_CN_MIRROR}
    fi

    npm cache clean -f
    npm install -g n
    n stable

    pip install ${PIP_MIRROR_FLAGS} requests opencv-python
    if [ $? -ne 0 ]; then
        echo "install python package failed."
        return 1
    fi

    MINDSPORE_FILE_ARCH="${OSARCH}"
    if [ "${OSARCH}" = "x86_64" ]; then
        MINDSPORE_FILE_ARCH="x64"
    fi

    if [ ! -e "/usr/local/mindspore-lite" ]; then
        wget https://ms-release.obs.cn-north-4.myhuaweicloud.com/${MINDSPORE_VER}/MindSpore/lite/release/linux/${OSARCH}/mindspore-lite-${MINDSPORE_VER}-linux-${MINDSPORE_FILE_ARCH}.tar.gz
        if [ $? -ne 0 ]; then
            echo "download mindspore lite failed."
            return 1
        fi

        tar xf mindspore-lite-${MINDSPORE_VER}-linux-${MINDSPORE_FILE_ARCH}.tar.gz
        if [ $? -ne 0 ]; then
            echo "extract mindspore failed."
            return 1
        fi

        mv mindspore-lite-${MINDSPORE_VER}-linux-${MINDSPORE_FILE_ARCH} /usr/local/
        if [ $? -ne 0 ]; then
            echo "move mindspore lite failed."
            return 1
        fi
        ln -s /usr/local/mindspore-lite-${MINDSPORE_VER}-linux-${MINDSPORE_FILE_ARCH} /usr/local/mindspore-lite
    fi

    return 0
}

build_modelbox()
{
    git clone ${MODELBOX_GIT_REPO}
    CURRDIR="${pwd}"
    if [ $? -ne 0 ]; then
        echo "clone modelbox failed"
        return 1
    fi

    mkdir modelbox/build -p
    if [ $? -ne 0 ]; then
        echo "create build directory failed."
        return 1
    fi

    cd modelbox/build
    cmake .. -DCMAKE_BUILD_TYPE=Debug ${CMAKE_CN_MIRROR_FLAG}
    if [ $? -ne 0 ]; then
        echo "cmake failed."
        return 1
    fi

    make package -j${JOB_NUMBER}
    if [ $? -ne 0 ]; then
        echo "build modelbox failed."
        return 1
    fi

    dpkg -i release/*.deb

    return 0
}


start_modelbox()
{
    modelbox-tool develop -s 
    if [ $? -ne 0 ]; then
        echo "setup modelbox develop env failed."
        return 1
    fi

    echo "start modelbox success"
    return 0
}

main()
{
    while getopts 'mj:' OPT; do
        case ${OPT} in 
            m)
                USE_CN_MIRROR=1 
            ;;
            j)
                JOB_NUMBER="$OPTARG"
            ;;
            ?)
            ;;
        esac
    done

    setup_env
    if [ $? -ne 0 ]; then
        return 1
    fi

    install_packages
    if [ $? -ne 0 ]; then
        return 1
    fi

    build_modelbox
    if [ $? -ne 0 ]; then
        return 1
    fi

    start_modelbox
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

main $@
