package model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Player {

    private String name;
    
    //手牌
    private List<Pai> tehai;
    
    //河
    private List<Pai> kawa;

    public Player(String name) {
        this.name = name;
        
        tehai = new ArrayList<>();
        kawa = new ArrayList<>();
    }

    // 手牌に牌を追加
    public void addPai(Pai pai) {
        tehai.add(pai);
    }
    
    // Playerクラスの中に以下を追加・変更します

    // 手牌を種類や名前で綺麗に並べ替えるメソッド
    public void sortTehai() {
        // 例：Paiのタイプ（おかず／ごはん）と名前で比較して並び替える
        Collections.sort(tehai, new Comparator<Pai>() {
            @Override
            public int compare(Pai p1, Pai p2) {
                // まず「おかず」と「ごはん」で分ける場合
                if (!p1.getType().equals(p2.getType())) {
                    return p1.getType().compareTo(p2.getType());
                }
                // 同じタイプなら名前の文字コード順で隣にまとめる
                return p1.getName().compareTo(p2.getName());
            }
        });
    }
    
    
    // 指定した位置の牌を捨てる
    public Pai discardPai(int index) {

        if (index < 0 || index >= tehai.size()) {
            return null;
        }

        Pai pai = tehai.remove(index);

        // 河に追加
        kawa.add(pai);

        return pai;
        
    }
    
    public void pickUpKawaPai (int index) {
    	kawa.remove(index);
    }
    
    
    
    // 【追加】指定した名前の牌が手牌に何枚あるか数える
    public int countPaiByName(String name) {
        int count = 0;
        for (Pai p : tehai) {
            if (p.getName().equals(name)) {
                count++;
            }
        }
        return count;
    }
    
    
    // Playerクラスに追加するメソッド
    public boolean checkAgari() {
    	
        // 手牌が11枚（ツモった状態）でない場合は上がりではない
        if (tehai.size() != 11) {
            return false;
        }
        
        // 牌の名前ごとの枚数をカウントするマップ
        Map<String, Integer> countMap = new HashMap<>();
        // 牌の名前とタイプ（おかず/ごはん）を紐付けるマップ
        Map<String, String> typeMap = new HashMap<>();

        for (Pai pai : tehai) {
            String name = pai.getName();
            countMap.put(name, countMap.getOrDefault(name, 0) + 1);
            typeMap.put(name, pai.getType());
        }

        int okazuSets = 0;   // 3枚揃った「おかず」の組数
        int gohanPairs = 0;  // 2枚揃った「ごはん」の組数（頭）

        // 集計結果をチェック
        for (Map.Entry<String, Integer> entry : countMap.entrySet()) {
            String name = entry.getKey();
            int count = entry.getValue();
            String type = typeMap.get(name);

            if ("okazu".equals(type)) {
                // おかずは3枚で1組
                if (count == 3) {
                    okazuSets++;
                    
                } else {
                    // 3枚以外の半端な枚数がある場合は不成立
                    return false;
                }
            } else if ("gohan".equals(type)) {
                // ごはんは2枚で1組（頭）
                if (count == 2) {
                    gohanPairs++;
                } else {
                    // 2枚以外（1枚や3枚など）がある場合は不成立
                    return false;
                }
            }
        }

        // 「おかず3組」かつ「ごはん1組」であれば上がり！
        return (okazuSets == 3 && gohanPairs == 1);
    }
    
 // Player.java に追加
    private boolean isReach = false;

    public boolean isReach() {
        return isReach;
    }

    public void setReach(boolean isReach) {
        this.isReach = isReach;
    }
    
    public String getName() {
        return name;
    }

    public List<Pai> getTehai() {
        return tehai;
    }
    
    public List<Pai> getKawa() {
        return kawa;
    }
}

