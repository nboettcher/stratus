param 
    ( 
        [parameter(Mandatory=$True)]  
        [String]  
        $tenantId
    ) 


.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'ethan.hartman@gofastpath.com' -adminFirstName 'Ethan' -adminLastName 'Hartman' -idp 'AzureAD' -idpUserId 'ethan.hartman@gofastpath.com'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'ben.meredith@gofastpath.com' -adminFirstName 'Ben' -adminLastName 'Meredith' -idp 'AzureAD' -idpUserId 'ben.meredith@gofastpath.com'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'zach.messerschmidt@gofastpath.com' -adminFirstName 'Zach' -adminLastName 'Messerschmidt' -idp 'AzureAD' -idpUserId 'zach.messerschmidt@gofastpath.com'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'zach.wear@gofastpath.com' -adminFirstName 'Zach' -adminLastName 'Wear' -idp 'AzureAD' -idpUserId 'zach.wear@gofastpath.com'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'meyer@gofastpath.com' -adminFirstName 'Alex' -adminLastName 'Meyer' -idp 'AzureAD' -idpUserId 'meyer@gofastpath.com'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'matthew.smith@gofastpath.com' -adminFirstName 'Matt' -adminLastName 'Smith' -idp 'AzureAD' -idpUserId 'matthew.smith@gofastpath.com'
