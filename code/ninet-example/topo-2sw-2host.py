from mininet.topo import Topo


class CustomTopo(Topo):
    def __init__(self):
        Topo.__init__(self)
        
        left_host = self.addHost("h1")
        right_host = self.addHost("h2")

        left_switch = self.addSwitch("s3")
        right_switch = self.addSwitch("s4")

        self.addLink(left_host, left_switch)
        self.addLink(left_switch, right_switch)
        self.addLink(right_switch, right_host)

topos = {"custom_topo": (lambda: CustomTopo())}