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
