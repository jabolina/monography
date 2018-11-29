control main() {
    if (defined(ethernet.dst_addr)) {
        table(table_definition);
    }
}