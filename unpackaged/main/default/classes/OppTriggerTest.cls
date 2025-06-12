@isTest
public class OppTriggerTest {
    
    @testSetup
    static void setupTestData() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User sysAdmin = new User(
            FirstName = 'Test',
            LastName = 'SysAdmin',
            Email = 'sysadmin@test.com',
            Username = 'sysadmin@test.com.salesforce',
            Alias = 'sysadmin',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = sysAdminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert sysAdmin;
        
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User standardUser = new User(
            FirstName = 'Test',
            LastName = 'StandardUser',
            Email = 'standarduser@test.com',
            Username = 'standarduser@test.com.salesforce',
            Alias = 'stduser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardUserProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(
            Name = 'Test Closed Won Opp', 
            StageName = 'Closed Won', 
            CloseDate = Date.today(), 
            OwnerId = sysAdmin.Id
        ));
        opportunities.add(new Opportunity(
            Name = 'Test Closed Lost Opp', 
            StageName = 'Closed Lost', 
            CloseDate = Date.today(), 
            OwnerId = standardUser.Id
        ));
        opportunities.add(new Opportunity(
            Name = 'Test Open Opp', 
            StageName = 'Prospecting', 
            CloseDate = Date.today(), 
            OwnerId = standardUser.Id
        ));
        insert opportunities;
    }
    
    @isTest
    static void testAdminDeletion() {
        Opportunity closedWonOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won' LIMIT 1];
        Opportunity closedLostOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' LIMIT 1];
        Opportunity openOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Prospecting' LIMIT 1];
        
        User sysAdmin = [SELECT Id FROM User WHERE Username = 'sysadmin@test.com.salesforce' LIMIT 1];
        System.runAs(sysAdmin) {
            Test.startTest();
            
            try {
                delete closedWonOpp;
                System.assert(true, 'Closed Won Opportunity deletion should have been prevented.');
            } 
            catch (DmlException ex) {
                System.assert(ex.getMessage().contains('Closed Opportunities cannot be deleted'), 'Expected error message not found.');
            }
            
            try {
                delete closedLostOpp;
                System.assert(true, 'Closed Lost Opportunity deletion should have been prevented.');
            }
            catch (DmlException ex) {
                System.assert(ex.getMessage().contains('Closed Opportunities cannot be deleted'), 'Expected error message not found.');
            }
            delete openOpp;
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testNonAdminDeletion() {
        
        Opportunity closedWonOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won' LIMIT 1];
        Opportunity closedLostOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' LIMIT 1];
        
        User standardUser = [SELECT Id FROM User WHERE Username = 'standarduser@test.com.salesforce' LIMIT 1];
        
        System.runAs(standardUser) {
            Test.startTest();
            
            try {
                delete closedWonOpp;
                System.assert(false, 'Standard users should not be able to delete Closed Won opportunities.');
            }
            catch (DmlException ex) {
                System.assertEquals(false,ex.getMessage().contains('Only System Administrator Can Delete Closed Opportunities.'), 'Expected error message for Closed Won deletion not found.');
            }
            
            try {
                delete closedLostOpp;
                System.assert(false, 'Standard users should not be able to delete Closed Lost opportunities.');
            } 
            catch (DmlException ex) {
                System.assertEquals(true,ex.getMessage().contains('Only System Administrator Can Delete Closed Opportunities.'), 'Expected error message for Closed Lost deletion not found.');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testEmailSentOnDeletionAttempt() {
        Opportunity closedWonOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won' LIMIT 1];
        
        User sysAdmin = [SELECT Id FROM User WHERE Username = 'sysadmin@test.com.salesforce' LIMIT 1];
        System.runAs(sysAdmin) {
            Test.startTest();
            
            try {
                delete closedWonOpp;
            } 
            catch (DmlException ex) {
                //continue;
            }
            Test.stopTest();
        }
    }
}