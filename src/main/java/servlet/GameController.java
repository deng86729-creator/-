package servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Game;
import model.Pai;
import model.Player;
import model.Yama;

/**
 * Servlet implementation class GameController
 */
@WebServlet("/GameController")
public class GameController extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    public GameController() {super();}

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Game game = (Game) session.getAttribute("game");

        // ゲームがまだ始まっていない場合は新規作成
        if (game == null) {
            game = new Game();
            // 親（あなた、インデックス0）に初期手牌を11枚配るなどの調整が必要であればここで行う
            // ※現状、Gameクラスのコンストラクタで10枚配っている場合は、親にプラス1枚配るなどの処理を追加できます
            session.setAttribute("game", game);
        }

        // JSPへ転送
        request.getRequestDispatcher("/WEB-INF/game.jsp")
               .forward(request, response);
    }

    protected void doPost(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {

        // 文字コード
        request.setCharacterEncoding("UTF-8");

        // セッションからゲーム全体を取得
        HttpSession session = request.getSession();
        Game game = (Game) session.getAttribute("game");

        if (game == null) {
            game = new Game();
            session.setAttribute("game", game);
        }

        
        String action = request.getParameter("action"); /*どのボタンが押されたか取得*/
        Player player = game.getPlayers().get(0);  /*番のプレイヤー情報取得*/
        Player currentPlayer = game.getCurrentPlayer(); /*現在のプレイヤーを取得*/
        Yama yama = game.getYama();
        int CurrentPlayerIndex = game.getCurrentPlayerIndex(); /*誰の番？*/
	           	
        	//自分のリクエストに応じた処理を行う
	        		        	
	       	if ("pakutto".equals(action)) { /*パクッが押された*/
	       		Pai targetPai = game.getLastDiscardedPai();
	       		Player lastPlayer = game.getLastDiscardPlayer();
	
	           	// 捨てたのが自分以外で、自分がその牌を2枚持っている場合
	           	if (targetPai != null && lastPlayer != player && player.countPaiByName(targetPai.getName()) >= 2) {
	           		// 牌を手牌に加える
	           		player.addPai(targetPai);
	           		lastPlayer.pickUpKawaPai(lastPlayer.getKawa().size() - 1);
	           		player.sortTehai();
	            	// 記憶をクリア
	            	game.setLastDiscardedPai(null);
	                
	           		// ★ここで「現在のプレイヤーを自分（0）に強制的に書き換える」
	           		// （これで自分のターンになり、1枚不要な牌を捨てるフェーズに入れます）
	           		game.setCurrentPlayerIndex(0); // インデックス管理を導入している場合
	
	            	request.setAttribute("message", "「パクッ！」が成功しました！不要な牌を1枚捨ててください。");
	           	 }
	            	
	        }else if ("tsumo".equals(action) && CurrentPlayerIndex == 0) {
	        	
	             if (currentPlayer.getTehai().size() == 10) {
	            	 Pai pai = yama.draw();
	            	 if (pai != null) {
	                    currentPlayer.addPai(pai);
	                    currentPlayer.sortTehai();
	                }
	            }
	                
	        } else if ("discard".equals(action) && CurrentPlayerIndex == 0) {
	            String indexString = request.getParameter("paiIndex");
	                
	            if (indexString != null) {
	                int index = Integer.parseInt(indexString);
	                Pai discarded = currentPlayer.discardPai(index);
	                currentPlayer.sortTehai();
	
	                // 捨てた牌を記録して、次のCPUの番へ進める処理へ…
	                game.setLastDiscardedPai(discarded);
	                game.setLastDiscardPlayer(currentPlayer);
	                game.indexIncrement(); /*CurrentPlayerIndexをインクリメント*/
	                    
	                    
	            }
	        }else if ("reach".equals(action) && CurrentPlayerIndex == 0) {
	            currentPlayer.setReach(true);
	           
	            
	        } else if ("itadakimasu".equals(action) && CurrentPlayerIndex == 0) {
	            if (currentPlayer.checkAgari()) {
	                    request.setAttribute("message", "「いただきます！」見事な上がりです！おめでとうございます！");
	            }
	        }else{

		        // --- CPU（インデックス 1, 2, 3）のターンの処理 ---
		        //自模る
		     	if (currentPlayer.getTehai().size() == 10) {
	                Pai pai = yama.draw();
	                if (pai != null) {
	                    currentPlayer.addPai(pai);
	                    currentPlayer.sortTehai();
	                }
	            }
		      	//捨てる
		       	// 一番後ろの牌をそのまま捨てる（自摸切り）
	            Pai discarded = currentPlayer.discardPai(currentPlayer.getTehai().size() - 1);
	            currentPlayer.sortTehai();
	                
	            game.setLastDiscardedPai(discarded);
	            game.setLastDiscardPlayer(currentPlayer);
	            game.indexIncrement();
	        	
	    }
        
	        

        	// JSPへ戻る
        	request.getRequestDispatcher("/WEB-INF/game.jsp")
        		.forward(request, response);
        
        }
    }


