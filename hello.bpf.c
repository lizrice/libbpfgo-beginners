// +build ignore
#include "hello.bpf.h"

// Example: tracing a message on a kprobe
SEC("kprobe/sys_execve")
int hello(void *ctx)
{
    bpf_printk("I'm alive!");
    return 0;
}

// Example of passing data using a perf map
// Similar to bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count();}'
BPF_PERF_OUTPUT(events)
SEC("raw_tracepoint/sys_enter")
int hello_bpftrace(void *ctx)
{
    char data[100];
    bpf_get_current_comm(&data, 100);
    bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &data, 100);
    return 0;
}