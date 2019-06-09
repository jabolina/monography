#include "includes/paxos_headers.p4"
#include "includes/paxos_parser.p4"
#include "l2_control.p4"

#define INSTANCE_COUNT 65536

field_list resubmit_field_list {
    paxos_packet_metadata.invalid_instance;
    paxos_packet_metadata.valid_instance;
    paxos_packet_metadata.new_instance;
    paxos.instance; 
}

header_type ingress_metadata_t {
    fields {
        round : ROUND_SIZE;
        invalid_instance: INSTANCE_SIZE;
        valid_instance: INSTANCE_SIZE;
        new_instance: INSTANCE_SIZE;
    }
}
metadata ingress_metadata_t paxos_packet_metadata;

register datapath_id {
    width: DATAPATH_SIZE;
    instance_count : 1;
}

register rounds_register {
    width : ROUND_SIZE;
    instance_count : INSTANCE_COUNT;
}

register vrounds_register {
    width : ROUND_SIZE;
    instance_count : INSTANCE_COUNT;
}

register values_register {
    width : VALUE_SIZE;
    instance_count : INSTANCE_COUNT;
}

register invalid_instance_register {
    width: INSTANCE_SIZE;
    instance_count: 1;
}

register valid_instance_register {
    width: INSTANCE_SIZE;
    instance_count: 1;
}

register future_instance_register {
    width: INSTANCE_SIZE;
    instance_count: 1;
}

action clean_register() {
    register_write(rounds_register, paxos_packet_metadata.invalid_instance, 0);
    register_write(vrounds_register, paxos_packet_metadata.invalid_instance, 0);
    register_write(values_register, paxos_packet_metadata.invalid_instance, 0);
}

action read_round() {
    register_read(paxos_packet_metadata.round, rounds_register, paxos.instance);
    modify_field(intrinsic_metadata_paxos.set_drop, 1);
}

action read_instance() {
    register_read(paxos_packet_metadata.invalid_instance, invalid_instance_register, 0);
    register_read(paxos_packet_metadata.valid_instance, valid_instance_register, 0);
    register_read(paxos_packet_metadata.new_instance, future_instance_register, 0);
}

action slide_window() {
    add_to_field(paxos_packet_metadata.invalid_instance, 1);
    add_to_field(paxos_packet_metadata.valid_instance, 1);
    add_to_field(paxos_packet_metadata.new_instance, 1);

    register_write(invalid_instance_register, 0, paxos_packet_metadata.invalid_instance);
    register_write(valid_instance_register, 0, paxos_packet_metadata.valid_instance);
    register_write(future_instance_register, 0, paxos_packet_metadata.new_instance);

    resubmit(resubmit_field_list);
}

action handle_1a() {
    modify_field(intrinsic_metadata_paxos.set_drop, 0);
    modify_field(paxos.msgtype, PAXOS_1B);
    register_read(paxos.vround, vrounds_register, paxos.instance);
    register_read(paxos.value, values_register, paxos.instance);
    register_read(paxos.acceptor, datapath_id, 0);
    register_write(rounds_register, paxos.instance, paxos.round);
}

action handle_2a() {
    modify_field(intrinsic_metadata_paxos.set_drop, 0);
    modify_field(paxos.msgtype, PAXOS_2B);
    register_write(rounds_register, paxos.instance, paxos.round);
    register_write(vrounds_register, paxos.instance, paxos.round);
    register_write(values_register, paxos.instance, paxos.value);
    register_read(paxos.acceptor, datapath_id, 0);
}

table tbl_rnd {
    actions { read_round; }
}

table tbl_inst {
    actions { read_instance; }
}

table tbl_slide_window {
    actions { slide_window; }
}

table tbl_clean_register {
    actions { clean_register; }
}

table tbl_acceptor {
    reads   { paxos.msgtype : exact; }
    actions { handle_1a; handle_2a; _drop; }
}

control ingress {
    apply(smac);
    apply(dmac);
    
    if (valid(paxos)) {
        apply(tbl_inst);
        apply(tbl_rnd);

        if (paxos_packet_metadata.round <= paxos.round) {
            if (
                (paxos_packet_metadata.invalid_instance < paxos_packet_metadata.valid_instance and
                    paxos_packet_metadata.valid_instance < paxos_packet_metadata.new_instance)
                or
                (paxos_packet_metadata.new_instance < paxos_packet_metadata.invalid_instance and
                    paxos_packet_metadata.invalid_instance < paxos_packet_metadata.valid_instance)
                or
                (paxos_packet_metadata.valid_instance < paxos_packet_metadata.new_instance and
                    paxos_packet_metadata.new_instance < paxos_packet_metadata.invalid_instance)
            ) {
                if (
                    (paxos_packet_metadata.invalid_instance < paxos.instance and
                        paxos_packet_metadata.valid_instance <= paxos.instance and
                        paxos.instance < paxos_packet_metadata.new_instance)
                    or
                    ((paxos_packet_metadata.valid_instance <= paxos.instance and
                        paxos_packet_metadata.new_instance < paxos_packet_metadata.valid_instance) or
                        (paxos.instance < paxos_packet_metadata.new_instance and
                        paxos_packet_metadata.new_instance < paxos_packet_metadata.valid_instance))
                    or
                    (paxos_packet_metadata.valid_instance <= paxos.instance and
                        paxos.instance < paxos_packet_metadata.new_instance)
                ) {
                    apply(tbl_acceptor);
                } else if (
                    (paxos_packet_metadata.new_instance <= paxos.instance and
                        paxos_packet_metadata.invalid_instance < paxos.instance)
                    or
                    (paxos_packet_metadata.new_instance <= paxos.instance and
                        paxos.instance < paxos_packet_metadata.invalid_instance)
                ) {
                    apply(tbl_clean_register);
                    apply(tbl_slide_window);
                }
            }
        }
    }
}