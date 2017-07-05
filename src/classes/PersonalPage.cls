public class PersonalPage extends GeneralController{

    public List<Game__c> myFutureGames{
        get{if (myFutureGames ==null) myFutureGames = new List<Game__c>();
            return myFutureGames;}
        set;
    }
    
    public PersonalPage(){
        myFutureGames = getMyFutureGames();
    } 
    
    public List<Game__c> getMyFutureGames(){
        List<Game__c> myGames = new List<Game__c>();
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null){
            myGames = [Select Id, Name, TournamentGame__c, Player_one__c, Player_two__c, 
                       FirstPlayerGoals__c, SecondPlayerGoals__c, isFPAccepted__c, isSPAccepted__c, Stage__c 
                       From Game__c Where (Player_one__c = :getCurrentPlayer().Id OR Player_two__c = :getCurrentPlayer().Id)
                       AND FirstPlayerGoals__c = 0 AND SecondPlayerGoals__c = 0];
        
        }
        return myGames;
    }
    
}