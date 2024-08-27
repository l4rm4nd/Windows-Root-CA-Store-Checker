# Windows-Root-CA-Store-Checker
PowerShell Script to Validate Windows Root CA Trust Store

## Description

1. Downloads the trusted CA stores as CSV from Mozilla.
2. Extracts the local root CA store and calculates SHA256 fingerprints
3. Compares the local CA SHA256 fingerprints against Mozilla's SHA256 fingerprints from CSV file
4. Displays the Certificate Authorities (CAs) that do not match. Also dumps them into an CSV outfile.

> [!WARNING]
> Mozilla's CSV does only contain web-related root CAs.
>
> Therefore, the script will detect Windows-related CAs, which are not known or necessary from the viewpoint of Mozilla.

## How to use

Open a low-priv PowerShell (PS) and execute the script:

````
.\audit.ps1
````
