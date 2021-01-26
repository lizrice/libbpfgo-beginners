# libbpfgo-beginners
Basic eBPF examples in Golang using libbpfgo, based on the [original Python examples](https://github.com/lizrice/ebpf-beginners) from my [Beginner's Guide to eBPF talk](https://speakerdeck.com/lizrice/liz-rice-beginners-guide-to-ebpf)  

WORK IN PROGRESS! 

eBPF hello world examples using libbpfgo

## Install Go 

See [the Go documentation](https://golang.org/doc/install)

## Install packages

```sh
sudo apt-get update
sudo apt-get install libbpf-dev make clang llvm libelf-dev
```

## Building and running hello

```sh
make all
sudo ./hello
```

This builds two things:
* dist/hello.bpf.o - an object file for the eBPF program
* hello - a Go executable

The executable reads in the object file at runtime.

## Notes 

I'm using Ubuntu 20.10, kernel 5.8, go 1.15

This approach installs the libbpf-dev package. Another alternative (which is what [Tracee](https://github.com/aquasecurity/tracee) does) is to install the libbpf source as a git submodule, and build it from source. 
