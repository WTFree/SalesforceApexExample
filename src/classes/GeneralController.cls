public abstract class GeneralController{

    public List<Player__c> allActivePlayers{
        get{
            return [SELECT ID,Name,Email__c,Status__c FROM Player__c Where Status__c = 'active'];
        }
        set;
    }
    public List<Player__c> allActivePlayersWithoutMe{
        get{
            return [SELECT ID,Name,Email__c,Status__c FROM Player__c Where Status__c = 'active' AND
                    Email__c != :ApexPages.currentPage().getCookies().get('playerSession').getValue()];
        }
        set;
    }

}