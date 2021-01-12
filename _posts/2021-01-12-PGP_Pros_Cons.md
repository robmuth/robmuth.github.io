---
title: My PGP Pros and Cons
category: Security/Privacy
---

# My PGP Pros and Cons

I first wanted to write an explanation why I won't extend my PGP keys anymore. Short story: it's so complicated that I always forget how it works. However, at the end, I've extended them and here is why PGP is damned but you should appreciate it.

While I've collected a list of alternatives[^Threema, Keybase, Signal, Telegram, Proton Mail, iMessage (meh)] to get in touch with me with E2E encryption, I noticed that all alternatives suffer centralization. While I certainly don't need high security for my communications, I still feel comfortable when I have choice. Spoiler: Nobody has ever sent me a PGP encrypted email that actually needed encryption.

The following pros and cons reflect my personal experiences.

## Pro PGP
1. As a security researcher I really enjoy the details and ideas of PGP's concepts.
2. PGP is the gold standard for encrypting emails.
3. Signed E-Mails can be useful (but also dangerous, as sometimes you don't want that somebody can proof that you've sent something ;-)
4. There is no centralized infrastructure (!) that can access your private keys.

In fact, the last released version of the [WhatsApp encryption white paper] has suspicious changes. In the past, they've promised that WhatsApp can't access private keys (see [Twitter]) but not anymore.

## Contra PGP
1. Nobody ever sent me a PGP encrypted email that actually needed encryption.
2. I have to install complex software (ie, OpenPGP/GPG). I can't use PGP right way with, let's say *bash script* or python w/o PGP libraries.
3. Key concepts are too complicated to remember. I always have to study manuals when I do something with PGP.
4. Key servers are not reliably reachable.
5. Strangers can just upload a key for my email address (so, keep web-of-trust in mind!)
6. There is some noticeable confusion between PGP and GPG.

## Conclusion
The contra list is longer ¯\_(ツ)_/¯ Nevertheless, I still believe in PGP. It has its place (eg, for lawyers or journalists) and must stay. At least so that people have a choice for strong encryption.

For the best, I'll extend my [PGP keys]. But I don't have a proper PGP client installed, so don't expect an answer in time.

[Twitter]: https://twitter.com/Shiftreduce/status/1347546599384346624
[WhatsApp encryption white paper]: https://scontent.whatsapp.net/v/t39.8562-34/122249142_469857720642275_2152527586907531259_n.pdf/WA_Security_WhitePaper.pdf?ccb=2&_nc_sid=2fbf2a&_nc_ohc=hFDNXSaJaccAX_URnP1&_nc_ht=scontent.whatsapp.net&oh=2a6b4105d660d6e60d496850cdad9c9f&oe=6022F599
[PGP keys]: http://keyserver.ubuntu.com/pks/lookup?search=robertmuth&fingerprint=on&op=index

[//]: # ( #Blog )
