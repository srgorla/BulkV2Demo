## Retrieve  records
./retrieveSFRecords.sh --target-org sap --query 'SELECT subject, description, status, priority, origin, reason , type, Account.External_ID__c  FROM Case' --max-records 500 --file-pattern "Case%d.csv" 
# using shorthands
./retrieveSFRecords.sh -t sap -q 'SELECT subject, description, status, priority, origin, reason , type, Account.External_ID__c  FROM Case limit 50' -m 5 -f "Case%d.csv"

./retrieveSFRecords.sh -t int -q "Select Access_End_Date__c,Access_Given__c,Access_Notes__c,Access_Start_Date__c,Access_Type__c,AccountAndContactMatchIndicator__c,Account.SAP_Account_Number__c,After_Hours__c,Agent_Extension__c,Agent_Id__c,Agent_User__c,Approved__c,AssetId,Business_Case_for_Access__c,Business_Segment__c,BusinessHoursId,BypassQueueAttributeLookUpFilter__c,BypassValidation__c,Call_Center__c,Call_ID__c,Call_Type__c,Case_Owner_RacfId__c,Case_Pending__c,Case_Updated_By_Agent__c,CaseIndirectUpdate__c,Category__c,Category_of_Work__c,Channel__c,Cisco_Call_ID__c,Comments,Contact_Split_Required__c,Contact.SAP_Contact_Id__c,ContactingTeamMember__c,CreatedFromProfile__c,CSA_Disconnect__c,CTI_Call_Type__c,CTI_Load__c,CTI_Needed__c,CTI_Phone_Number__c,CurrencyIsoCode,Customer_Insight_ID__c,Customer_Solution_Identified__c,Description,Description_1__c,Description_2__c,Description_3__c,Duration__c,Email_Reference_Number__c,Email_Sender__c,EntitlementId,Environment_Requested__c,Estimated_Time_Actively_Working__c,ETC_From_Address__c,ETC_To_Address__c,ExecuteOmniFlow__c,Expedite__c,First_Call_Breached__c,Government_Account__c,Guest__c,Guest_Email__c,Guest_First_Name__c,Guest_Last_Name__c,Guest_Phone_Number__c,Is_PMNC__c,IsClosedOnCreate,IsEscalated,IsInbound__c,IsStopped,Junk_Email__c,Language,Last_Email_Message_Id__c,Lead__c,Level1_Category_prediction__c,Level1Category__c,Level2_Category_prediction__c,Level2Category__c,Level3_Category_prediction__c,Level3Category__c,Location__c,Manufacturer_1__c,Manufacturer_2__c,Manufacturer_3__c,Model_Number_1__c,Model_Number_2__c,Model_Number_3__c,Multiple_User_Access_Request__c,Null_To_Address__c,Origin,Original_Recipient_Email__c,Other__c,Other_Brand_1__c,Other_Brand_2__c,Other_Brand_3__c,OwnerId,ParentId,Pending_Internal_Other_Reason__c,Phone_Transfer__c,Post_Sale_Selection__c,Pre_Sale_Selection__c,Priority,PriorityCriteria__c,Product_Category__c,ProductId,Purchase_Order__c,Qty_1__c,Qty_2__c,Qty_3__c,Qty_Purchased_1__c,Qty_Purchased_2__c,Qty_Purchased_3__c,Qty_Purchased_4__c,Qty_Purchased_5__c,Qty_Purchased_6__c,Queue_prediction__c,QueueAttribute__c,RACFID__c,RACFID_Access_to_Mirror__c,Reason,Reason_for_Status__c,Reason_Solution_not_Identified__c,Recommendation__c,RecordTypeId,ReopenedCaseCount__c,Requested_For__c,Resolved_Other_Comments__c,ResolvedBy__c,ResolvedCaseSub_Category__c,Restore_Case_Id__c,Route_to_Queue__c,RouteToQueue__c,Run_Case_Assignment_Rules__c,Sales_Order__c,SAP_Account_Numbers_From_Email__c,SAP_Acct_Numbers_From_Email__c,SAP_Order_Number__c,SAP_Order_type__c,Search_Brand_1__c,Search_Brand_2__c,Search_Brand_3__c,SecondaryMilestoneExpirationDatetime__c,Seller_Call__c,Seller_Call_Name__c,Seller_Submitted__c,Service_Cloud_User__c,Service_Lead_Details__c,Service_Lead_Details_long__c,Service_Now_Ticket__c,Service_Requested_but_not_Offered__c,Service_Type__c,ServiceContractId,SKU_1__c,SKU_2__c,SKU_3__c,SKU_4__c,SKU_5__c,SKU_6__c,SlaStartDate,Social_Media_Pilot__c,Solution_Type__c,SourceId,Sourcing_Quote__c,Sourcing_Quote_Name__c,Status,Sub_Category__c,Sub_Status__c,Subject,Submitted_Seller__c,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,SurveyCriteriaMet__c,System_Admin_Recommendation__c,Temporary__c,Temporary_Event__c,ToAddress__c,TPS_Notes__c,Type,Type_of_Lead__c,User_ID_Vendor_Number__c from case where account.Aligned_Branch__r.Branch_Id__c ='145' and IsClosed = true and Origin  = 'Email' limit 1000 " -f "Case145%d.csv"


