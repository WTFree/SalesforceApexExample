public with sharing class PlayerCreateController{
    
  // the contact record you are adding values to
  public boolean checkCookie { get; set; }   
  public Cookie playerCookie { get; set; }
  public Player__c player {
    get {
      if (player == null)
        player = new Player__c();
      return player;
    }
    set;
  }

  public PlayerCreateController() {
        playerCookie= ApexPages.currentPage().getCookies().get('PlayerSession');
         if(playerCookie != null){
             checkCookie=true;
         }else{checkCookie = false;} 
  }
  
  public boolean isValidPassword(){
      return player.Password__c == player.Confirm_Password__c;
  }
  
   // save button is clicked
  public PageReference save() {
    if(isValidPassword() && player.Password__c != null && player.Confirm_Password__c !=null){
    try {
      insert player;// inserts the new record into the database
      //send an email
      try{
          System.schedule('Deleting player if status will not be Active', '0 1 * * * ?', new RegistrationControll());
      } 
      catch(Exception ex){
          System.debug('An exception occured while creating new schedule(if it exists)');  
      }
      sendEmail();
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new player.'));
      return null;
    }}
    else{
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Write down correct password'));
      return null;
    }    
    return Page.PlayerCreateThankyou;
  }
  

    public void sendEmail(){
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[] {player.Email__c};
        String[] ccAddresses = new String[] {'vitaly.gaiduchok@gmail.com'};

        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);

     
        mail.setSenderDisplayName('Submit your email address');

        mail.setSubject('Submit your email address');

        mail.setBccSender(false);

        mail.setUseSignature(false);

        mail.setPlainTextBody('Test');

        mail.setHtmlBody('Your player:<b> ' + player.Id +' </b>has been created.<p>'+
                'To activate your player account <a href="http://gaiduchokttt-developer-edition.eu11.force.com/registration?code=' + player.Id + '">Click here</a>');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  
 }