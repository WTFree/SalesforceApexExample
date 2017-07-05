public class RepresentTableTennisTournament{

    public List<Tournament__c> allTournament{get; set;}    
    public Tournament__c currentTournament{get; set;}  
    public boolean getStatusPlayer{get;set;}
    
    public RepresentTableTennisTournament(){
        allTournament = getAllTournaments();
        if(ApexPages.currentPage().getCookies().get('PlayerSession') !=null ){
            getStatusPlayer = isModeratorPlayer(); 
        }  
    }
    
    public List<Tournament__c> getAllTournaments(){
    
        List<Tournament__c> tournaments = [SELECT ID, Name, End_Date__c, Start_Date__c, Player_Type__c, Status__c, Type_of_Elimination_Tournament__c
                                           FROM Tournament__c ORDER BY Status__c];
        return tournaments;
    }
    
    public boolean isModeratorPlayer(){
        List<Player__c> selectPlayer=  [Select Status__c, isModerator__c from Player__c 
                                        where Email__c=:ApexPages.currentPage().getCookies().get('PlayerSession').getValue() Limit 1];
        if(selectPlayer.get(0) != null && selectPlayer != null && selectPlayer.size() !=null && selectPlayer.size() >0 && 
           selectPlayer.get(0).Status__c !=null && selectPlayer.get(0).Status__c == 'active' && selectPlayer.get(0).isModerator__c !=null && 
           selectPlayer.get(0).isModerator__c == true){
            return true;
        }return false;       
    }
}