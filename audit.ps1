# Define the URL for the Mozilla Included CA Certificate Report CSV
$csvUrl = "https://ccadb.my.salesforce-sites.com/mozilla/IncludedCACertificateReportCSVFormat"
 
# Define the path where the CSV file will be saved
$csvFilePath = ".\IncludedCACertificateReport.csv"
 
# Download the CSV file
Invoke-WebRequest -Uri $csvUrl -OutFile $csvFilePath
 
Write-Host "CSV file downloaded to $csvFilePath"
 
# Define the stores you want to check
$stores = @("Root")
 
# Initialize an array to hold the certificate fingerprints from the local machine
$localCertFingerprints = @()
 
# Load Mozilla CA fingerprints from the CSV
$mozillaCerts = Import-Csv -Path $csvFilePath
 
# Extract the SHA256 fingerprints from column F in the Mozilla CSV
$mozillaFingerprints = $mozillaCerts | Select-Object -ExpandProperty 'SHA-256 Fingerprint'
 
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
         
        # Check if the fingerprint exists in the Mozilla list
        if ($fingerprint -notin $mozillaFingerprints) {
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
 
# Output the results of unmatched certificates to a CSV file
$localCertFingerprints | Export-Csv -Path ".\Unmatched_Certs.csv" -NoTypeInformation
 
# Optionally, display the results in the console
$localCertFingerprints | Format-Table -AutoSize
 
Write-Host "Unmatched certificates have been saved to .\Unmatched_Certs.csv"
