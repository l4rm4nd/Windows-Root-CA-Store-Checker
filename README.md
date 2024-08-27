# Windows-Root-CA-Store-Checker
PowerShell Script to Validate Windows Root CA Trust Store

## Description

1. Loads the trusted CA stores as CSV into memory from [Mozilla](https://wiki.mozilla.org/CA/Included_Certificates) and [Microsoft](https://learn.microsoft.com/en-us/security/trusted-root/participants-list).
2. Extracts the local root CA store from computer and calculates SHA256 fingerprints
3. Compares the local CA SHA256 fingerprints against Mozilla's and Microsoft's SHA256 fingerprints from CSV files
4. Displays the Certificate Authorities (CAs) that do not match. Also dumps them into an CSV outfile.

## How to use

Open a low-priv PowerShell (PS) and execute the script:

````
.\RootCACheck.ps1
````
![image](https://github.com/user-attachments/assets/06f686f5-97f4-462e-b1bd-154a471614dc)
