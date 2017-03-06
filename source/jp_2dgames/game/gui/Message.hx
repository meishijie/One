package jp_2dgames.game.gui;
import jp_2dgames.game.util.MyColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * メッセージ定数
 **/
class Msg {
  public static inline var PLAYER_DAMAGE:Int = 1; // プレイヤーダメージ
  public static inline var ENEMY_DAMAGE:Int = 2; // 敵ダメージ
  public static inline var ENEMY_DEFEAT:Int = 3; // 敵を倒した
  public static inline var ITEM_DISCARD:Int = 4; // アイテムを捨てた
  public static inline var ITEM_EAT:Int = 5; // アイテムを食べた
  public static inline var ITEM_EQUIP:Int = 6; // アイテムを装備した
  public static inline var ITEM_UNEQUIP:Int = 7; // アイテムを外した
  public static inline var ITEM_PICKUP:Int = 8; // アイテムを拾った
  public static inline var MISS:Int = 9; // 攻撃を外した
  public static inline var LEVELUP:Int = 10; // レベルアップした
  public static inline var LEVELUP2:Int = 11; // レベル数値を表示
  public static inline var ITEM_FULL:Int = 12; // アイテムがいっぱい
  public static inline var ITEM_STEPON:Int = 13; // アイテムの上に乗る
  public static inline var ITEM_PUT:Int = 14; // アイテムを床に置いた
  public static inline var INVENTORY_CANT_OPEN:Int = 15; // インベントリを開けない
  public static inline var ITEM_DESTORY:Int = 16; // アイテムが壊れた
  public static inline var ITEM_HIT_WALL:Int = 17; // アイテムが壁に当たった
  public static inline var ITEM_THROW:Int = 18; // アイテムを投げた
  public static inline var RECOVER_HP:Int = 19; // HP回復
  public static inline var ITEM_DRINK:Int = 20; // アイテムを飲んだ
  public static inline var RECOVER_FOOD_MAX:Int = 21; // 満腹度が最大まで回復した
  public static inline var RECOVER_FOOD:Int = 22; // 満腹度が最大まで回復した
  public static inline var ITEM_SCROLL:Int = 23; // 巻物を読んだ
  public static inline var GROW_HPMAX:Int = 24; // 最大HP上昇
  public static inline var GROW_FOOD:Int = 25; // 最大満腹度上昇
  public static inline var GROW_STR:Int = 26; // 力上昇
  public static inline var BAD_CONFUSION:Int = 27; // 混乱
  public static inline var BAD_SLEEP:Int = 28; // 眠り
  public static inline var BAD_PARALYSIS:Int = 29; // 麻痺
  public static inline var BAD_SICKNESS:Int = 30; // 病気
  public static inline var BAD_POWERFUL:Int = 31; // 元気いっぱい
  public static inline var BAD_ANGER:Int = 32; // 怒り
  public static inline var BAD_POISON:Int = 33; // 毒
  public static inline var ITEM_WAND:Int = 34; // 杖を振った
  public static inline var NOTHING_HAPPENED:Int = 35; // 何も起こらなかった
  public static inline var BAD_CURE:Int = 36; // 正常に戻った
  public static inline var SHOP_SELL:Int = 37; // アイテム売却
  public static inline var SHOP_BUY:Int = 38; // アイテム購入
  public static inline var SHOP_SHORT_OF_MONEY:Int = 39; // お金が足りない
  public static inline var SHOP_ITEM_FULL:Int = 40; // アイテムが一杯で買えない
  public static inline var ITEM_ORB:Int = 41; // オーブを使った
  public static inline var ITEM_REVIVE:Int = 42; // アイテムの力で復活
  public static inline var BAD_STAR:Int = 43; // 無敵状態になった
  public static inline var BAD_CLOSED_PLAYER:Int = 44; // 封印状態になった（プレイヤー）
  public static inline var BAD_CLOSED_ENEMY:Int = 45; // 封印状態になった（敵）
  public static inline var ITEM_LIMIT_ADD:Int = 46; // アイテム所持上限が上昇した
  public static inline var WEAPON_ADD:Int = 47; // 武器を強化
  public static inline var ARMOR_ADD:Int = 48; // 防具を強化
  public static inline var HP_SWAP:Int = 49; // HPを交換
  public static inline var ITEM_GET:Int = 50; // アイテム獲得
  public static inline var WARP:Int = 51; // ワープした
  public static inline var POSITION_CHANGE:Int = 52; // お互いの位置を入れ替え
  public static inline var RECOVER_HPMAX:Int = 53; // HPが最大まで回復
  public static inline var NIGHTMARE_DELAY:Int = 54; // ナイトメアの出現を遅延させた
  public static inline var ITEM_CANT_USE:Int = 55; // アイテムが使えない
  public static inline var CANT_USE_ORB_BLUE:Int = 56; // 青オーブは使えない

}

