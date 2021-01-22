# libbpfgo-beginners
Basic eBPF examples in Golang using libbpfgo

WORK IN PROGRESS! 

eBPF hello world examples using libbpfgo

## Install packages

```sh
sudo apt-get update
sudo apt-get install linux-headers-$(uname -r) make llvm clang libelf-dev pkg-config
```

pkg-config is needs to build the libbpf headers

## Dependencies

libbpfgo is included as a git submodule
We also need stdarg.h, for now I have copied the version from tracee/3rdparty/include

## Building and running hello

```sh
make all
sudo ./hello
```

This builds two things:
* dist/hello.bpf.o - an object file for the eBPF program
* hello - a Go executable

The executable reads in the object file at runtime

