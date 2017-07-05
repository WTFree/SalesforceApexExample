public class MyTeamClass extends GeneralController{
    
    public List<Player__c> allPlayers{get;set;}
    public Player__c playerBySearch{get;set;}    
    public Player__c currentPlayer{get;set;}
    public boolean captaionOfThisTeam{get;set;}
    public boolean captaionOfThisTeamForThisTournament{get;set;}
    public String selectedPlayer{get;set;}
    public List<Player__c> myTeamForThisTournament{
        get{
            Set<Team__c> thisTeam = new Set<Team__c>();
            thisTeam.addAll([Select Id From Team__c Where TournamendID__c = :ApexPages.currentPage().getParameters().get('id')]); 
                
            if(myTeamForThisTournament==null) myTeamForThisTournament = new List<Player__c>();
            myTeamForThisTournament = [Select Name,Email__c From Player__c Where Status__c = 'active' AND 
                                       Id in (Select Player_Child__c From Junction_Player_Team_Object__c Where Team_child__c = :thisTeam)];
            return myTeamForThisTournament;
        }
        set;
    }
    public List<SelectOption> playersOptions {
        get {
            if (playersOptions == null) {
                playersOptions = new List<SelectOption>();
                Set<Team__c> thisTeam = new Set<Team__c>();
                thisTeam.addAll([Select Id From Team__c Where TournamendID__c = :ApexPages.currentPage().getParameters().get('id')]); 
                
                List<Player__c> allPlayersInTeamForCurrentTournament = [Select ID,Name,Email__c,Status__c From Player__c Where Status__c = 'active' AND 
                                                                        Id in (Select Player_Child__c From Junction_Player_Team_Object__c Where Team_child__c = :thisTeam)];
                Set<Player__c> setAllPlayersInTeamForCurrentTournament = new Set<Player__c>();
                setAllPlayersInTeamForCurrentTournament.addAll(allPlayersInTeamForCurrentTournament); 
                for(Player__c p : allActivePlayersWithoutMe) {
                        if(setAllPlayersInTeamForCurrentTournament.contains(p)){
                                SelectOption SO = new SelectOption(p.id, p.Name+' has already been in team', true);
                                playersOptions.add(SO);
                        }
                        else{
                            SelectOption SO = new SelectOption(p.id, p.Name);
                            playersOptions.add(SO);
                    
                    }
                }
            }
        return playersOptions;
        } 
        set;
    }
    public Team__c myTeam{
        get{
            if (myTeam== null)
                myTeam= new Team__c();
                return myTeam;
            }
        set;
    }
    public Junction_Player_Team_Object__c myTeamAtThisTournament{
        get{
            if(myTeamAtThisTournament == null) myTeamAtThisTournament = new Junction_Player_Team_Object__c ();
            return myTeamAtThisTournament;
        }
        set;
    }
    public Tournament__c currentTournament{
        get{
            if(currentTournament == null) currentTournament = new Tournament__c();
            return currentTournament;
        }
        set;
    }
    public String tournamentId{
        get{return ApexPages.currentPage().getParameters().get('id');}
        set;
    }
    public MyTeamClass(){
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null){
                captaionOfThisTeam = teamAlreadyRegisteredForCurrentPlayer();
                captaionOfThisTeamForThisTournament = playerTeamAlreadyRegisteredForCurrentPlayer();
                currentTournament = [Select Id,Name From Tournament__c Where Id = :tournamentId];
            }
        }
        allPlayers = getAllPlayers();
        playerBySearch= doSearch();        
    }
    

    
    public PageReference joinToTournament(){
        String playerEmail = [Select Email__c From Player__c Where Id = :selectedPlayer].Email__c;
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null){
            myTeamAtThisTournament.Team_child__c = [Select Id From Team__c Where firstPlayer__c in(
                                                    Select Id From Player__c Where Email__c = : ApexPages.currentPage().getCookies().get('PlayerSession').getValue())].Id;   
            sendEmail(playerEmail,myTeamAtThisTournament.Team_child__c);
            
            myTeamAtThisTournament.Player_Child__c = [Select Id From Player__c Where Email__c = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()].Id;
            if(selectedPlayer !=null && currentPlayer != null && selectedPlayer == currentPlayer.Id){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You cann\'t invite yourself'));
                return null;
            }
            upsert myTeamAtThisTournament;
        }
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;   
    }       
    
    public PageReference createTeam(){
        if(teamAlreadyRegisteredForCurrentPlayer() == false){      
            myTeam.TournamendID__c = tournamentId;
            myTeam.firstPlayer__c = [Select Id From Player__c Where Email__c = : ApexPages.currentPage().getCookies().get('PlayerSession').getValue()].Id;   
            try{insert myTeam;}
            catch(DMLException e){}
        }
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }
     
    public boolean teamAlreadyRegisteredForCurrentPlayer(){
        Integer teamForThisPlayer = [SELECT COUNT() FROM Team__c 
                                     WHERE TournamendID__c = :tournamentId AND firstPlayer__c in 
                                     (Select Id From Player__c Where Email__c = : ApexPages.currentPage().getCookies().get('PlayerSession').getValue())];
        
        return teamForThisPlayer >0;
    }
    public boolean playerTeamAlreadyRegisteredForCurrentPlayer(){
        
        List<Player__c> thisPlayer = [Select Id From Player__c Where Email__c = : ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
        Integer teamForThisPlayer = [SELECT COUNT() FROM Junction_Player_Team_Object__c 
                                     WHERE Team_Child__c in (Select Id From Team__c Where TournamendID__c = :tournamentId
                                     And firstPlayer__c= :thisPlayer)];
        if(teamAlreadyRegisteredForCurrentPlayer())return teamForThisPlayer >0;
        return false;
    }
    
    public void sendEmail(String secondPlayerEmail, String teamID){
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Player__c thisSecondPlayer = [SELECT ID,Email__c FROM Player__c WHERE Email__c = :secondPlayerEmail];
        String teamName = [Select Name From Team__c Where id = :teamID].Name; 
        
        String[] toAddresses = new String[] {thisSecondPlayer .Email__c};
        String[] ccAddresses = new String[] {'vitaly.gaiduchok@gmail.com'};

        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);

     
        mail.setSenderDisplayName('Submit your team invite');

        mail.setSubject('Submit your team invite');

        mail.setBccSender(false);

        mail.setUseSignature(false);

        mail.setPlainTextBody('Test');

        mail.setHtmlBody('Hello -> '+ teamName + ' <- invite you, if you want to join to this team click down<b><br/><a href="http://gaiduchokttt-developer-edition.eu11.force.com/myTeamAccepted?playerCode=' + thisSecondPlayer.Id+ '&teamCode='+teamID+'">Click here</a>');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
        
    public List<Player__c> getAllPlayers(){
        if(ApexPages.currentPage().getParameters().get('Email__c') != null){return null;}
        return [SELECT ID, Name, Email__c FROM Player__c where Status__c = 'active'];
    }
    
    
    public Player__c doSearch(){
         if(ApexPages.currentPage().getParameters().get('Email__c') == null){return null;}
         return [SELECT ID, Name, Email__c FROM Player__c where Status__c = 'active' AND Email__c = :ApexPages.currentPage().getParameters().get('Email__c')];      
    } 
}