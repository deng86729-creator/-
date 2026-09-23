package model;

public class Pai {

    // 牌の種類
    private String name;

    // おかず牌か、ごはん牌か
    private String type;

    public Pai(String name, String type) {
        this.name = name;
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }
 // 【追加】牌の名前から画像ファイルのパスを返すメソッド
    public String getImageFileName() {
        switch (name) {
            case "唐揚げ": return "karaage.png";
            case "焼き魚": return "yakizakana.png";
            case "卵焼き": return "tamagoyaki.png";
            case "ハンバーグ": return "hamburg.png";
            case "エビフライ": return "ebifurai.png";
            case "ウインナー": return "winer.png";
            case "コロッケ": return "korokke.png";
            case "とんかつ": return "tonkatsu.png";
            case "餃子": return "gyoza.png";
            case "シュウマイ": return "shumai.png";
            case "白米": return "hakumai.png";
            case "赤飯": return "sekihan.png";
            case "炊き込みご飯": return "takikomi.png";
            case "チャーハン": return "chahan.png";
            case "おにぎり": return "onigiri.png";
            case "お寿司": return "sushi.png";
            case "ふりかけご飯": return "furikake.png";
            default: return "default.png";
        }
    }

}

