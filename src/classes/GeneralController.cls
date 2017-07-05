public abstract class GeneralController{

    public List<Player__c> allActivePlayers{
        get{
            return [SELECT ID,Name,Email__c,Status__c FROM Player__c Where Status__c = 'active'];
        }
        set;
    }
    public Player__c iPlayer{
        get{
            if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null){
                if(iPlayer == null) iPlayer = new Player__c();   
            }iPlayer = getCurrentPlayer();
            return iPlayer;
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
    
    public Game__c getCurrentGame(){
       if(ApexPages.currentPage().getParameters().get('id')==null) Game__c thisGame = new Game__c();
           Game__c thisGame=  [Select Id, Name, TournamentGame__c, Player_one__c, Player_two__c, 
                       FirstPlayerGoals__c, SecondPlayerGoals__c, isFPAccepted__c, isSPAccepted__c, Stage__c 
                       From Game__c Where Id= :ApexPages.currentPage().getParameters().get('id')];
           return thisGame;
       
    }
    
    public Player__c getCurrentPlayer(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null) 
        return [Select Id, Name, Email__c, isModerator__c From Player__c Where Email__c = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
        return new Player__c();
    }

}