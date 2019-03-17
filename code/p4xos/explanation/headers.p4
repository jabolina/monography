header_type paxos_t {
    fields {
        msgtype : 8;
        instance : 16;
        round : 8;
        vround : 8;
        acceptor: 64;
        value : 512;
    }
}