public class CurrentGame{
    
    public boolean writeResultThisMatch{get;set;}
    public boolean allowForAcceptPlayerOne{get;set;} 
    public boolean allowForAcceptPlayerTwo{get;set;} 
    public boolean getStatusPlayer{get;set;}//can remove, but problem on site side, c.eu11... all ok. But on side from site problem need to fix
    
    public Tournament__c currentTournament{
        get{
            if (currentTournament == null)
                currentTournament= new Tournament__c();
                return currentTournament;
        }
        set;
    }
    public Game__c currentGame{
        get {
            if (currentGame == null)
                currentGame = new Game__c();
                return currentGame;
            }
        set;
    }
    public Player__c currentPlayer {
        get {
            if (currentPlayer == null)
                currentPlayer = new Player__c();
                return currentPlayer ;
            }
        set;
    }
    public Player__c playerOne {
        get {
            if (playerOne == null)
                playerOne = new Player__c();
                return playerOne ;
            }
        set;
    }
    public Player__c playerTwo {
        get {
            if (playerTwo == null)
                playerTwo = new Player__c();
                return playerTwo ;
            }
        set;
    }    
    
    public CurrentGame(){
        currentGame = getCurrentGame();
        currentTournament = getCurrentTournament();
        if(ApexPages.currentPage().getCookies().get('PlayerSession') !=null){
            allowForAcceptPlayerOne = getAllowsForCurrentPlayerOne();
            allowForAcceptPlayerTwo = getAllowsForCurrentPlayerTwo();
            currentPlayer = getCurrentPlayer();
            writeResultThisMatch = getAllowsForCurrentPlayer();
            playerOne = getCurrentPlayerOne(); 
            playerTwo = getCurrentPlayerTwo();
            getStatusPlayer = currentPlayer.isModerator__c;
        }
    }
    
