SoftEther VPN
=============
All-in-one VPN solution featuring various protocols. You need a compatible administration tool to manage the server.

Services
--------
Includes the following services:
- SoftEther VPN Server

What's not included:
- SoftEther web administration (not production ready)

For more info, read up on [SoftEther specs](https://www.softether.org/3-spec#SoftEther_VPN_Protocol_Specification).

Important Caveats
-----------------
1. Do not enable IPSec on SoftEther. Rancher 1.6 uses IPSec internally for clustering, and SoftEther can mess things up if it 
competes for port 500/4500. This means no L2TPv3, L2TP/IPSec, and EtherIP.

2. OpenVPN uses UDP (in addition to TCP). HAProxy cannot handle UDP, so this stack will directly map 1194/UDP to the SoftEther 
server container. Make sure 1194/UDP is not already occupied on the worker host or deployment will fail.

3. If you cannot dedicate port 1194/UDP to the SoftEther server, an alternative is to modify `OpenVPN UDP Port` for some other 
unoccupied port on the worker host (recommended range: 10,000-60,000). The caveat is that your clients who use OpenVPN need to 
modify their profiles to this port number instead of the default 1194.

Usage
-----
1. Update your load balancer to point the following ports to the SoftEther service:-
- SNI 443 SoftEther, MS-SSTP
- SNI 992: SoftEther, MS-SSTP
- SNI 5555: SoftEther, MS-SSTP
- TCP 1194: OpenVPN

**Why SNI?** HTTPS or TLS terminates the SSL and pass unencrypted traffic to the target, which SoftEther does not support.

**Why TCP for OpenVPN?** OpenVPN in TCP mode does't work with SNI. For OpenVPN, you can rely on UDP alone, or dedicate a TCP port to the VPN server.

2. If you have an external firewall before the host, make sure you adjust the rules on your firewall to allow access to the ports listed in step 1.

3. Download a compatible [management client](https://www.softether-download.com/files/softether/v4.29-9680-rtm-2019.02.28-tree/Windows/Admin_Tools/VPN_Server_Manager_and_Command-line_Utility_Package/softether-vpn_admin_tools-v4.29-9680-rtm-2019.02.28-win32.zip) to perform administration tasks. 
