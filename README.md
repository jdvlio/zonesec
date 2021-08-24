
[bind9_zonefile]: https://bind9.readthedocs.io/en/latest/reference.html#zone-file

# Summary

Contained here is a simple tool in the form of a mundane makefile.  It is
nothing more than an ordinary wrapper for some of the utilities packaged with
`ldns` and `nsd` which, ofcourse, both need to be installed.

After cloning the repository, note that an example zone file is provided and
contains the basics any small domain will need.

# What is DNSSEC?

When DNS was first envisioned by its creators, they did not have in mind the
hostile environment that is the modern internet.  A determined attacker would
not find it hard to hijack traffic to your DNS server, redirecting it to some
other DNS server he controls.

As you might imagine this scenario can be rather catastrophic, to put it
lightly.  For this scenario, among others, DNSSEC was invented.  Thinking of the
domains from the IANA root domain down to one of your (sub)domains as a chain,
DNSSEC makes it possible for an arbitrary resolver or recursive name server to
validate each link in this chain.

Each link in the aforementioned chain has two keys (we'll ignore that
technically you could use only 1 key for this, as two is in my opinion more
convenient): a Zone Signing Key (ZSK) and a Key Signing Key (KSK).  Each parent
zone (e.g. `.com`) provides a DS record for all of its delegated subdomains e.g.
`example.com`, which they sign using their ZSK.

The keys for a domain are kept in DNSKEY records and are signed using that
domain's KSK.  In this manner, DNS responses can be validated by essentially
veryfying that all the necessary signatures are present on the way up from the
domain being queried all the way to the root domain.

# What is DNSSEC not?

A mechanism for encrypting or anonymizing DNS traffic.  This role belongs to
DNS over TLS, DNS over HTTPS and Anonymous DNS over HTTPS.  DNSSEC is merely a
means of verifying that a DNS response is valid/legitimate in the sense that it
comes from the intended domain.

# Basic usage instructions

1. Simply clone the repository to a location where you wish to keep your zone
   file and its keys.  Make sure you have both `nsd` and `ldns` installed before
   proceeding.  It is recommended to name the directory after your domain.
2. Change the value of the `DOMAIN` variable in the Makefile to the name of your
   domain (without a trailing period).
3. Rename the example zone file so that it is of the form `example.com.zone` if
   your domain is `example.com`.  Edit this file to suit your needs.

   I would recommend ultimately using `nsd` as your DNS server (on whatever
   machine you wish) but the `BIND9` documentation, nonetheless, has [useful
   information on zone files][bind9_zonefile].  Note that for this step **you**
   **may safely ignore the existence of DNSSEC** as the DNSSEC-related records
   are added automatically in the next step.  These need not (should not) be
   added manually at this stage.
4. In the same directory run the command:
   ```
    $ make signzone
   ```
   to create a signed zone file for `nsd` to serve.

6. Run the command
   ```
    $ make ds
   ```
   in order to retrieve the info needed to pass on to your registrar or parent
   zone.

   Your so-called "key id" is the first entry after the `DS` keyword.  It is
   followed by the DNSKEY algorithm (default: 14), digest algorithm (default: 4)
   and then the actual digest for your key.

# Advanced usage

Running the command:

	$ make list

produces a list of all the supported algorithms, excluding a few ancient ones
that I have filtered out (alongside *hmac* keys which are used for TSIG).

Should you prefer different algorithms than the ones I have set your are free to
set them by changing the variables defined at the start of the Makefile or by
passing them as environment variables to make on the command line.

Feel free to investigate the Makefile for a bit more insight into the inner
workings!  It's really simple stuff honestly.


# There's more?

One of the consequences of the DNSSEC infrastructure's existence is that any
other (public) information on the internet that needs validation can simply be
shoe horned into the DNS infrastructure.

It is an ugly solution but it can remove the need for even uglier solutions to
exist, such as Certificate Authorities (CAs) which can be replaced by the `CERT`
DNS record and OpenPGP "key servers" which can be replaced by `OPENPGPKEY`
records.  Though standardized by the IETF as RFCs, to my knowledge this is not
common practice yet, sadly.

Unfortunately, it has also made things like the annoying DMARC protocol possible
but no internet standard is perfect.