    public Tournament__c getCurrentTournament(){
        List<Tournament__c> thisTournament = [Select Id, Name, Status__c, Type_of_Elimination_Tournament__c, Player_Type__c From Tournament__c 
                                              Where Id IN (Select TournamentGame__c From Game__c
                                              Where Id= :ApexPages.currentPage().getParameters().get('id'))];
       if(thisTournament.size()>0){
           return thisTournament.get(0);
       }return null;
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
    public Player__c getCurrentPlayerOne(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null)
        return [Select Id, Name From Player__c
                Where Id IN (Select Player_one__c From Game__c
                Where Id= :ApexPages.currentPage().getParameters().get('id'))];
        return new Player__c();
   }
    public Player__c getCurrentPlayerTwo(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null)
        return [Select Id, Name From Player__c
                Where Id IN (Select Player_two__c From Game__c
                Where Id= :ApexPages.currentPage().getParameters().get('id'))];
        return new Player__c();
   }
    
    public void submitResult(){
        if(getAllowsForCurrentPlayer()||getCurrentPlayer().isModerator__c){
            acceptResult();
            try{update(currentGame);}
            catch(DMLException E){} 
            createNextSingleEliminationStage();        
        }
    }
    
    public void createNextSingleEliminationStage(){
        if(getCurrentTournament().Type_of_Elimination_Tournament__c =='Single Elimination' && getCurrentTournament().Player_type__c =='Single'&&
            ApexPages.currentPage().getParameters().get('id')!=null && ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null){
            Boolean allGamesAlreadyFinished;
            Integer i = [Select Count() From Game__c Where TournamentGame__c = :currentTournament.Id AND 
                         (FirstPlayerGoals__c=0 AND isSPAccepted__c = false) AND (SecondPlayerGoals__c=0 AND isFPAccepted__c = false)];
            if(i!=null && i==0 ) allGamesAlreadyFinished = true;
            if(getCurrentGame()!=null && allGamesAlreadyFinished!=null && allGamesAlreadyFinished){
                Decimal thisGameStage = getCurrentGame().Stage__c;
                List<Game__c> thisGames = [Select Id,Player_one__c,Player_two__c,FirstPlayerGoals__c,SecondPlayerGoals__c From Game__c Where TournamentGame__c = :currentTournament.Id And Stage__c = :thisGameStage];
                List<Game__c> nextRoundGames = new List<Game__c>();
                List<Id> playersWinnersId = new List<Id>();
                for(Game__c x : thisGames){
                    if(x.FirstPlayerGoals__c > x.SecondPlayerGoals__c) {playersWinnersId.add(x.Player_one__c);}
                    else{playersWinnersId.add(x.Player_two__c);}
                }
                List<Player__c> playerWinners = [Select Id, Name, Email__c From Player__c Where Id = :playersWinnersId];
                thisGameStage++;
                Id freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                for(Integer round=0; round<=playerWinners.size()-1;round +=2){
                    Integer match=round+1;
                    Game__c currentGame = new Game__c();
                    currentGame.Player_one__c = playerWinners.get(round).Id;
                    currentGame.FirstPlayerGoals__c = 0;
                    currentGame.SecondPlayerGoals__c = 0;
                    currentGame.Stage__c = thisGameStage;
                    currentGame.TournamentGame__c = currentTournament.Id;
                    if(match < playerWinners.size()){
                        currentGame.Player_two__c = playerWinners.get(match).Id ;
                    }else{currentGame.Player_two__c = freeSlot;
                              try{currentTournament.Status__c = 'COMPLETE';
                                  upsert currentTournament;}
                              catch(DMLException ex){}
                              break;}
                    nextRoundGames.add(currentGame);
                }
                if(nextRoundGames !=null && nextRoundGames.size()>0){
                    try{upsert nextRoundGames;}
                    catch(DMLException e){}
                }
            }     
        }
    }
       
    public void acceptResult(){
        if(getAllowsForCurrentPlayer()||getCurrentPlayer().isModerator__c){
            if(getAllowsForCurrentPlayerOne() && currentGame.isFPAccepted__c == false) currentGame.isFPAccepted__c = true;  
            if(getAllowsForCurrentPlayerTwo() && currentGame.isSPAccepted__c == false) currentGame.isSPAccepted__c = true;  
            try{update(currentGame);}
            catch(DMLException E){}     
        }
    }
    public void moderatorAcceptResult(){
        if(getCurrentPlayer().isModerator__c){
            currentGame.isFPAccepted__c = true;  
            currentGame.isSPAccepted__c = true;  
            try{update(currentGame);}
            catch(DMLException E){}     
        }
    }
    public void declineResult(){
        if(getAllowsForCurrentPlayer()||getCurrentPlayer().isModerator__c){
            if(getAllowsForCurrentPlayerOne() && currentGame.isFPAccepted__c == true) currentGame.isFPAccepted__c = false;  
            if(getAllowsForCurrentPlayerTwo() && currentGame.isSPAccepted__c == true) currentGame.isSPAccepted__c = false;
            currentGame.FirstPlayerGoals__c = 0;
            currentGame.SecondPlayerGoals__c = 0;
            try{upsert(currentGame);}
            catch(DMLException E){}     
        }
    }
    public void moderatorDeclineResult(){
        if(getCurrentPlayer().isModerator__c){
            currentGame.isFPAccepted__c = false;  
            currentGame.isSPAccepted__c = false;
            currentGame.FirstPlayerGoals__c = 0;
            currentGame.SecondPlayerGoals__c = 0;
            try{upsert(currentGame);}
            catch(DMLException E){}     
        }
    }
    public boolean getAllowsForCurrentPlayer(){
       if(getAllowsForCurrentPlayerOne() || getAllowsForCurrentPlayerTwo())return true;
       return false;
    }
    public boolean getAllowsForCurrentPlayerOne(){
       if(getCurrentPlayer().Id== getCurrentPlayerOne().Id)return true;
       return false;
    }
    public boolean getAllowsForCurrentPlayerTwo(){
       if(getCurrentPlayer().Id== getCurrentPlayerTwo().Id)return true;
       return false;
    }

}