## insert records
./retrieveSFRecords.sh --target-org sap --query 'SELECT subject, description, status, priority, origin, reason , type, Account.External_ID__c  FROM Case limit 10' --max-records 5 --file-pattern "Case%d.csv"

./trigger_bulk_v2_jobs.sh --target-org sap --object Case --operation insert --file-pattern "Case%d.csv"


## Delete  records
./retrieveSFRecords.sh --target-org sap --query 'SELECT id FROM Case where createddate = today' --file-pattern "CaseDelete%d.csv"

./trigger_bulk_v2_jobs.sh --target-org sap --object Case --operation delete --file-pattern "CaseDelete%d.csv"

## upsert records
./retrieveSFRecords.sh --target-org sap --query 'SELECT Name, billingstreet, billingcity, BillingState,  BillingPostalCode,  BillingCountry, External_ID__c  FROM Account where External_ID__c != null '  --file-pattern "Account%d.csv"

./trigger_bulk_v2_jobs.sh --target-org  sap --object Account --operation upsert --external-id External_ID__c --file-pattern "Account%d.csv"

./trigger_bulk_v2_jobs.sh --target-org  sap --object Account --operation upsert --external-id External_ID__c --file-pattern "test_accounts%d.csv"
sh ./trigger_bulk_v2_jobs.sh --target-org  sap --object Account --operation upsert --external-id External_ID__c --file-pattern "test_accounts%d.csv"


./trigger_bulk_v2_jobs.sh --target-org  sap --object Case --operation insert --external-id External_ID__c --file-pattern "test_cases%d.csv"
sh ./shell/trigger_bulk_v2_jobs.sh --target-org  sap --object Case --operation insert --external-id External_ID__c --file-pattern "test_cases%d.csv"

SF CLI commands - access token, instance url 
jq - json parsing
curl commands -  http calls 
bulk v2 - (query, delete, insert, upsert)
Locator  - to query more results records 


Chunking files into smaller files - Bulk v2 limits - 150 MB size 
for performance improvement - submit multiple jobs (SF allows 5 at a time to run ) 
Default - parallel processing 


sf data query resume -i 7508L000003ohSe -r csv 

sf data query resume -i 7508L000003oaQWQAY -r csv 


python3 python/generate_test_accounts_with_cases.py   
python3 python/generate_test_accounts.py

./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Account --operation delete --file-pattern "AccountDelete%d.csv"



Demo 
pwd -> shell 

cd ..
python3 python/generate_test_accounts.py


cd shell

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "test_accounts_%d.csv"

./retrieveSFRecords.sh --target-org dcdemo --query 'SELECT id FROM Account where createddate = today' --file-pattern "AccountDelete%d.csv" -m 100000




Demo 
python3 generate_test_accounts.py 10000000

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "sample_accounts_%d.csv"


./retrieveSFRecords.sh --target-org dcdemo --query 'SELECT id FROM Account' --file-pattern "AccountDelete%d.csv" -m 100000

./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Account --operation hardDelete --file-pattern "AccountDelete%d.csv"


./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Account --operation hardDelete --file-pattern "AccountDeletetest%d.csv"

Insert Account - Case data 
















Sandbox Seeding 

Start with Blank state 
    Delete all Accounts and Cases 

./retrieveSFRecords.sh --target-org dcdemo --query "SELECT id FROM Case where  account.External_ID__c like 'CD%' " --file-pattern "CaseDelete%d.csv" -m 100000

./retrieveSFRecords.sh --target-org dcdemo --query "SELECT id FROM Account where  External_ID__c like 'CD%' " --file-pattern "AccountDelete%d.csv" -m 100000

./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Case --operation hardDelete --file-pattern "CaseDelete%d.csv"

./trigger_bulk_v2_jobs.sh --target-org dcdemo --object Account --operation hardDelete --file-pattern "AccountDelete%d.csv"




python3 generate_test_accounts_with_cases.py
    100 accounts - 5 cases for each account 

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "test_accounts_%d.csv"

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Case --operation insert --file-pattern "test_cases_%d.csv"

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "test_accounts_%d.csv"









./sandbox_seeding_cleanup.sh
python3 generate_test_accounts.py 1000000


Demo 

./sandbox_seeding.sh  


Query Data 
    External id
    query locator 
    small chunks

./retrieveSFRecords.sh --target-org dcdemo --query 'SELECT id, name, BillingStreet,BillingCity,BillingState, BillingPostalCode, BillingCountry, External_ID__c FROM Account Limit 250000' --file-pattern "AccountExtract%d.csv" -m 100000

Big Data 

    150 MB upload limit issues 
        small chunks 

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "sample_accounts_consolidated_%d.csv"
    takes lot of time to process 

./trigger_bulk_v2_jobs.sh --target-org  dcdemo --object Account --operation upsert --external-id External_ID__c --file-pattern "sample_accounts_%d.csv"
    completes in 1/5 of the time for the sameload 


./retrieveSFRecords.sh --target-org int --query "Select  type, origin,  Level1Category__c, Level2Category__c, status,  Channel__c,  subject , Description  from case where isclosed = true  and account.Aligned_Branch__r.Branch_Id__c = '145' and Level1Category__c  != null limit 10000" --file-pattern "JP_Casest%d.csv" -m 100000

./trigger_bulk_v2_jobs.sh --target-org  jp --object Case --operation insert --file-pattern "JP_Cases%d.csv"



