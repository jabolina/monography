action handle_request() {
    modify_field(paxos.msgtype, PAXOS_2A);
    modify_field(paxos.round, 0);	
    register_read(paxos.instance, instance_register, 0);
    add_to_field(paxos.instance, 1);
    register_write(instance_register, 0, paxos.instance);
}