/**
 * メッセージウィンドウ用のテキスト
 **/
class MessageText extends FlxText {

  private var _ofsY:Float = 0;
  public function setOfsY(ofsY:Float) {
    _ofsY = ofsY;
  }
  private var _baseY:Float = 0;

  private var _bg:FlxSprite;
  public var bg(get, never):FlxSprite;
  private function get_bg() {
    return _bg;
  }

  public function new(X:Float, Y:Float, Width:Float) {
    super(X, Y, Width);
    setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    // アウトラインをつける
    setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
    color = FlxColor.WHITE;
    // じわじわ表示
    alpha = 0;
    FlxTween.tween(this, {alpha:1}, 0.3, {ease:FlxEase.sineOut});
    // スライド表示
    var xnext = x;
    x += 64;
    FlxTween.tween(this, {x:xnext}, 0.3, {ease:FlxEase.expoOut});
    // 消滅判定
    new FlxTimer().start(5, function(t:FlxTimer) {
      // じわじわ消す
      FlxTween.tween(this, {_baseY:-8}, 0.3, {ease:FlxEase.sineOut});
      FlxTween.tween(this, {alpha:0}, 0.3, {ease:FlxEase.sineOut, onComplete:function(tween:FlxTween) {
        kill();
      }});
    });

    // 背景作成
    _bg = new FlxSprite(X-8, Y+4, "assets/images/ui/messagetext.png");
    _bg.alpha = 0;
    _bg.color = MyColor.MESSAGE_WINDOW;
  }

  /**
   * 更新
   **/
override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    y = _baseY + _ofsY;
    _bg.y = y + 4;
    _bg.alpha = alpha*0.5;
  }
}

/**
 * メッセージウィンドウ
 **/
class Message extends FlxGroup {

  // メッセージログの最大
  private static inline var MESSAGE_MAX = 5;
  // ウィンドウ座標
  private static inline var POS_X = 8;
  private static inline var POS_Y = 480 - HEIGHT - 24 - 8;
  private static inline var POS_Y2 = 24 + 8;
  // ウィンドウサイズ
  private static inline var WIDTH = 640 - 8 * 2;
  private static inline var HEIGHT = (MESSAGE_MAX*DY)+14;
  private static inline var MSG_POS_X = 8;
  private static inline var MSG_POS_Y = 8;
  // メッセージ表示間隔
  private static inline var DY = 24;

  // ウィンドウが消えるまでの時間 (5sec)
  private static inline var TIMER_DISAPPEAR:Float = 5;

  // インスタンス
  public static var instance:Message = null;

  // メッセージの追加
  public static function push(msg:String, color:Int=FlxColor.WHITE) {
    Message.instance._push(msg, color);
  }

  public static function push2(msgId:Int, args:Array<Dynamic>=null) {
    if(Message.instance != null) {
      Message.instance._push2(msgId, args);
    }
  }

  // ヒントメッセージの追加
  public static function pushHint() {
    return Message.instance._pushHint();
  }

  // メッセージの取得
  public static function getText(msgId:Int):String {
    return Message.instance._getText(msgId);
  }

  // メッセージウィンドウを消す
  public static function hide() {
    Message.instance.visible = false;
  }

  // ウィンドウの色を変える
  public static function setWindowColor(color:Int):Void {
    Message.instance._window.color = color;
  }

  private var _window:FlxSprite;
  private var _msgList:List<MessageText>;

  // ウィンドウを下に表示しているかどうか
  private var _bDispBottom:Bool = true;
  public static function isDispBottom():Bool {
    return instance._bDispBottom;
  }

  // ウィンドウが消えるまでの時間
  private var _timer:Float;

