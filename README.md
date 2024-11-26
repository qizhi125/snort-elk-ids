# 基于 Snort 和 ELK 的入侵检测系统

本项目旨在构建一个基于 Snort 的网络入侵检测系统（IDS），并结合 ELK 堆栈（Elasticsearch、Logstash、Kibana）进行日志记录、数据分析和可视化。整个安装过程是在 WSL 环境下运行的 Fedora 40 中完成的。

## 项目概述

- **Snort**：一个强大的网络入侵检测系统，用于监控网络流量并依据一系列规则进行分析。
- **ELK 堆栈**：包括 Elasticsearch、Logstash 和 Kibana，用于数据存储、分析和可视化。

本系统配置运行在 **Fedora 40** 中，使用 **WSL (Windows Subsystem for Linux)**，它可以在 Windows 上提供一个 Linux 兼容的环境，方便测试和集成。

## 系统要求

- **操作系统**：Fedora 40（运行于 Windows 的 WSL 中）
- **Snort 版本**：Snort 3
- **ELK 堆栈版本**：Elasticsearch 8.x，Logstash 8.x，Kibana 8.x

## 安装与配置概述

在项目中，我们提供了一个自动化脚本 `install_snort.sh`，可以帮助你快速完成 Snort 3 及其依赖项的安装和配置。

### 自动化脚本

项目中包含的 `install_snort.sh` 脚本会自动执行以下任务：
- 配置 Fedora 的 DNF 仓库。
- 安装 Snort 所需的依赖项，包括必需和可选的库。
- 克隆并构建 LibDAQ。
- 克隆并构建 Snort 3。
- 配置 Snort 的必要目录和默认配置文件。

### 使用自动化脚本

要使用自动化脚本，请执行以下命令：

```bash
sudo scripts/install_snort.sh
```

该脚本将根据你的 WSL 环境在 Fedora 40 中自动安装和配置 Snort 3。建议在运行脚本前确保你的系统已更新至最新版本。

### WSL 注意事项

- **Systemctl**：WSL 不支持 `systemctl` 来管理服务，取而代之，可以使用手动命令来启动 Snort 等服务。
- **网络限制**：在 WSL 中某些网络功能可能会受到限制，建议在虚拟机中测试 Snort 的完整功能。

### 项目结构
snort-elk-ids/ ├── README.md ├── snort/ │ └── snort.lua (Snort 配置文件) ├── elk/ │ └── snort-logstash.conf (Logstash 的 Snort 配置文件) ├── config/ ├── scripts/ │ └── install_snort.sh (安装脚本)


### 参考文献

1. RichardLuo. [Snort安装](https://www.cnblogs.com/RichardLuo/p/Snort_Install.html). 博客园, 访问于2024年11月26日。
2. Snort Team. [Snort++ Documentation](https://snort.org/documents). Snort官网, 访问于2024年11月26日。

### 许可

本项目遵循 MIT 许可协议，详情请参阅 LICENSE 文件。

### 作者

- qizhi125
