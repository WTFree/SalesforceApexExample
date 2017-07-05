trigger sendSimpleConfirmRegistrationEmailTrigger on Player__c (after insert) {
    sendSimpleConfirmRegistrationEmailClass executor = new sendSimpleConfirmRegistrationEmailClass();  
    executor.sendAnEmail(Trigger.new);
}