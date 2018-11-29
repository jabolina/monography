table table_definition {
    reads {
        ethernet.dest_addr: exact;
    }
    action {
        call_action;
    }
    max_size: 2000;
}