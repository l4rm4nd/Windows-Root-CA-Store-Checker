# Define URLs for the Mozilla and Microsoft Included CA Certificate Reports
$mozillaCsvUrl = "https://ccadb.my.salesforce-sites.com/mozilla/IncludedCACertificateReportCSVFormat"
$microsoftCsvUrl = "https://ccadb-public.secure.force.com/microsoft/IncludedCACertificateReportForMSFTCSV"

# Download the Mozilla CSV and load into memory
$mozillaCsvContent = Invoke-WebRequest -Uri $mozillaCsvUrl
$mozillaCerts = $mozillaCsvContent.Content | ConvertFrom-Csv
Write-Host "[i] Mozilla CSV data loaded into memory"

# Download the Microsoft CSV and load into memory
$microsoftCsvContent = Invoke-WebRequest -Uri $microsoftCsvUrl
$microsoftCerts = $microsoftCsvContent.Content | ConvertFrom-Csv
Write-Host "[i] Microsoft CSV data loaded into memory"
Write-Host ""

# Define the stores you want to check
$stores = @("Root")
#$stores = @("Root", "CA", "AuthRoot", "TrustedPublisher", "Disallowed", "My")

# Initialize an array to hold the certificate fingerprints from the local machine
$localCertFingerprints = @()

# Extract the SHA256 fingerprints from column F in the Mozilla and Microsoft CSVs
$mozillaFingerprints = $mozillaCerts | Select-Object -ExpandProperty 'SHA-256 Fingerprint'
$microsoftFingerprints = $microsoftCerts | Select-Object -ExpandProperty 'SHA-256 Fingerprint'

# Combine the Mozilla and Microsoft fingerprints into a single list
$combinedFingerprints = $mozillaFingerprints + $microsoftFingerprints

# Loop over each store and get certificates
foreach ($storeName in $stores) {
    Write-Host "Processing store: $storeName"
    
    # Open the certificate store
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store($storeName, "LocalMachine")
    $store.Open("ReadOnly")
    
    # Loop over each certificate in the store
    foreach ($cert in $store.Certificates) {
        # Compute the SHA256 fingerprint
        $fingerprint = $cert.GetCertHashString("SHA256")
        
        # Check if the fingerprint exists in the combined list of Mozilla and Microsoft fingerprints
        if ($fingerprint -notin $combinedFingerprints) {
            # If not found, create an object to store the certificate's information
            $certInfo = [PSCustomObject]@{
                StoreName    = $storeName
                Thumbprint   = $cert.Thumbprint
                Subject      = $cert.Subject
                Issuer       = $cert.Issuer
                NotBefore    = $cert.NotBefore
                NotAfter     = $cert.NotAfter
                SerialNumber = $cert.SerialNumber
                SHA256       = $fingerprint
            }
            
            # Add the information to the array
            $localCertFingerprints += $certInfo
        }
    }
    
    # Close the store
    $store.Close()
}

# Sort the results by StoreName and then by Subject
$sortedCertFingerprints = $localCertFingerprints | Sort-Object StoreName, Subject

# Output the sorted results to a CSV file
$sortedCertFingerprints | Export-Csv -Path ".\Unmatched_Certs.csv" -NoTypeInformation

# Optionally, display the sorted results in the console
Write-Host ""
Write-Host "[!] The following CAs do not match and are unknown:"
$sortedCertFingerprints | Format-Table -AutoSize

Write-Host "Unmatched certificates have been saved to .\Unmatched_Certs.csv"
