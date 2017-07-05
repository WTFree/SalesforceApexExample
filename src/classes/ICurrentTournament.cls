public interface ICurrentTournament{
    Tournament__c getTournament();
    PageReference takeTournamentPart();
    boolean isRegisteredForTournir();
    PageReference RemoveTournamentPart();
    PageReference startTournament();
    void startRoundRobinTournament();
    PageReference finishTournament();
    List<Game__c> getCurrentGames();
    List<Player__c> getAllRegisteredPlayers();
    Integer fullTournament();
}