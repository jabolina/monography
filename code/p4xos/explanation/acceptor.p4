action handle_1a() {
    modify_field(paxos.msgtype, PAXOS_1B);
    register_read(paxos.vround, vrounds_register, paxos.instance);
    register_read(paxos.value, values_register, paxos.instance);
    register_read(paxos.acceptor, datapath_id, 0);
    register_write(rounds_register, paxos.instance, paxos.round);
}

action handle_2a() {
    modify_field(paxos.msgtype, PAXOS_2B);
    register_write(rounds_register, paxos.instance, paxos.round);
    register_write(vrounds_register, paxos.instance, paxos.round);
    register_write(values_register, paxos.instance, paxos.value);
    register_read(paxos.acceptor, datapath_id, 0);
}