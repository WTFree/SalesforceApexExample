public class ConfirmController{
    
    public PageReference confirmRegistration(){
        String code = ApexPages.currentPage().getParameters().get('code');
        String url = ApexPages.currentPage().getURL(); 
        List<Player__c> playersId = [Select Id from Player__c 
                                     where Id = :code  Limit 1];
        
        if(playersId.get(0) != null){
            playersId.get(0).Status__c = 'active';
            update playersId.get(0);
        }
        else{
            return Page.Exception;
        }
        
        return Page.Home;
    }

}