  // メッセージCSV
  private var _csv:CsvLoader;
  // ヒントメッセージCSV
  private var _csvHint:CsvLoader;

  // テキストのオフセット座標
  private var _txtOfsY:Float = 0;
  // 上下切り替えのオフセット座標
  private var _txtOfsY2:Float = 0;

  /**
	 * コンストラクタ
	 **/

  public function new(csv:CsvLoader, csvHint:CsvLoader) {
    super();
    // 背景枠
    _window = new FlxSprite(POS_X, POS_Y, "assets/images/ui/message.png");
    _window.color = MyColor.MESSAGE_WINDOW;
//    this.add(_window);
    _msgList = new List<MessageText>();

    // CSVメッセージ
    _csv = csv;
    _csvHint = csvHint;

    // 非表示
    visible = false;
  }

  private var ofsY(get_ofsY, never):Float;

  private function get_ofsY() {
    var player = cast(FlxG.state, PlayState).player;
    var y = (player.ychip) * 32;

    if(y > POS_Y - 1 * 32) {
      // 上にする
      if(_bDispBottom) {
        // 下から上に変わった
        _txtOfsY2 = -DY * MESSAGE_MAX;
      }
      _bDispBottom = false;
      return POS_Y2;
    }

    if(y < POS_Y2 + 5 * 32) {
      // 下にする
      if(_bDispBottom == false) {
        // 上から下に変わった
        _txtOfsY2 = DY * MESSAGE_MAX;
      }
      _bDispBottom = true;
      return POS_Y;
    }

    if(_bDispBottom) {
      return POS_Y;
    }
    else {
      return POS_Y2;
    }
  }

  /**
	 * 更新
	 **/
override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    _txtOfsY *= 0.9;
    _txtOfsY2 *= 0.9;

    for(text in _msgList) {
      if(text.alive == false) {
        pop();
        _txtOfsY += DY;
      }
    }

    // 座標更新
    _window.y = ofsY;
    _updateTextPosition();
  }

  private function _updateTextPosition():Void {
    var idx = 0;
    for(text in _msgList) {
      // 描画基準座標
      var offsetY = ofsY + MSG_POS_Y;
      // テキストごとのオフセット
      offsetY += idx * DY;
      // 上下切り替えによるオフセット
      offsetY += _txtOfsY2;
      // テキスト消去によるオフセット
      offsetY += _txtOfsY;
      text.setOfsY(offsetY);
      idx++;
    }
  }

  /**
	 * メッセージを末尾に追加
	 **/
  private function _push(msg:String, color:Int,elapsed:Float=1.0) {
    var text = new MessageText(POS_X + MSG_POS_X, 0, WIDTH);
    text.text = msg;
    text.color = color;
    if(_msgList.length >= MESSAGE_MAX) {
      // 最大を超えたので先頭のメッセージを削除
      pop();
    }
    _msgList.add(text);

    // 座標を更新
    _updateTextPosition();
    for(txt in _msgList) {
      txt.update(elapsed);
    }
    this.add(text.bg);
    this.add(text);

    // 表示する
    visible = true;
    _timer = TIMER_DISAPPEAR;
  }

  private function _push2(msgId:Int, args:Array<Dynamic>):Void {
    var msg = _csv.getString(msgId, "msg");
    var color = MyColor.strToColor(_csv.getString(msgId, "color"));
    if(args != null) {
      var idx:Int = 1;
      for(val in args) {
        msg = StringTools.replace(msg, '<val${idx}>', '${val}');
        idx++;
      }
    }
    _push(msg, color);
  }

  /**
   * メッセージを取得する
   * @param msgId メッセージID
   * @return メッセージ
   **/
  private function _getText(msgId:Int):String {
    return _csv.searchItem("id", '${msgId}', "msg");
  }

  /**
   * ヒントメッセージを表示する
   **/
  private function _pushHint():Void {
    // フロア番号がメッセージIDとなる
    var floor = Global.getFloor();
    var msg = _csvHint.searchItem("id", '${floor}', "msg");
    push(msg);
  }

  /**
	 * 先頭のメッセージを削除
	 **/
  public function pop() {
    var t = _msgList.pop();
    this.remove(t.bg);
    this.remove(t);
  }
}
