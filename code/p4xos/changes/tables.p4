action clean_register() {
    register_write(rounds_register, paxos_packet_metadata.invalid_instance, 0);
    register_write(vrounds_register, paxos_packet_metadata.invalid_instance, 0);
    register_write(values_register, paxos_packet_metadata.invalid_instance, 0);
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

table tbl_clean_register {
    actions { clean_register; }
}

table tbl_inst {
    actions { read_instance; }
}

table tbl_slide_window {
    actions { slide_window; }
}
