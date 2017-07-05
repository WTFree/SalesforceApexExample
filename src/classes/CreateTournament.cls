public class CreateTournament{
     
     public boolean getStatusPlayer{get; set;}
     public List<Tournament__c> allTournament{get; set;}    
     public Tournament__c currentTournament{get; set;}  

     public Tournament__c tournament {
        get {
            if (tournament== null)
                tournament= new Tournament__c();
                return tournament;
            }
        set;
    }
     
    public CreateTournament(){
        currentTournament = getTournament();
        if(ApexPages.currentPage().getCookies().get('PlayerSession') !=null){
            getStatusPlayer = isModeratorPlayer();
        }
        allTournament = getAllTournaments();   
    }

    public Tournament__c getTournament(){      
        List<Tournament__c> thisTournament = [SELECT ID, Name, End_Date__c, Start_Date__c, Player_Type__c, Status__c, Type_of_Elimination_Tournament__c 
                                              FROM Tournament__c where id =: ApexPages.currentPage().getParameters().get('id')];
        if(thisTournament.size()>0){
        return thisTournament.get(0);}
        return null;
    }
    
    public PageReference create(){
    
        PageReference pageRef = new PageReference('/apex/CreateTournament');      
        pageRef.setRedirect(true);
        if(tournament.Status__c == 'IN PROGRESS'){
        List<Tournament__c> checkList = [SELECT Id From Tournament__c where Status__c = 'IN PROGRESS'];
        if(checkList.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Another tournament has already in progress, you must change "Status"'));
            return null;
        }}
        try {
             Database.insert(tournament);
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new tournament.'));
            return null;
        }
        return pageRef ;
    }
    
    public boolean isModeratorPlayer(){
         List<Player__c> selectPlayer = new List<Player__c>();
         selectPlayer = [Select Email__c, Status__c, isModerator__c from Player__c 
                         where Email__c=:ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
         if(selectPlayer.size() !=null && selectPlayer.get(0).Status__c == 'active'){
             return selectPlayer.get(0).isModerator__c;
         }else{return false;}
         
    }  
    
    public List<Tournament__c> getAllTournaments(){
        List<Tournament__c> tournaments = [SELECT ID, Name, End_Date__c, Start_Date__c, Player_Type__c, Status__c, Type_of_Elimination_Tournament__c
                                           FROM Tournament__c ORDER BY Tournament__c.End_date__c];
        return tournaments;
    }
    
    public PageReference updateTournament(){
        if(currentTournament.Status__c == 'IN PROGRESS'){
        List<Tournament__c> checkList = [SELECT Id From Tournament__c where Status__c = 'IN PROGRESS'];
        if(checkList.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Another tournament has already in progress, you must change "Status"'));
            return null;
        }}
        try {
             Database.update(currentTournament);
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error update this tournament.'));
            return null;
        }
        return Page.UpdateTournament;
    }
    
    public PageReference deleteTournament(){
        PageReference pageRef = new PageReference('/apex/CreateTournament');      
        pageRef.setRedirect(true);
        try {
             Database.delete(currentTournament);
        } catch (DMLException e) {
            return pageRef;
        }
        return pageRef;
    }
    
    public void sendNewTournamentEmail(){    
        List<Player__c> allPlayersEmails = [Select Email__c From Player__c];
        for(Player__c p : allPlayersEmails){
            if(p.Email__c !=null){
                List < String > toAddresses = new List < String > ();
                List < String > CcAddresses = new List < String > ();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                toAddresses.add(p.Email__c);
                ccAddresses.add('vitaly.gaiduchok@gmail.com');
                mail.setToAddresses(toAddresses);
                mail.setCcAddresses(CcAddresses);
                mail.setSenderDisplayName('Check our new Tournament, Vialy Gaoduchok');
                mail.setSubject('Check our new Tournament, Vialy Gaoduchok');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setPlainTextBody('Test');
                mail.setHtmlBody('New tournament has been created, you can join to this tournament. Pls watch at our schedule tournaments<br/><a href="http://gaiduchokttt-developer-edition.eu11.force.com/RepresentTableTennisTournament"> CLICK HERE </a>');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
        }
    }
    
}