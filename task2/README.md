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


---


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


---


### 3. Trace the Issue and List All Possible Causes

Based on the "host not found" error and potential follow-up findings:

**DNS Layer:**

1.  **Incorrect/Missing DNS Record:** The A record for `internal.example.com` doesn't exist or points to the wrong IP on the internal DNS server.
2.  **Internal DNS Server Unreachable:** The DNS server(s) listed in the client's `/etc/resolv.conf` are down or not reachable over the network.
3.  **Client `/etc/resolv.conf` Misconfiguration:** The client machine is pointing to the wrong DNS servers entirely.
4.  **Client DNS Caching Issue:** The client has a stale or incorrect DNS entry cached locally. This is more likely if multiple clients share the same cache.

**Network/Service Layer:**

5.  **Server-Side Firewall:** The firewall on the server (`192.168.1.14`) is blocking incoming connections on port 80/443.
6.  **Intermediate Network Firewall:** A firewall device between the client and server is blocking port 80/443.
7.  **Web Server Process Not Running:** The actual web server software (Nginx, Apache) on `192.168.1.14` has crashed or is stopped.
8.  **Web Server Misconfiguration:** The web server is running but not listening on the correct IP address or port, or the virtual host for `internal.example.com` is not set up correctly.
9.  **Client-Side Firewall:** The firewall on the client machine is blocking outbound connections to port 80/443 but this is less common for web Browse.
10. **Basic Network Connectivity:** A more fundamental network issue exists like incorrect IP/subnet on client/server, routing problems, switch issues.



---


### 4. Propose and Apply Fixes

Here's how to confirm and fix each potential cause:

**(Cause 1 & 2 are the most likely starting points based on the "host not found" error)**

1.  **Incorrect/Missing DNS Record:**
    * **Confirm:** Log into the internal DNS server. Check its configuration/zone file for `internal.example.com`. Verify the IP address listed is correct.
    * **Fix:** Edit the DNS server's configuration to add or correct the A record for `internal.example.com`.
2.  **Internal DNS Server Unreachable:**
    * **Confirm:** From an affected client, try pinging the DNS server IP found in `/etc/resolv.conf`.
        ```bash
        ping <DNS_Server_IP>
        ```
        Use `traceroute <DNS_Server_IP>` to see where the connection fails.
    * **Fix:** Requires diagnosing the DNS server itself (is it powered on? is the DNS service running?) or the network path to it (check switches, firewalls between client and DNS server). No single fix command; involves general network/server troubleshooting.

3.  **Client `/etc/resolv.conf` Misconfiguration:**
    * **Confirm:** `cat /etc/resolv.conf`. Compare the `nameserver` IPs listed with the known correct internal DNS server IPs.
    * **Fix (Temporary):** Manually edit the file (requires `sudo`).
        ```bash
        sudo nano /etc/resolv.conf
        # Correct the 'nameserver' lines
        ```

4.  **Client DNS Caching Issue:**
    * **Confirm:** Difficult to confirm directly, often tried after other checks fail.
    * **Fix:** Flush the local DNS cache. The command varies:
        ```bash
        sudo systemd-resolve --flush-caches
        ```

5.  **Server-Side Firewall:**
    * **Confirm:** On the web server (`192.168.1.14`), check firewall rules.
        ```bash
        sudo ufw status verbose
        ```
        Look for rules that ACCEPT traffic to dpt:80 and dpt:443.
    * **Fix:** Add rules to allow traffic.
        ```bash
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        ```

6.  **Intermediate Network Firewall:**
    * **Confirm:** Use `traceroute internal.example.com` (or `traceroute 192.168.1.14` if DNS is fixed/bypassed). Identify network hops. Requires checking firewall logs/rules on devices along that path (often needs network team involvement).
    * **Fix:** Modify rules on the intermediate firewall device(s).

7.  **Web Server Process Not Running:**
    * **Confirm:** On the web server (`192.168.1.14`), check the service status.
        ```bash
        sudo systemctl status nginx
        sudo ss -tlpn | grep ':80\|:443'
        ```
    * **Fix:** Start/restart the service. Check logs for errors if it fails to start.
        ```bash
        sudo systemctl start nginx
        sudo systemctl enable nginx
        journalctl -u nginx
        ```

8.  **Web Server Misconfiguration:**
    * **Confirm:** On the web server, check the web server configuration files (e.g., `/etc/nginx/sites-available/`). Ensure `listen` directives are correct and the `server_name` matches `internal.example.com`. Test the configuration:
        ```bash
        sudo nginx -t
        ```
    * **Fix:** Edit the configuration files to correct `listen` address/port or `server_name` directives. Reload the service:
        ```bash
        sudo systemctl reload nginx 
        ```

9.  **Client-Side Firewall:**
    * **Confirm:** On the client machine, check outbound rules.
        ```bash
        sudo iptables -L OUTPUT -v -n
        sudo ufw status verbose
        ```
    * **Fix:** Adjust client firewall rules if needed.

10. **Basic Network Connectivity:**
    * **Confirm:** Use `ping <Server_IP>`, `ip addr show` (check client IP/subnet), `ip route show` (check default gateway). Do similar checks on the server.
    * **Fix:** Correct IP configuration (`sudo nano /etc/network/interfaces` or NetworkManager tools), fix routing (`sudo ip route add/del`), ensure interfaces are up (`sudo ip link set eth0 up`).