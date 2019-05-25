// When the window slides, the register must be cleaned in for the
// inactive instance
action clean_register() {
    register_write(rounds_register, paxos_packet_metadata.invalid_instance, 0);
    register_write(vrounds_register, paxos_packet_metadata.invalid_instance, 0);
    register_write(values_register, paxos_packet_metadata.invalid_instance, 0);
}

// This will read the window intervals into the packet metadata
action read_instance() {
    register_read(paxos_packet_metadata.invalid_instance, invalid_instance_register, 0);
    register_read(paxos_packet_metadata.valid_instance, valid_instance_register, 0);
    register_read(paxos_packet_metadata.new_instance, future_instance_register, 0);
}

// This will slide the window in 1 and resubmit the package
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
