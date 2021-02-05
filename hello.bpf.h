/* In Linux 5.4 asm_inline was introduced, but it's not supported by clang.
 * Redefine it to just asm to enable successful compilation.
 * see https://github.com/iovisor/bcc/commit/2d1497cde1cc9835f759a707b42dea83bee378b8 for more details
 */
#include <linux/types.h>
#ifdef asm_inline
#undef asm_inline
#define asm_inline asm
#endif

#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

typedef __u64 u64;

/* TODO!! This is too generic for this example, where can we pull it from? 
*/
#define BPF_MAP(_name, _type, _key_type, _value_type, _max_entries) \
    struct bpf_map_def SEC("maps") _name = {                        \
        .type = _type,                                              \
        .key_size = sizeof(_key_type),                              \
        .value_size = sizeof(_value_type),                          \
        .max_entries = _max_entries,                                \
    };

#define BPF_HASH(_name, _key_type, _value_type) \
    BPF_MAP(_name, BPF_MAP_TYPE_HASH, _key_type, _value_type, 10240);

#define BPF_PERF_OUTPUT(_name) \
    BPF_MAP(_name, BPF_MAP_TYPE_PERF_EVENT_ARRAY, int, __u32, 1024);

char LICENSE[] SEC("license") = "Dual BSD/GPL";
