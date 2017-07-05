public class CurrentTournament implements ICurrentTournament{

    public boolean checkCookie { get; set; }
    public Tournament__c currentTournament{get;set;}
    public boolean getStatusPlayer{get; set;}
    public boolean checkRegistrationForTournir{get;set;}
    public boolean writeResultThisMatch{get;set;}
    public Integer getActualCountTounamentPlayers{get;set;}
    public String actualTournamentType{get;set;}
    public List<Player__c> allRegisteredPlayers{get;set;}
    public List<Team__c> allRegisteredTeams{get;set;}
    public List<Game__c> allCurrentGames{get;set;}
    public List<List<Game__c>> singleEliminationGrid{get{
        if(singleEliminationGrid == null) singleEliminationGrid  = new List<List<Game__c>>();
        return singleEliminationGrid ;}
        set;}
    public List<Game__c> SEround1{get;set;}
    public List<Game__c> SEround2{get;set;}
    public List<Game__c> SEround3{get;set;}
    public List<Game__c> SEround4{get;set;}
    public List<List<Game__c>> RRGrid{get{
        if(RRGrid== null) RRGrid= new List<List<Game__c>>();
        return RRGrid;
        }set;}
    public Player__c player {
        get {
            if (player == null)
                player = new Player__c();
                return player;
            }
        set;
    }    
    
    public CurrentTournament(){
        currentTournament = getTournament();
        if(ApexPages.currentPage().getCookies().get('PlayerSession') != null){
            checkCookie=true;
            getStatusPlayer = isModeratorPlayer();
            checkRegistrationForTournir = isRegisteredForTournir(); 
            getActualCountTounamentPlayers = fullTournament();
            allCurrentGames= getCurrentGames(); 
            singleEliminationGrid = makeGridOfSingleTournament();
            if(singleEliminationGrid.size() !=null && singleEliminationGrid.size()>0){
                SEround1 = singleEliminationGrid.get(0);
                if(singleEliminationGrid.size()>1){
                SEround2 = singleEliminationGrid.get(1);
                    if(singleEliminationGrid.size()>2){
                    SEround3 = singleEliminationGrid.get(2);
                    if(singleEliminationGrid.size()>3){
                        SEround4 = singleEliminationGrid.get(3);
                        }else{SEround4  = new List<Game__c>();}
                    }else{SEround3  = new List<Game__c>();}
                }else{SEround2  = new List<Game__c>();}
            }else{SEround1  = new List<Game__c>();}
            RRGrid = makeGridOfRRTournament();
        }else{singleEliminationGrid  = new List<List<Game__c>>();
              RRGrid = new List<List<Game__c>>();}
            allRegisteredPlayers= getAllRegisteredPlayers();
            allRegisteredTeams = getAllRegisteredTeams();
            actualTournamentType = getActualTournamentType(); 
    }
    
    public Tournament__c getTournament(){      
        List<Tournament__c> thisTournament = [SELECT ID, Name, End_Date__c, Start_Date__c, Player_Type__c, Status__c, Type_of_Elimination_Tournament__c 
                                              FROM Tournament__c where id =: ApexPages.currentPage().getParameters().get('id')];
        if(thisTournament.size()>0){
        return thisTournament.get(0);}
        return null;
    }
    
    public String getActualTournamentType(){
        return [Select Type_of_Elimination_Tournament__c From Tournament__c 
                Where Id = :ApexPages.currentPage().getParameters().get('id')].Type_of_Elimination_Tournament__c;
    }
    
    public Player__c getPlayer(){
        return [Select ID, Name, Email__c,isModerator__c,Status__c From Player__c 
                Where Email__c= :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
    }
    
    public boolean isModeratorPlayer(){
        List<Player__c> selectPlayer=  [Select Email__c, Status__c, isModerator__c from Player__c 
                                        where Email__c=:ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
        if(selectPlayer.size() !=null && selectPlayer.get(0).Status__c == 'active'){
            return selectPlayer.get(0).isModerator__c;
        }else{return false;}       
    }
    
    public boolean isRegisteredForTournir(){
        Junction_Player_Tournament_Object__c playerTournamentJunctionObject = new Junction_Player_Tournament_Object__c();
        Player__c testPlayer = [Select Id From Player__c where Email__c = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
        playerTournamentJunctionObject.Player_Child__c = testPlayer.Id;
        playerTournamentJunctionObject.Tournament_child__c = ApexPages.currentPage().getParameters().get('id');
        List<Junction_Player_Tournament_Object__c> listPlayerTournament = [Select Id From Junction_Player_Tournament_Object__c
                                                                           WHERE Player_Child__c = :playerTournamentJunctionObject.Player_Child__c AND 
                                                                           Tournament_child__c = :playerTournamentJunctionObject.Tournament_child__c ];
        if(listPlayerTournament.size()>0){
            return true;
        } return false;       
    }
        
    public PageReference takeTournamentPart(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession') !=null){
            if(getTournament().Player_type__c=='Single'){
                Junction_Player_Tournament_Object__c playerTournamentJunctionObject = new Junction_Player_Tournament_Object__c();
                Player__c testPlayer = [Select Id From Player__c where Email__c = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
                playerTournamentJunctionObject.Player_Child__c = testPlayer.Id;
                playerTournamentJunctionObject.Tournament_child__c = ApexPages.currentPage().getParameters().get('id');    
                List<Junction_Player_Tournament_Object__c> listPlayerTournament = [Select Id From Junction_Player_Tournament_Object__c
                                                                                   WHERE Player_Child__c = :playerTournamentJunctionObject.Player_Child__c AND 
                                                                                   Tournament_child__c = :playerTournamentJunctionObject.Tournament_child__c ];
                if(listPlayerTournament.size() == 0){
                    try{
                        insert playerTournamentJunctionObject;
                         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Congratulations, now you take part Tournament. If you want to see change, pls reload your page'));
                    }
                    catch(DMLException e){}
                }
            }
             
        }
        return null;    
    }
    
    public PageReference RemoveTournamentPart(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession') !=null){
            Junction_Player_Tournament_Object__c playerTournamentJunctionObject = new Junction_Player_Tournament_Object__c();
            Player__c testPlayer = [Select Id From Player__c where Email__c = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
            playerTournamentJunctionObject.Player_Child__c = testPlayer.Id;
            playerTournamentJunctionObject.Tournament_child__c = ApexPages.currentPage().getParameters().get('id');    
            List<Junction_Player_Tournament_Object__c> listPlayerTournament = [Select Id From Junction_Player_Tournament_Object__c
                                                                               WHERE Player_Child__c = :playerTournamentJunctionObject.Player_Child__c AND 
                                                                               Tournament_child__c = :playerTournamentJunctionObject.Tournament_child__c ];
            if(listPlayerTournament.size() > 0){
                try{
                    playerTournamentJunctionObject = listPlayerTournament.get(0);
                    Database.delete(playerTournamentJunctionObject);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Now you don\'t take part at this Tournament. If you want to see change, pls reload your page'));
                }
                catch(DMLException e){}
            }
        
        }
        return null;
    }
    
    public Integer fullTournament(){
        if(getTournament().Player_type__c=='Single')return [Select Id From Junction_Player_Tournament_Object__c Tournament_child__c Where Tournament_child__c = :ApexPages.currentPage().getParameters().get('id') ].size();
        if(getTournament().Player_type__c=='Team')return [Select Count() From Team__c where tournamendID__c = :ApexPages.currentPage().getParameters().get('id')];
        return 0;
    }
    
    public List<Player__c> getAllRegisteredPlayers(){
        
        List<Player__c> currentRegisteredPlayers =[Select Id,Name, Email__c From Player__c Where Id IN (Select Player_Child__c From Junction_Player_Tournament_Object__c
                                                   Where Tournament_child__c = :ApexPages.currentPage().getParameters().get('id'))];
        if(currentRegisteredPlayers.size()>0){    
            return currentRegisteredPlayers;
        }        
        return null;
    }
    
    public List<Team__c> getAllRegisteredTeams(){
        
        List<Team__c> currentRegisteredTeams =[Select Id,Name From Team__c Where TournamendID__c = :ApexPages.currentPage().getParameters().get('id')];
        Integer thisJPTOcount = [Select Count() From Junction_Player_Team_Object__c Where Team_Child__c = :currentRegisteredTeams];
        if(currentRegisteredTeams.size()>0 && thisJPTOcount !=null && thisJPTOcount == 2){    
            return currentRegisteredTeams;
        }        
        return null;
    }
    
    public PageReference startTournament(){
        Tournament__c thisTournament = getTournament();
        List<Tournament__c> tournamentList = [Select Status__c from Tournament__c where Status__c = 'IN PROGRESS'];
        if(tournamentList.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Another tournament has already started'));
            return null;
        } 
        if(thisTournament  != null && thisTournament.Status__c !=null && thisTournament.Type_of_Elimination_Tournament__c !=null){
            thisTournament.Status__c  = 'IN PROGRESS';
    
            if(thisTournament.Type_of_Elimination_Tournament__c =='Round-robin tournament'){
                startRoundRobinTournament();
            }
            if(thisTournament.Type_of_Elimination_Tournament__c =='Single Elimination'){
                startSingleEliminationTournament();
            }/*
            if(thisTournament.Type_of_Elimination_Tournament__c =='Double Elimination'){
                startRoundRobinTournament();
            }*/        
            
            try{upsert thisTournament;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Congratulations you start this Tournament.Reload your page'));
                try{
                 System.schedule('Remember to play each games', '0 1 * * * ?', new RememberYourGames());
                } 
                catch(Exception ex){
                 System.debug('An exception occured while creating new schedule(if it exists)');  
                }
            }catch(DMLException e){}
             
            
        }
        
        return ApexPages.currentPage().setRedirect(true);
    }
    
    public void startRoundRobinTournament(){
        List<Game__c> thisGames = new List<Game__c>();
        if(getTournament() !=null && fullTournament() !=null && getTournament() !=null && getAllRegisteredPlayers() !=null && getTournament().Player_type__c !=null && getTournament().Player_type__c == 'Single'){                
            for(Integer round=0; round<fullTournament();round++){
                for(Integer match=round+1;match<fullTournament()-1;match++){
                        Game__c currentGame = new Game__c();
                        currentGame.Player_one__c = getAllRegisteredPlayers().get(round).Id ; 
                        currentGame.Player_two__c = getAllRegisteredPlayers().get(match).Id ;
                        currentGame.FirstPlayerGoals__c = 0;
                        currentGame.SecondPlayerGoals__c = 0;
                        currentGame.TournamentGame__c = getTournament().Id;
                        thisGames.add(CurrentGame);
                }
            }
        }
        try{upsert thisGames;}
        catch(DMLException e){}
    }
    
    public void startSingleEliminationTournament(){
        //additional round
        if(getTournament().Type_of_Elimination_Tournament__c == 'Single Elimination'){
            List<Game__c> thisGames = new List<Game__c>();
            Integer i = 0;
            for(Integer j = 1; j<=fullTournament(); j *=2){
                i = j;
            }
            Integer z;
            if(i == fullTournament()){z = 0;}
            else{z = 2*i-fullTournament();}
            for(Integer round=0; round<fullTournament()-z;round +=2){
                Integer match=round+1;
                Game__c currentGame = new Game__c();
                currentGame.Player_one__c = getAllRegisteredPlayers().get(round).Id ; 
                currentGame.Player_two__c = getAllRegisteredPlayers().get(match).Id ;
                currentGame.FirstPlayerGoals__c = 0;
                currentGame.SecondPlayerGoals__c = 0;
                currentGame.TournamentGame__c = getTournament().Id;           
                currentGame.Stage__c = 1;
                thisGames.add(CurrentGame);
            }
        if(i != fullTournament()){    
            Integer k = 2*i-fullTournament();
            Id freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
            for(Integer nextRound = fullTournament()-1; k>0; nextRound--){
                Game__c currentGame = new Game__c();
                currentGame.Player_one__c = getAllRegisteredPlayers().get(nextRound).Id ; 
                currentGame.Player_two__c = freeSlot;
                currentGame.FirstPlayerGoals__c = 2;
                currentGame.SecondPlayerGoals__c = 0;
                currentGame.isFPAccepted__c = true;
                currentGame.isSPAccepted__c = true;
                currentGame.Stage__c = 1;
                currentGame.TournamentGame__c = getTournament().Id;
                thisGames.add(CurrentGame);
                k--;    
            }
        }
           
        try{upsert thisGames;}
        catch(DMLException e){}       
        }
    }
     
    public PageReference finishTournament(){ 
        Tournament__c thisTournament = getTournament(); 
        thisTournament.Status__c  = 'COMPLETE';
        pagereference p = apexpages.Currentpage();
        apexpages.Message msg ;
        try{update thisTournament;
            msg = new Apexpages.Message(ApexPages.Severity.Info,'Now this tournament has already finished. If you want to see change, pls reload your page');
            }
        catch(DMLException e){
             msg = new Apexpages.Message(ApexPages.severity.ERROR,'ERROR FINISHING THIS TOURNAMENT');
            }
        apexpages.addmessage(msg);
        return p;
    }
    
    public List<Game__c> getCurrentGames(){
        return [Select Name, Player_one__c, Player_two__c,FirstPlayerGoals__c,SecondPlayerGoals__c,Stage__c, TournamentGame__c 
                                   From Game__c Where TournamentGame__c = :ApexPages.currentPage().getParameters().get('id')];
    }
    
    
    public List<List<Game__c>> makeGridOfSingleTournament(){
        Integer i = 0;//Stage count
        List<List<Game__c>> thisGames = new List<List<Game__c>>();
        if(fullTournament() !=null){
            for(Integer j =1; j<fullTournament();j*=2){
                i++;
            }
        }
        if(getCurrentGames() !=null){
            for(Integer j = 1; j<=i;j++){
                List<Game__c> stageLists = new List<Game__c>();
                for(Game__c x : getCurrentGames()){
                    if(j !=null && j == x.Stage__c.intValue()){
                        stageLists.add(x);     
                    }
                }
                thisGames.add(stageLists);    
            }
        }
        return thisGames;
    }
    public List<List<Game__c>> makeGridOfRRTournament(){
        List<List<Game__c>> thisGames = new List<List<Game__c>>();
        if(getAllRegisteredPlayers() !=null && getCurrentGames() !=null){
            for(Player__c p : getAllRegisteredPlayers()){
                List<Game__c> personalPlayerGame = new List<Game__c>();
                for(Game__c x : getCurrentGames()) 
                if(p != null && p.Id != null && p.Id == x.Player_one__c || p.Id == x.Player_two__c) thisGames.add(personalPlayerGame);
            }
        }
        return thisGames;
    }
}