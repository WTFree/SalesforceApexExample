global class RememberYourGames implements schedulable{
     global void execute(SchedulableContext ctx) {
         DateTime dt = DateTime.now();
         dt = dt.addDays(-1);
         
         List<Game__c> myGameList =  [SELECT Id, CreatedDate,Player_one__c, Player_two__c  FROM Game__c 
                                      WHERE SecondPlayerGoals__c = 0 AND FirstPlayerGoals__c = 0 AND CreatedDate < :dt];
         Set<Id> myIds = new Set<Id>();
         for(Game__c x : myGameList){
             myIds.add(x.Player_one__c);
             myIds.add(x.Player_two__c);
         }
         List<Player__c> thisPlayers = [Select Email__c From Player__c Where Id =:myIds];
         sendPlayYourGamesEmail(thisPlayers);
     }
     
     public void sendPlayYourGamesEmail(List<Player__c> allPlayerEmails){
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