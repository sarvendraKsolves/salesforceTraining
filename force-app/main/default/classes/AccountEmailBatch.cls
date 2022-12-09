global class AccountEmailBatch implements Database.Batchable<sObject>,Database.stateful {
    //As per the requirement - Need hard coded values
    Set<String> accountIds = new Set<String>{ '0015h000018DJW2AAO', '0015h000018DJW1AAO', '0015h000018DJUyAAO', '0015h000018DJUzAAO', '0015h000018DKaUAAW' };
        //Start Method
        global Database.QueryLocator start(Database.BatchableContext bc) {
            String query = 'SELECT Id,Name,Email__c,OwnerId FROM Account WHERE Id IN : accountIds';
            return Database.getQueryLocator(query);      
        }
    //Excution Method
    global void execute(Database.BatchableContext bc, List<Account> accountRecords){
        List<Messaging.SingleEmailMessage> lstMessage = new List< Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [
            SELECT Id, Body 
            FROM EmailTemplate 
            WHERE DeveloperName = 'MarketingProductInquiryResponse1997'
        ];
        for(Account acc : accountRecords)
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {acc.Email__c});
            email.setTargetObjectId(acc.OwnerId);
            email.setSaveAsActivity(false);
            email.setTemplateId(emailTemplate.Id);
            lstMessage.add(email);  
        }
        if(!lstMessage.isEmpty()){
            try{
                Messaging.sendEmail(lstMessage); 
            }
            catch(Exception e){
                //Keeping this debug to capture the exceptions
                System.debug('Email sending exception :'+e.getLineNumber() +' Message : '+e.getMessage());
            }
        }
    }    
    //Finish Method
    global void finish(Database.BatchableContext bc){
        List<Account> updateAccounts = new List<Account>();
        updateAccounts= [ 
            SELECT Sign_Up_date__c, Is_Sign_Up_Done__c 
            FROM Account 
            WHERE Id IN : accountIds 
        ];
        if(!updateAccounts.isEmpty()){
            for(Account acc : updateAccounts)
            {
                date inputdate = date.today();
                acc.Sign_Up_date__c=inputdate;
                acc.Is_Sign_Up_Done__c=true;
            }
            try{
                update updateAccounts;
            }
            catch(Exception e){
                //Keeping this debug to capture the exceptions
                System.debug('Finish Method Exception : Line - '+e.getLineNumber() +' Message : '+e.getMessage());
            }
        }
    }  
}