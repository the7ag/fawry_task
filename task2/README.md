### 1. Verify DNS Resolution

Getting "host not found" error suggests a DNS problem. We have to check if the hostname `internal.example.com` can be translated into an IP address, checking if our internal DNS servers (from `/etc/resolv.conf`) and a known public one (like Google's `8.8.8.8`) has the same resolve.

**A. Check which DNS servers your system is using:**

```bash
cat /etc/resolv.conf
```

* [[Screenshot1]]
* This file tells us which DNS server(s) your system will ask first.mine is 10.255.255.254

**B. Query your default (internal) DNS server:**

```bash
nslookup internal.example.com
```

* [[Screenshot2]]
* **It failed:** And we got `NXDOMAIN` (Non-Existent Domain). This confirms the internal DNS server doesn't know `internal.example.com` This matches the "host not found" error.

**C. Query a Google's DNS server :**

```bash
nslookup internal.example.com 8.8.8.8
```

* [[Screenshot 3]].
* **It also failed:** Because it's and *internal-only* domain, this query failed (`NXDOMAIN`). Public DNS servers won't know about your private `internal.example.com`.
* **Interpretation:**
    * **Internal DNS Failed** and **Public DNS Failed**: This is expected for an internal domain. The problem lies with your internal DNS server (unreachable, down, or missing the record).


**Conclusion from this step:** Most likely, the internal DNS server listed in `/etc/resolv.conf` is either unreachable or doesn't have the correct record for `internal.example.com`.
