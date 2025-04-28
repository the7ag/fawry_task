### 1. Verify DNS Resolution

Getting a "host not found" error suggests a DNS problem. We have to check if the hostname `internal.example.com` can be translated into an IP address, checking if our internal DNS servers (from `/etc/resolv.conf`) and a known public one (like Google's `8.8.8.8`) have the same resolve.

**A. Check which DNS servers your system is using:**

```bash
cat /etc/resolv.conf
```

* ![screenshot1](https://github.com/user-attachments/assets/0fc02307-1d5a-47f8-a026-d049087e9051)

* This file tells us which DNS server(s) your system will ask first.mine is 10.255.255.254

**B. Query your default (internal) DNS server:**

```bash
nslookup internal.example.com
```

* ![screenshot2](https://github.com/user-attachments/assets/e31f4133-7d6e-4d54-aaae-e4f8100fe215)

* **It failed:** We got `NXDOMAIN` (Non-Existent Domain). This confirms the internal DNS server doesn't know `internal.example.com`. This matches the "host not found" error.

**C. Query Google's DNS server:**

```bash
nslookup internal.example.com 8.8.8.8
```

* ![screenshot3](https://github.com/user-attachments/assets/1e922b48-ef64-4116-b3c1-e7583d257a75)

* **It also failed:** Because it's an internal-only domain, this query failed (`NXDOMAIN`). Public DNS servers won't know about your private `internal.example.com`.
* **Interpretation:**
    * **Internal DNS Failed** and **Public DNS Failed**: This is expected for an internal domain. The problem lies with your internal DNS server (unreachable, down, or missing the record).


**Conclusion from this step:** Most likely, the internal DNS server listed in `/etc/resolv.conf` is either unreachable or doesn't have the correct record for `internal.example.com`.


### 2. Verify DNS Resolution
172.17.96.1
Let's assume that we get an IP address from DNS (you got it from the documentation,it's `192.168.1.14`). We now need to check two things if the web service on that IP is actually running and if it's accessible.

**A. Check connectivity to the web ports (80 , 443):**

```bash
# Try connecting to port 80
telnet 192.168.1.14 80

# Try connecting to port 443 
telnet 192.168.1.14 443
```

* [[Screenshot 4]]
* **Success:** It got a success because the server is up and listnning on that port and that ip

**B. Use `curl` to check if the web service responds:**

```bash
# Check HTTP
curl -v http://192.168.1.14

# Check HTTPS (add -k if using self-signed certs)
curl -v -k https://192.168.1.14
```

* [[Screenshot 5]]
* [[Screenshot 6]]

**C. Check if the service is listening (Run this ON THE SERVER `192.168.1.14`):**

```bash
sudo ss -tlpn | grep ':80\|:443'
```

* [[Screenshot 7]]
* **Failure:** There's no output because the server isn't hosted on the WSL machine it's running on my local windows machine so that's why there's no output

**Conclusion from this step:** These checks tell you if the web server itself is running and reachable or not using the above commands once we know the IP for the server
