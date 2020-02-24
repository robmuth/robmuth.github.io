---
title: Manually Generating Signed Xcode Certificates for App Store Distribution
category: iOS
tags: [Xcode, iOS]
---

Manually Generating Signed Xcode Certificates for App Store Distribution
==========

This guide shows you how to generate app store distribution certificates for Xcode manually, so you can share them with your team members and developers. 
Commercial Apple developer accounts can issue these certificates automatically, but personal accounts have to generate and sign them manually.

> Disclaimer: I don't know if Apple allows you to share your personal certificates. Make sure you follow Apple's terms and conditions when sharing personal certificates. I highly recommend to keep your certificates safe and to not share them publicly in the Internet.

1. Add a new certificate on https://developer.apple.com/account/ios/certificate/create for "iOS App Development"
    1. Create a new ```Certificate from a Certificate Authority``` with *Keychain Access* and fill out the forms like described on the Webpage (https://help.apple.com/developer-account/#/devbfa00fef7)
    2. Download the certificate
    3. Import the certificate to your keychain (double-click it)
    4. Open *Keychain Access* and select the "Keys" category
    5. Find the imported key, expand the item (click on ▶) and select both rows (Certificate and Key!), right-click the rows and export 2 items as .p12-file
    6. Make a new provisioning profile for Development and download it
    7. Import all 3 files at the other party by double-clicking them: .p12, .cer, .mobileprovision

2. Do the same for "App Store and Ad Hoc" **but with a new private key!** Do not reuse the first private key.

[//]: # ( #Xcode #iOS )
