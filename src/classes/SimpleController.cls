public class SimpleController {

    public boolean checkCookie { get; set; }
    public boolean getStatusPlayer{get; set;}
    public Cookie playerCookie { get; set; }
    public List<Tournament__c> tournamentInProgress{get;set;}
    public Player__c player {
        get {
            if (player == null)
                player = new Player__c();
                return player;
            }
        set;
    }    
    public Tournament__c tournament {
        get {
            if (tournament== null)
                tournament= new Tournament__c();
                return tournament;
            }
        set;
    }
    
    public SimpleController(){
         playerCookie= ApexPages.currentPage().getCookies().get('PlayerSession');
         if(playerCookie != null){
             checkCookie=true; 
             getStatusPlayer = isModeratorPlayer();
             player = getPlayer();   
         }
         else{
             checkCookie=false;
             getStatusPlayer = false;
         }
         tournamentInProgress = getAllTournamentsInProgress();
    }
    
    public Player__c getPlayer(){
        return [Select Name, Email__c From Player__c Where Email__c = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()]; 
    }
    
    public PageReference loginUser(){
        List<Player__c> selectPlayer = [Select Status__c, Password__c from Player__c where Email__c = :player.Email__c Limit 1];
        if(selectPlayer.size() > 0){
            if(selectPlayer.get(0).Status__c == 'active'){
                if(selectPlayer.get(0).Password__c == player.Password__c){
                    Cookie ps = new Cookie('PlayerSession', player.Email__c, null, 10000, false); //ps = player session
                    ApexPages.currentPage().setCookies(new Cookie[]{ps});
                    PageReference acctPage = new PageReference('/apex/Home');
                    acctPage.setRedirect(true);
                    return acctPage ;
                }else{ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Incorrect password'));
                      return null;}
            }else{ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'To begin with you must activate your account'));
                  return null;}
        }else {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Incorect Email'));
               return null;}
        
    }
    
    public PageReference logoutUser(){
        Cookie playerSession = ApexPages.currentPage().getCookies().get('PlayerSession');
        if(playerSession != null){
            playerSession = new Cookie('PlayerSession','',null,0,false);
            ApexPages.currentPage().setCookies(new Cookie[]{playerSession });
        }
        PageReference acctPage = new PageReference('/apex/Home');
        acctPage.setRedirect(true);
        return acctPage ;
    }
    
    public PageReference create(){
        try {
            Database.insert(tournament);
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new tournament.'));
            return null;
        }
        return Page.Home;
    }
    
    public boolean isModeratorPlayer(){
         List<Player__c> selectPlayer = new List<Player__c>();
         selectPlayer = [Select Email__c, Status__c, isModerator__c from Player__c 
                         where Email__c= :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
         if(selectPlayer.size() !=null && selectPlayer.get(0).Status__c == 'active'){
             return selectPlayer.get(0).isModerator__c;
         }else{return false;}
         
    }
    public List<Tournament__c> getAllTournamentsInProgress(){
    
        List<Tournament__c> tournaments = [SELECT ID, Name, End_Date__c, Start_Date__c, Player_Type__c, Status__c, Type_of_Elimination_Tournament__c
                                           FROM Tournament__c Where Status__c = 'IN PROGRESS'];
        return tournaments;
    }
}