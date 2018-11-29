action call_action(value, egr_spec) {
    add_header(ethernet);
    
    set_field(ethernet.dst_addr, value);
    set_field(metadata.egress_spec, egr_spec);
}