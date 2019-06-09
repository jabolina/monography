#include "includes/paxos_headers.p4"
#include "includes/paxos_parser.p4"
#include "l2_control.p4"

register instance_register {
    width : INSTANCE_SIZE;
    instance_count : 1;
}

action handle_request() {
    modify_field(paxos.msgtype, PAXOS_2A);
    modify_field(paxos.round, 0);
    register_read(paxos.instance, instance_register, 0);
    add_to_field(paxos.instance, 1);
    register_write(instance_register, 0, paxos.instance);
}

table tbl_sequence {
    reads   { paxos.msgtype : exact; }
    actions { handle_request; _nop; }
    size : 1;
}

control ingress {
    apply(smac);
    apply(dmac);

    if (valid(paxos)) {
        apply(tbl_sequence);
    }
}