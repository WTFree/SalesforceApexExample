global class RegistrationControll implements schedulable{
     global void execute(SchedulableContext ctx) {
     DateTime dt = DateTime.now();
     dt = dt.addDays(-1);
        delete [SELECT Id, CreatedDate FROM Player__c 
            WHERE Status__c = 'wait for active' AND CreatedDate < :dt];
     }
}