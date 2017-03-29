param 
    ( 
        [parameter(Mandatory=$True)]  
        [String]  
        $tenantId
    ) 


.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'miller@gofastpath.com' -adminFirstName 'Chris' -adminLastName 'Miller'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'nelson.middendorff@gofastpath.com' -adminFirstName 'Nelson' -adminLastName 'Middendorff'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'ben.meredith@gofastpath.com' -adminFirstName 'Ben' -adminLastName 'Meredith'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'zach.messerschmidt@gofastpath.com' -adminFirstName 'Zach' -adminLastName 'Messerschmidt'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'zach.wear@gofastpath.com' -adminFirstName 'Zach' -adminLastName 'Wear'
.\NewAdmin.ps1 -tenantId $tenantId -adminEmailAddress 'meyer@gofastpath.com' -adminFirstName 'Alex' -adminLastName 'Meyer'
