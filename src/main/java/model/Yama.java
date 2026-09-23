package model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Yama {

    private List<Pai> pais;

    public Yama() {
        pais = new ArrayList<>();

        createPais();
        shuffle();
    }
    
    

    // 88枚の牌を作る
    private void createPais() {

        // おかず10種類
        String[] okazu = {
            "唐揚げ",
            "焼き魚",
            "卵焼き",
            "ハンバーグ",
            "エビフライ",
            "ウインナー",
            "コロッケ",
            "とんかつ",
            "餃子",
            "シュウマイ",
           
        };

        // おかずはそれぞれ10枚
        for (String name : okazu) {
            for (int i = 0; i < 10; i++) {
                pais.add(new Pai(name, "okazu"));
            }
        }

        // ごはん5種類
        String[] gohan = {
            "白米",
            "赤飯",
            "炊き込みご飯",
            "チャーハン",
            "おにぎり",
            
        };

        // ごはんもそれぞれ4枚
        for (String name : gohan) {
            for (int i = 0; i < 4; i++) {
                pais.add(new Pai(name, "gohan"));
            }
        }
    }

    // 山をシャッフル
    void shuffle() {
        Collections.shuffle(pais);
    }

    // 山から牌を1枚取る
    public Pai draw() {

        if (pais.isEmpty()) {
            return null;
        }

        return pais.remove(0);
    }

    // 残り枚数
    public int getRemainingCount() {
        return pais.size();
    }
}

