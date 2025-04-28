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
Let's assume that we get an IP address from DNS (you got it from the documentation,it's `192.168.1.14`). We now need to check two things if the web service on that IP is actually running and if it's accessible.

**A. Check connectivity to the web ports (80, 443):**

```bash
# Try connecting to port 80
telnet 192.168.1.14 80

# Try connecting to port 443 
telnet 192.168.1.14 443
```

* ![screenshot4](https://github.com/user-attachments/assets/86224a5a-d94d-41e9-be5d-52c5c44d1f62)

* **Success:** It was a success because the server is up and listening on that port and that IP

**B. Use `curl` to check if the web service responds:**

```bash
# Check HTTP
curl -v http://192.168.1.14

# Check HTTPS (add -k if using self-signed certs)
curl -v -k https://192.168.1.14
```

* ![screenshot5](https://github.com/user-attachments/assets/bbb8df08-4cc5-4435-a125-52f657478472)
* ![screenshot6](https://github.com/user-attachments/assets/0e7ab57a-0089-470c-a476-0e4ade6e7a46)


**C. Check if the service is listening (Run this ON THE SERVER `192.168.1.14`):**

```bash
sudo ss -tlpn | grep ':80\|:443'
```

* ![screenshot7](https://github.com/user-attachments/assets/aa30413c-7819-4cdd-b67d-18d55c545f2a)
* **Failure:** There's no output because no service inside the WSL Linux environment is listening on ports 80 or 443. The web server is running on the Windows side (not inside WSL), so ss -tlpn inside WSL shows nothing for ports 80/443

**Conclusion from this step:** These checks tell you if the web server itself is running and reachable or nott using the above commands once we know the IP for the server
