# SSH into a server with IPv6 address: 5ba3:9c4:8a3e:6e5b::/64
ssh root@5ba3:9c4:8a3e:6e5b::1
# If that doesn't work try ssh root@5ba3:9c4:8a3e:6e5b::2 and so on.

# Check what kind of network interfaces you have on your machine.
# an internet cable (eth0) or wifi connection:
# Linux:
ip add
# macOS:
ifconfig

# Next check if you have a default internet access.
ip route
# If not try restarting first.

# See if you can ping 8.8.8.8
ping 8.8.8.8 

# See if you can ping google.com
ping google.com

# See if you can ping github.com (if not, you might only have ipv6).
