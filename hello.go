package main

import (
	"C"
	"fmt"

	bpf "github.com/aquasecurity/tracee/libbpfgo"
)
import (
	"bufio"
	"os"
	"os/signal"
)

func main() {
	doEbpf()
}

func doEbpf() error {
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt)

	bpfModule, err := bpf.NewModuleFromFile("hello.bpf.o")
	must(err)
	defer bpfModule.Close()

	bpfModule.BPFLoadObject()

	prog, err := bpfModule.GetProgram("hello")
	must(err)

	_, err = prog.AttachKprobe("__x64_sys_execve")
	must(err)

	go tracePrint()

	// Wait until interrupted
	<-sig
	fmt.Println("Cleaning up")

	return err
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}

// TODO: something like this could live in libbpfgo
func tracePrint() {
	f, err := os.Open("/sys/kernel/debug/tracing/trace_pipe")
	must(err)
	r := bufio.NewReader(f)
	b := make([]byte, 1000)
	for {
		len, err := r.Read(b)
		must(err)
		s := string(b[:len])
		fmt.Println(s)
	}
}
