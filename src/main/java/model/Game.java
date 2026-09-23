package model;

import java.util.ArrayList;
import java.util.List;

public class Game {
	private Yama yama;
	private List<Player> players;
	private int currentPlayerIndex = 0;
	private Pai lastDiscardedPai = null;
	private Player lastDiscardPlayer = null;

	public Game() {
        yama = new Yama();
        /*yama.shuffle();*/

        players = new ArrayList<>();
        players.add(new Player("プレイヤー（あなた）"));
        players.add(new Player("CPU 1"));
        players.add(new Player("CPU 2"));
        players.add(new Player("CPU 3"));

        

        // 各プレイヤーに初期手牌を配る（例：10枚ずつ）
        for (Player player : players) {
            for (int i = 0; i < 10; i++) {
                Pai pai = yama.draw();
                if (pai != null) {
                    player.addPai(pai);
                }
            }
        }
        for (Player player : players) {
        	player.sortTehai();
        	player.checkAgari();
        }
        
    }
	
	public void indexIncrement() {
		currentPlayerIndex = (currentPlayerIndex + 1)%4;
	}
	

    public Yama getYama() {
        return yama;
    }

    public List<Player> getPlayers() {
        return players;
    }

    public Player getCurrentPlayer() {
        return players.get(currentPlayerIndex);
    }
    
    public int getCurrentPlayerIndex() {return currentPlayerIndex;}
    public void setCurrentPlayerIndex(int currentPlayerIndex) {this.currentPlayerIndex = currentPlayerIndex;}
    
    public Pai getLastDiscardedPai() {return lastDiscardedPai;}
    public void setLastDiscardedPai(Pai lastDiscardedPai) {this.lastDiscardedPai = lastDiscardedPai;}
    
    public Player getLastDiscardPlayer() { return lastDiscardPlayer; }
    public void setLastDiscardPlayer(Player player) { this.lastDiscardPlayer = player; }
}
