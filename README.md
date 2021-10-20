# libbpfgo-beginners
Basic eBPF examples in Golang using [libbpfgo](https://github.com/aquasecurity/tracee/tree/main/libbpfgo). 
* Accompanying [slides from my talk at GOTOpia 2021](https://speakerdeck.com/lizrice/beginners-guide-to-ebpf-programming-with-go) called Beginner's Guide to eBPF Programming in Go
* See also my [original Python examples](https://github.com/lizrice/ebpf-beginners) from my [Beginner's Guide to eBPF talk](https://speakerdeck.com/lizrice/liz-rice-beginners-guide-to-ebpf)  

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

The Go executable reads in the object file at runtime. Take a look at the .o file with readelf if you want to see the sections defined in it.

## Docker

To avoid compatibility issues, you can use the `Dockerfile` provided in this repository.

Build it by your own:

```bash
docker build -t hello .
```

And the run it from the project directory to compile the program:

```bash
docker run --rm -v $(pwd)/:/app/:z hello
```

## Notes 

I'm using Ubuntu 20.10, kernel 5.8, go 1.15

This approach installs the libbpf-dev package. Another alternative (which is what [Tracee](https://github.com/aquasecurity/tracee) does) is to install the [libbpf source](https://github.com/libbpf/libbpf) as a git submodule, build it from source and install it to the expected location (e.g. `/usr/lib/x86_64-linux-gnu/libbpf.a` on an Intel x86 processor).
