public class MyTeamInvite{

    public MyTeamInvite(){
    
    }
    
    public PageReference activeThisTeam(){
        String playerCode = ApexPages.currentPage().getParameters().get('playerCode');
        String teamCode = ApexPages.currentPage().getParameters().get('teamCode');
        Integer thisJPTOcount = [Select Count() From Junction_Player_Team_Object__c Where Player_Child__c = :playerCode AND Team_Child__c = :teamCode];
        if(thisJPTOcount !=null && thisJPTOcount == 0){
            Junction_Player_Team_Object__c myTeamAtThisTournament = new Junction_Player_Team_Object__c(Player_Child__c = playerCode, Team_Child__c = teamCode);
            try{insert myTeamAtThisTournament;}
            catch(DMLException e){}
        }
        
        PageReference acctPage = new PageReference('/apex/Home');
        acctPage.setRedirect(true);
        return acctPage ;
    }
    
}