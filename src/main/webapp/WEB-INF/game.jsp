<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="model.Game" %>
<%@ page import="model.Player" %>
<%@ page import="model.Pai" %>

<%
    // セッションからGameオブジェクトを取得
    Game game = (Game) session.getAttribute("game");
    
    // まだゲームが始まっていない場合はコントローラーへ誘導（念のため）
    if (game == null) {
        response.sendRedirect("GameController");
        return;
    }

    // 操作対象のプレイヤー（ここでは便宜上インデックス0の「あなた」をメイン操作とする）
    Player player = game.getPlayers().get(0);
    int remaining = game.getYama().getRemainingCount();
%>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>弁当雀</title>
    <style>
    body {
            background-color: #f5f0e6;
            font-family: sans-serif;
            text-align: center;
        }

        .game-window {
            width: 1400px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgb(0, 64, 64);
            border: 3px solid rgb(0, 0, 0);
            border-radius: 15px;
        }

        h1 {
            color: #8b4513;
        }

        /*.player-area {
            margin-top: 20px;
            padding: 15px;
            background-color: #faf6ee;
            border: 1px solid #d2b48c;
            border-radius: 8px;
        }*/

        .tehai {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 15px;
        }

        .pai {
            width: 60px;
            height: 90px;
            background-color: #fffdf5;
            border: 2px solid #333;
            border-radius: 5px;
            display: flex;
            justify-content: center;
            align-items: center;
            writing-mode: vertical-rl;
            font-size: 16px;
            cursor: pointer;
            transition: 0.2s;
        }
        
        .pai.okazu {
            background-color: #fff5e6;
            border-color: #d2691e;
        }
        
        .pai.gohan {
            background-color: #ffffff;
            border-color: #1e90ff;
        }
        
        .pai.back {
            background-color: rgb(240, 204, 32);
            border-color: rgb(0, 0, 0);
            color: rgb(240, 204, 32);
        }
        
        .pai.selected {
            background-color: #ffe082;
            transform: translateY(-10px);
        }

        .button-area {
            margin-top: 30px;
        }

        button {
            padding: 10px 30px;
            margin: 5px;
            font-size: 18px;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .tsumo-button {
            background-color: #4682b4;
        }

        .discard-button {
            background-color: #8b4513;
        }

        button:hover {
            opacity: 0.8;
        }

        .kawa {
            margin-top: 40px;
        }

        .kawa-pai {
            display: inline-block;
            padding: 8px 12px;
            margin: 5px;
            background-color: #eee;
            border: 1px solid #999;
            border-radius: 3px;
            font-size: 14px;
        }

        .info {
            margin-top: 30px;
            font-weight: bold;
            color: #555;
        }
        /* 雀卓全体のコンテナ */
        .mahjong-table {
            display: grid;
			/*ゲーム画面を9分割する*/
            grid-template-areas:
                "left top right"
                "left center right"
                "left bottom right";
				/*3列にして左右を220px、真ん中を自由にする*/
            grid-template-columns: 220px 1fr 220px;
			/*3行にして左右をauto、真ん中を自由にする*/
            grid-template-rows: auto 1fr auto;
			/*並んだ者同士を15pxあける*/
            gap: 15px;
			/*中央揃え*/
            align-items: center;
            justify-items: center;
            margin-top: 20px;
        }

        /* 各プレイヤーの座席エリア */
        .seat-top { grid-area: top; }
        .seat-bottom { grid-area: bottom; width: 100%; }
        .seat-left { grid-area: left; }
        .seat-right { grid-area: right; }

        /* 中央の場（河や山、操作ボタンなど） */
        .table-center {
            grid-area: center;
			/* 麻雀卓らしい緑色やフェルト風 */
            background-color: rgb(0, 64, 64); 
            border: 4px solid rgb(0, 64, 64);
            border-radius: 10px;
            padding: 20px;
            width: 100%;
            min-height: 200px;
            color: rgb(0, 0, 0);
            box-sizing: border-box;
        }

        /* プレイヤーごとのミニカード枠 */
        .player-seat-box {
            background-color: rgb(0, 64, 64);
            border: 2px solid rgb(0, 64, 64);
            border-radius: 8px;
            padding: 10px;
            box-sizing: border-box;
            width: 100%;
        }

        /* 左右のプレイヤーの手牌は縦に並べるか、少しコンパクトにする場合 
        .seat-left .tehai, .seat-right .tehai {
            flex-wrap: wrap;
            max-width: 130px;
            margin: 0 auto;
        }*/
        
        /* 左右のプレイヤーの手牌エリアを縦一列にする */
        .seat-left .tehai, .seat-right .tehai {
            display: flex;
            flex-direction: column; /* 縦一列に並べる */
            align-items: center;     /* 中央揃え */
            gap: 0px;                /* 牌同士の隙間 */
            margin: 0 auto;
        }

        /* 左右のプレイヤーの牌（小さくして90度回転させる） */
        .seat-left .pai, .seat-right .pai {
            width: 50px;
            height: 35px;            /* 幅と高さを入れ替えて横長にする、または回転させる */
            font-size: 14px;
            /* writing-mode: horizontal-tb; 縦書きを横書きに戻す */
            transform: rotate(90deg);     /*90度回転（必要に応じて -90deg や調整） */
            margin: -10px 0;              /*  回転させた際の重なりを防ぐための上下余白 */
        }
        
        /* 牌のサイズ調整（CPU用は少し小さくするとスッキリします） */
        .pai.small {
            width: 35px;
            height: 55px;
            font-size: 12px;
        } 
		/* 裏向き（🀄）の場合の調整 
        .seat-left .pai.back, .seat-right .pai.back {
            transform: none;          裏向きマークは回転させない方が綺麗に見える場合もあります 
            width: 35px;
            height: 50px;
        }	*/
    </style>
</head>

<body>

<div class="game-window">

    <h1>🍱 弁当雀</h1>

    <!-- 雀卓風の配置テーブル -->
    <div class="mahjong-table">

        <!-- ① 上家（左：インデックス 3） -->
        <%
            Player pLeft = game.getPlayers().get(3);
        %>
        <div class="seat-left player-seat-box">
            <h4><%= pLeft.getName() %> <% if (pLeft.isReach()) { %><span style="color:red;">🔥</span><% } %></h4>
            <div class="tehai">
                <% for (Pai pai : pLeft.getTehai()) { %>
                    <div class="pai small back"> </div>
                <% } %>
            </div>
        </div>

        <!-- ② 対面（上：インデックス 2） -->
        <%
            Player pTop = game.getPlayers().get(2);
        %>
        <div class="seat-top player-seat-box">
            <h4><%= pTop.getName() %> <% if (pTop.isReach()) { %><span style="color:red;">🔥【リーチ】</span><% } %></h4>
            <div class="tehai">
                <% for (Pai pai : pTop.getTehai()) { %>
                    <div class="pai small back"> </div>
                <% } %>
            </div>
        </div>

        <!-- ③ 下家（右：インデックス 1） -->
        <%
            Player pRight = game.getPlayers().get(1);
        %>
        <div class="seat-right player-seat-box">
            <h4><%= pRight.getName() %> <% if (pRight.isReach()) { %><span style="color:red;">🔥</span><% } %></h4>
            <div class="tehai">
                <% for (Pai pai : pRight.getTehai()) { %>
                    <div class="pai small back"> </div>
                <% } %>
            </div>
        </div>

        <!-- ④ 中央エリア（河、山残り、各種メッセージ） -->
        <div class="table-center">
            <!--<h3>🍽️ 卓上の様子</h3>-->
            
            <!-- 河（あなたの河をここに表示する場合） -->
            <div class="kawa" style="margin-top: 10px;">
                <span style="font-size: 14px; font-weight: bold;">あなたの河：</span><br>
                <%
                    for (Pai pai : player.getKawa()) {
                        String typeClass = "okazu".equals(pai.getType()) ? "okazu" : "gohan";
                %>
					<span class="kawa-pai <%= typeClass %>" style="display: inline-flex; align-items: center; padding: 2px;">
				        <img src="images/<%= pai.getImageFileName() %>" alt="<%= pai.getName() %>" style="width: 25px; height: 35px; object-fit: contain;">
				    </span>
                <%
                    }
                %>
            </div>
			<!-- 【追加】CPU 1（右）の河 -->
			            <div class="kawa" style="margin-top: 10px;">
			                <span style="font-size: 14px; font-weight: bold;">CPU 1（右）の河：</span><br>
			                <%
			                    Player pRightKawa = game.getPlayers().get(1);
			                    for (Pai pai : pRightKawa.getKawa()) {
			                        String typeClass = "okazu".equals(pai.getType()) ? "okazu" : "gohan";
			                %>
								<span class="kawa-pai <%= typeClass %>" style="display: inline-flex; align-items: center; padding: 2px;">
							        <img src="images/<%= pai.getImageFileName() %>" alt="<%= pai.getName() %>" style="width: 25px; height: 35px; object-fit: contain;">
							    </span>
			                <%
			                    }
			                %>
			            </div>

			            <!-- 【追加】CPU 2（上）の河 -->
			            <div class="kawa" style="margin-top: 10px;">
			                <span style="font-size: 14px; font-weight: bold;">CPU 2（上）の河：</span><br>
			                <%
			                    Player pTopKawa = game.getPlayers().get(2);
			                    for (Pai pai : pTopKawa.getKawa()) {
			                        String typeClass = "okazu".equals(pai.getType()) ? "okazu" : "gohan";
			                %>
								<span class="kawa-pai <%= typeClass %>" style="display: inline-flex; align-items: center; padding: 2px;">
							        <img src="images/<%= pai.getImageFileName() %>" alt="<%= pai.getName() %>" style="width: 25px; height: 35px; object-fit: contain;">
							    </span>
			                <%
			                    }
			                %>
			            </div>

			            <!-- 【追加】CPU 3（左）の河 -->
			            <div class="kawa" style="margin-top: 10px;">
			                <span style="font-size: 14px; font-weight: bold;">CPU 3（左）の河：</span><br>
			                <%
			                    Player pLeftKawa = game.getPlayers().get(3);
			                    for (Pai pai : pLeftKawa.getKawa()) {
			                        String typeClass = "okazu".equals(pai.getType()) ? "okazu" : "gohan";
			                %>
								<span class="kawa-pai <%= typeClass %>" style="display: inline-flex; align-items: center; padding: 2px;">
							        <img src="images/<%= pai.getImageFileName() %>" alt="<%= pai.getName() %>" style="width: 25px; height: 35px; object-fit: contain;">
							    </span>
			                <%
			                    }
			                %>
			            </div>

            <div class="info" style="margin-top: 15px;">
                山の残り枚数：<%= remaining %> 枚
            </div>
            
            <% String message = (String) request.getAttribute("message"); %>
            <% if (message != null) { %>
                <div style="margin-top: 10px; font-size: 18px; color: #ffeb3b; font-weight: bold;">
                    <%= message %>
                </div>
            <% } %>
        </div>

        <!-- ⑤ 自分（下：インデックス 0）のエリア -->
        <div class="seat-bottom player-seat-box" style="border: 3px solid #8b4513; background-color: #fff;">
            <h2>
                <%= player.getName() %>の手牌
                <% if (player.isReach()) { %>
                    <span style="color: red; margin-left: 10px;">🔥【リーチ】</span>
                <% } %>
            </h2>

            <!-- フォーム（自摸、捨てる、リーチ、上がりボタン） -->
            <form action="GameController" method="post" onsubmit="return checkSubmit(event)">
                <input type="hidden" id="paiIndex" name="paiIndex" value="">

                <div class="tehai">
                    <%
                        int idx = 0;
                        for (Pai pai : player.getTehai()) {
                            String typeClass = "okazu".equals(pai.getType()) ? "okazu" : "gohan";
                    %>
                        <div class="pai <%= typeClass %>" onclick="selectPai(<%= idx %>, this)">
							<!-- 文字の代わりに画像を表示 -->
								<img src="images/<%= pai.getImageFileName() %>" 
								alt="<%= pai.getName() %>" style="width: 45px; height: 75px; object-fit: contain;">
                        </div>
                    <%
                            idx++;
                        }
                    %>
                </div>

                <div class="button-area">
                    <% if (player.getTehai().size() == 10) { %>
                        <button type="submit" name="action" value="tsumo" class="tsumo-button">自摸</button>
                    <% } %>
                    
                    <% if (player.getTehai().size() == 11) { %>
                        <button type="submit" name="action" value="discard" class="discard-button">捨てる</button>
                    <% } %>
                    
                    <% if (!player.isReach() && player.getTehai().size() == 11) { %>
                        <button type="submit" name="action" value="reach" style="background-color: #d9534f;">リーチ</button>
                    <% } %>

                    <% if (player.checkAgari()) { %>
                        <button type="submit" name="action" value="itadakimasu" 
							style="background-color: #2e7d32; font-weight: bold;">いただきます！</button>
                    <% } %>
					
					<%
					    // 直前の牌が存在し、かつ自分がその牌を2枚以上持っているかチェック
						Pai lastPai = game.getLastDiscardedPai();
					    boolean canPakutto = (lastPai != null && player.countPaiByName(lastPai.getName()) >= 2);

					    if (canPakutto) {
					%>
						<!-- 相手が捨てたタイミングで出現するパクッボタン -->
					    <form action="GameController" method="post" style="margin-top: 10px;">
					        <button type="submit" name="action" value="pakutto" style="background-color: #e67e22; color: white; font-size: 16px; padding: 10px 20px; font-weight: bold; border-radius: 5px;">
					            😋 パクッ！ (<%= lastPai.getName() %>をもらう)
					        </button>
					    </form>
					<% } %>
                </div>
            </form>
        </div>

    </div> <!-- .mahjong-table 終わり -->

</div>

    </form>
	
    <!-- 上がりメッセージの表示 -->
    <!--
    <%-- String message = (String) request.getAttribute("message"); %>
    <% if (message != null) { %>
        <div style="margin-top: 20px; font-size: 22px; color: #d9534f; font-weight: bold;">
            <%= message %>
        </div>
    <% } --%>
    -->

    <!-- 河（あなたの河） 
    <div class="kawa">
        <h2>河（かわ）</h2>
        <%
            for (Pai pai : player.getKawa()) {
                String typeClass = "okazu".equals(pai.getType()) ? "okazu" : "gohan";
        %>
            <span class="kawa-pai <%= typeClass %>">
                <%= pai.getName() %>
            </span>
        <%
            }
        %>
    </div>-->

    <!-- 山の残り枚数 
    <div class="info">
        山の残り枚数：<%= remaining %> 枚
    </div>-->

</div>

<script>
    let selectedPai = null;

    function selectPai(index, element) {
        if (selectedPai != null) {
            selectedPai.classList.remove("selected");
        }
        selectedPai = element;
        selectedPai.classList.add("selected");
        document.getElementById("paiIndex").value = index;
    }

    function checkSubmit(event) {
        const action = event.submitter ? event.submitter.value : "";
        const paiIndex = document.getElementById("paiIndex").value;

        if (action === "discard" && paiIndex === "") {
            alert("捨てる牌を選択してください！");
            return false;
        }
        return true;
    }
</script>

</body>
</html>