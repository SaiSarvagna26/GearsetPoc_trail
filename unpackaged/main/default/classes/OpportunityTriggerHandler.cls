public class OpportunityTriggerHandler {
    public static void sumOfOpportunities(List<Opportunity> newList) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : newList) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        
        if (accountIds.isEmpty()) {        
            return;
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult agg : [SELECT AccountId, SUM(Amount) sumAmt FROM Opportunity WHERE AccountId IN : accountIds GROUP BY AccountId]) {
            Account acc = new Account();
            acc.Id = (Id) agg.get('AccountId');
            acc.Sum_Of_Opportunity_Amount__c = (Decimal) agg.get('sumAmt');
            accountsToUpdate.add(acc);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}