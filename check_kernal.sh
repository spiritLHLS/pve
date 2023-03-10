#!/bin/bash
#from https://github.com/spiritLHLS/pve

# 用颜色输出信息
_red() { echo -e "\033[31m\033[01m$@\033[0m"; }
_green() { echo -e "\033[32m\033[01m$@\033[0m"; }
_yellow() { echo -e "\033[33m\033[01m$@\033[0m"; }
_blue() { echo -e "\033[36m\033[01m$@\033[0m"; }

# 检查CPU是否支持硬件虚拟化
if [ "$(egrep -c '(vmx|svm)' /proc/cpuinfo)" -eq 0 ]; then
    _red "CPU不支持硬件虚拟化，无法嵌套虚拟化KVM服务器，但可以开LXC服务器(CT)"
    exit 1
else
    _green "本机CPU支持KVM硬件嵌套虚拟化"
fi

# 检查虚拟化选项是否启用
if [ "$(grep -E -c '(vmx|svm)' /proc/cpuinfo)" -eq 0 ]; then
    _red "BIOS中未启用硬件虚拟化，无法嵌套虚拟化KVM服务器，但可以开LXC服务器(CT)"
    exit 1
else
    _green "本机BIOS支持KVM硬件嵌套虚拟化"
fi

# 查询系统是否支持
if [ "$(cat /sys/module/kvm_intel/parameters/nested)" = "Y" ]; then
    if lsmod | grep -q kvm; then
        _green "本机系统支持KVM硬件嵌套虚拟化"
        _green "本机符合要求：可以使用PVE虚拟化KVM服务器，并可以在开出来的KVM服务器选项中开启KVM硬件虚拟化"
    else
        _yellow "KVM模块未加载，不能使用PVE虚拟化KVM服务器，但可以开LXC服务器(CT)"
    fi
else
    _yellow "本机操作系统不支持KVM硬件嵌套虚拟化，使用PVE虚拟化出来的KVM服务器不能在选项中开启KVM硬件虚拟化，记得在开出来的KVM服务器选项中关闭"
    exit 1
fi

# 如果KVM模块未加载，则加载KVM模块并将其添加到/etc/modules文件中
if ! lsmod | grep -q kvm; then
    _yellow "尝试加载KVM模块……"
    modprobe kvm
    echo "kvm" >> /etc/modules
    _green "KVM模块已加载并添加到 /etc/modules，可以尝试使用PVE虚拟化KVM服务器，也可以开LXC服务器(CT)"
fi
