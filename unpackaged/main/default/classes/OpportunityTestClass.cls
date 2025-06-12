@isTest
public class OpportunityTestClass {
    @isTest
    public static void sumOfOpportunitiesTest(){
        List<Account> accList = New List<Account>();
        Account acc = New Account();
        acc.Name = 'Test';
        accList.add(acc);
        insert accList;
        
        List<Opportunity> oppList = New List<Opportunity>();
        for(Integer i=1;i<=100;i++){
            Opportunity opp = New Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'Opp Test '+i;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.TODAY()+10;
            opp.Amount = 1+i;
            oppList.add(opp);
        }
        insert oppList;
        
        List<Opportunity> oppListWithoutAccountId = New List<Opportunity>();
        for(Integer i=1;i<=10;i++){
            Opportunity opp = New Opportunity();
            opp.Name = 'Opp Test No Account '+i;
            opp.StageName = 'Prospecting';
            opp.CloseDate = System.TODAY()+10;
            opp.Amount = 1+i;
            oppListWithoutAccountId.add(opp);
        }
		insert oppListWithoutAccountId;
        Test.startTest();
		OpportunityTriggerHandler.sumOfOpportunities(oppList);
        OpportunityTriggerHandler.sumOfOpportunities(oppListWithoutAccountId);
        Test.stopTest();

        acc = [SELECT Sum_Of_Opportunity_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(5150.00, acc.Sum_Of_Opportunity_Amount__c);
    }
}