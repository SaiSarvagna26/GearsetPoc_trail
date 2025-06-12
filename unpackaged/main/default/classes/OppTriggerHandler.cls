public class OppTriggerHandler {
    public static Void getOpportunityStage(List<Opportunity> opportunityDetails){
        
        Id profileId=userinfo.getProfileId();
        String profileName=[SELECT Id,Name from Profile WHERE Id=:profileId].Name;
        Set<Id> opportunityToDelete = new Set<Id>();
        
        if(profileName != 'System Administrator'){          
            for(Opportunity opp : opportunityDetails){
                if(opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost'){
                    opp.addError('System Administrator can only delete Closed Opportunities.');
                }
            }
        }
        else{
            for(Opportunity opp : opportunityDetails){
                if(profileName == 'System Administrator' && opp.StageName == 'Closed Won' ){
                    opportunityToDelete.add(opp.OwnerId);
                }
            }
            List<User> userEmailList = new List<User>([SELECT Id, Email FROM User WHERE Id IN : opportunityToDelete]);
            List<Messaging.SingleEmailMessage> emailsWithTargetObjectId = new List<Messaging.SingleEmailMessage>();
            for (User u : userEmailList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {u.Email});
                email.setSubject('Opportunity Deletion');
                email.setPlainTextBody('Your opportunity has been deleted');
                emailsWithTargetObjectId.add(email);
            }
            if (!emailsWithTargetObjectId.isEmpty()) {
                Messaging.sendEmail(emailsWithTargetObjectId);
            }
        }        
    }    
}
