public class sendSimpleConfirmRegistrationEmailClass{
    
   public void sendAnEmail(List<Player__c> p) {
       String name =p.get(0).Name;
       String email=p.get(0).email__c;
       String uID= p.get(0).Id;
       Messaging.reserveSingleEmailCapacity(2);
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {email}; 
       String[] ccAddresses = new String[] {'vitaly.gaiduchok@gmail.com'};
       mail.setToAddresses(toAddresses);
   } 
   
}