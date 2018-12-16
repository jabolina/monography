from mininet.net import Containernet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.link import TCLink

net = Containernet(controller=Controller)
net.addController('c0')

d1 = net.addDocker('d1', ip='10.0.0.251', dimage="ubuntu:trusty")
d2 = net.addDocker('d2', ip='10.0.0.252', dimage="ubuntu:trusty")

s1 = net.addSwitch('s1')
s2 = net.addSwitch('s2')

net.addLink(d1, s1)
net.addLink(s1, s2, cls=TCLink, delay='100ms', bw=1)
net.addLink(s2, d2)

net.start()

net.ping([d1, d2])

net.stop()