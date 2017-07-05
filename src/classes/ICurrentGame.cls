public interface ICurrentGame{
    void submitResult();
    void createNextSingleEliminationStage();
    void acceptResult();
    void moderatorAcceptResult();
    void declineResult();
    void moderatorDeclineResult();
    boolean getAllowsForCurrentPlayer();
    boolean getAllowsForCurrentPlayerOne();
    boolean getAllowsForCurrentPlayerTwo();
}