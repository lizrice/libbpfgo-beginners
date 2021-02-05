package main

import (
	"C"

	bpf "github.com/aquasecurity/tracee/libbpfgo"
)
import (
	"fmt"
	"os"
	"os/signal"
)

func main() {
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt)

	bpfModule, err := bpf.NewModuleFromFile("hello.bpf.o")
	must(err)
	defer bpfModule.Close()

	err = bpfModule.BPFLoadObject()
	must(err)

	prog, err := bpfModule.GetProgram("hello")
	must(err)
	_, err = prog.AttachKprobe("__x64_sys_execve")
	must(err)

	go bpf.TracePrint()

	prog, err = bpfModule.GetProgram("hello_bpftrace")
	must(err)
	_, err = prog.AttachRawTracepoint("sys_enter")
	must(err)

	eventsChannel := make(chan []byte, 1024)
	p, err := bpfModule.InitPerfBuf("events", eventsChannel, nil, 1024)
	must(err)

	p.Start()

	counter := make(map[string]int, 350)

	go func() {
		for {
			select {
			case event := <-eventsChannel:
				// val := binary.LittleEndian.Uint64(event)
				// fmt.Printf("Event %s\n", string(event))
				comm := string(event)
				if _, ok := counter[comm]; ok {
					counter[comm]++
				} else {
					counter[comm] = 1
				}
			}
		}
	}()

	<-sig
	p.Stop()
	fmt.Printf("%v\n", counter)
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
