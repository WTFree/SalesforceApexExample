/**
 * An apex class that creates a portal user
 */
public with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    private static Id PORTAL_ACCOUNT_ID = '001x000xxx35tPN';
    
    public SiteRegisterController () {
    }

    public String playername {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirm_password {get; set { confirm_password = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
      
    private boolean isValidPassword() {
        if(password.length()<6 || confirm_password.length()<6){return false;}
        return password == confirm_password;
    }
    
    private boolean isValidPlayername(){
        return playername.length()>5;
    }
    
    public PageReference registerUser() {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
       Player__c player = new Player__c(Name__c=playername, Email__c=email);
        
       insert player;
    
       return null;
    
    }
}