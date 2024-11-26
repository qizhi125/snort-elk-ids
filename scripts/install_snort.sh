#!/bin/bash

# 脚本用于在 Fedora 40 WSL 上安装 Snort 3 以及其所有依赖项

# 确保以 root 用户身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 用户身份运行此脚本"
  exit 1
fi

# 配置阿里云镜像源
echo "配置阿里云镜像源..."
wget -O /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo
wget -O /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo

# 更新系统并重启（WSL 环境重启不会断开所有工作）
echo "更新系统..."
dnf makecache && dnf update -y

# 设置链接器路径
echo "设置链接器路径..."
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
echo '/usr/local/lib64' >> /etc/ld.so.conf.d/local.conf
ldconfig

# 安装构建 LibDAQ 所需的软件
echo "安装构建工具和依赖项..."
dnf install git vim flex bison gcc gcc-c++ make cmake automake autoconf libtool -y

# 安装必需的依赖项
echo "安装 Snort 必需依赖项..."
dnf install libpcap-devel pcre-devel libdnet-devel hwloc-devel openssl-devel zlib-devel luajit-devel pkgconf libmnl-devel libunwind-devel -y

# 可选：安装 NFQ 支持
echo "安装 NFQ 支持..."
dnf install libnfnetlink-devel libnetfilter_queue-devel -y

# 克隆并安装 LibDAQ
echo "克隆并安装 LibDAQ..."
git clone https://github.com/snort3/libdaq.git
cd libdaq
./bootstrap
./configure
make
make install
ldconfig
cd ../

# 安装可选依赖项
echo "安装 LZMA 和 UUID..."
dnf install xz-devel libuuid-devel -y

echo "安装 Hyperscan..."
dnf install hyperscan hyperscan-devel -y

echo "安装 Flatbuffers..."
curl -Lo flatbuffers-v23.3.3.tar.gz https://github.com/google/flatbuffers/archive/refs/tags/v23.3.3.tar.gz
tar xf flatbuffers-v23.3.3.tar.gz
mkdir fb-build && cd fb-build
cmake ../flatbuffers-23.3.3
make -j$(nproc)
make -j$(nproc) install
ldconfig
cd ../

echo "安装 Safec..."
dnf install libsafec libsafec-devel -y
ln -s /usr/lib64/pkgconfig/safec-3.3.pc /usr/lib64/pkgconfig/libsafec.pc

echo "安装 Tcmalloc..."
dnf install gperftools-devel -y

# 克隆并安装 Snort 3
echo "克隆并安装 Snort 3..."
git clone https://github.com/snort3/snort3.git
cd snort3

# 配置 PKG_CONFIG_PATH
echo "配置 PKG_CONFIG_PATH..."
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH

# 启用 Tcmalloc 并构建 Snort 3
echo "启用 Tcmalloc 并构建 Snort 3..."
export CFLAGS="-O3"
export CXXFLAGS="-O3 -fno-rtti"
./configure_cmake.sh --prefix=/usr/local/snort --enable-tcmalloc

# 构建和安装 Snort 3
cd build
make -j$(nproc)
make -j$(nproc) install
cd ../../

# 验证安装
echo "验证 Snort 安装..."
/usr/local/snort/bin/snort -V

# 配置日志和规则目录
echo "配置 Snort 日志和规则目录..."
mkdir -p /usr/local/snort/etc/rules
mkdir -p /usr/local/snort/var/log

# 将默认配置文件复制到配置目录
echo "复制 Snort 配置文件..."
cp /usr/local/snort/etc/snort/snort.lua snort/

# 打印提示信息
echo "安装已完成。"
echo "请根据需要在 'snort/snort.lua' 中修改配置。"
echo "要运行 Snort，请使用以下命令："
echo "/usr/local/snort/bin/snort -c /usr/local/snort/etc/snort/snort.lua -i eth0"
echo "（请将 eth0 替换为你的网络接口名称）"

echo "Snort 3 安装完成。"
