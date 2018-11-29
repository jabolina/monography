parser start {
    ethernet;
}

parse ethernet {
    switch (ethertype) {
        case 0x8100: vlan;
        case 0x9100: vlan;
        case 0x800: ipv4;
    }
}
