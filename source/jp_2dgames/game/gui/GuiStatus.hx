package jp_2dgames.game.gui;
import jp_2dgames.game.util.MyColor;
import jp_2dgames.game.util.DirUtil;
import jp_2dgames.game.state.PlayState;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import jp_2dgames.game.actor.Enemy;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.game.gui.Message.Msg;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * ステータス表示
 **/
class GuiStatus extends FlxGroup {

  /**
   * ヘルプモード
   **/
  public static inline var HELP_NONE:Int = 0; // 非表示
  public static inline var HELP_KEYINPUT:Int = 1; // 通常移動
  public static inline var HELP_INVENTORY:Int = 2; // インベントリ
  public static inline var HELP_DIALOG_YN:Int = 3; // Yes/Noダイアログ
  public static inline var HELP_INVENTORYCOMMAND:Int = 4; // インベントリ・コマンド
  public static inline var HELP_SHOP_SELL:Int = 5; // ショップ・売却
  public static inline var HELP_SHOP_BUY:Int = 6; // ショップ・購入

  // ステータス表示座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 4;

  private static inline var BG_W = 640;
  private static inline var BG_H = 24;

  // Y調整
  private static inline var MERGIN_Y = 2;

  // バーのサイズ
  private static inline var BAR_W = 180;
  private static inline var BAR_H = 4;

  // フロア数
  private static inline var FLOORTEXT_X = 24;
  private static inline var FLOORTEXT_Y = 0;
  // レベルテキスト
  private static inline var LVTEXT_X = FLOORTEXT_X + 32;
  private static inline var LVTEXT_Y = 0;
  // 所持金
  private static inline var MONEYTEXT_X = FOODTEXT_X + 80;
  private static inline var MONEYTEXT_Y = 0;
  // 所持金（増分）
  private static inline var MONEYTEXT_ADD_Y = 16;
  // HPテキスト
  private static inline var HPTEXT_X = LVTEXT_X + 64;
  private static inline var HPTEXT_Y = 0 - MERGIN_Y;
  // HPバー
  private static inline var HPBAR_X = HPTEXT_X;
  private static inline var HPBAR_Y = 16;
  // 満腹度
  private static inline var FOODTEXT_X = HPBAR_X + 192;
  private static inline var FOODTEXT_Y = 0;
  // スコア
  private static inline var SCORE_X = MONEYTEXT_X + 96;
  private static inline var SCORE_Y = 0;
  // ヘルプテキスト
  private static inline var HELP_X = 16;
  private static inline var HELP_DY = 24;

  // タイマー
  // 危険タイマー
  private var _tDanger:Int = 0;
  private var _tDangerFood:Int = 0;

  // ステータスGUI
  private var _group:FlxSpriteGroup;
  private var _groupOfsY:Float = 0;
  private var _bgStatus:FlxSprite;
  private var _txtLv:FlxText;
  private var _txtFloor:FlxText;
  private var _txtHp:FlxText;
  private var _hpBar:FlxBar;
  private var _txtFood:FlxText;
  private var _txtMoney:FlxText;
  private var _txtScore:FlxText;
  private var _txtMoneyAdd:FlxText;

  // お金増分演出用
  private var _prevMoney:Int = 0; // 前回のお金
  private var _tMoneyAdd:Int = 0; // 前回のお金との差分がなくなったフレーム数

  // 敵情報
  private var _enemyInfo:GuiEnemy;
  // ナイトメア出現ターン数
  private var _nightmareInfo:GuiNightmare;

  // ヘルプ
  private var _help:FlxSpriteGroup;
  private var _bgHelp:FlxSprite;
  private var _txtHelp:FlxText;
  private var _helpY:Float;
  private var _helpOfsY:Float = 0;
  private var _helpMode:Int = HELP_NONE;
  public var helpmode(get, never):Int;
  private function get_helpmode() {
    return _helpMode;
  }

  /**
	 * コンストラクタ
	 **/
  public function new() {
    super();

    _groupOfsY = -BG_H;
    _group = new FlxSpriteGroup();

    // 背景
    _bgStatus = new FlxSprite(0, 0).makeGraphic(BG_W, BG_H, FlxColor.WHITE);
    _bgStatus.color = FlxColor.BLACK;
    _bgStatus.alpha = 0.7;
    _group.add(_bgStatus);

    // フロアテキスト
    _txtFloor = new FlxText(FLOORTEXT_X, FLOORTEXT_Y, 128);
    _txtFloor.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _group.add(_txtFloor);

    // レベルテキスト
    _txtLv = new FlxText(LVTEXT_X, LVTEXT_Y, 128);
    _txtLv.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _group.add(_txtLv);

    // HPバー
    _hpBar = new FlxBar(HPBAR_X, HPBAR_Y, FlxBarFillDirection.LEFT_TO_RIGHT, BAR_W, BAR_H);
    _hpBar.createFilledBar(FlxColor.RED, FlxColor.RED);
    _group.add(_hpBar);

    // HPテキスト
    _txtHp = new FlxText(HPTEXT_X, HPTEXT_Y, 180);
    _txtHp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _group.add(_txtHp);

    // 満腹度テキスト
    _txtFood = new FlxText(FOODTEXT_X, FOODTEXT_Y, 160);
    _txtFood.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _group.add(_txtFood);

    // 所持金テキスト
    _txtMoney = new FlxText(MONEYTEXT_X, MONEYTEXT_Y, 128);
    _txtMoney.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txtMoney.alignment = "right";
    _group.add(_txtMoney);

    // 所持金テキスト（増分）
    _txtMoneyAdd = new FlxText(MONEYTEXT_X, MONEYTEXT_ADD_Y, 128);
    _txtMoneyAdd.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txtMoneyAdd.alignment = "right";
    _group.add(_txtMoneyAdd);

    // スコアテキスト
    _txtScore = new FlxText(SCORE_X, SCORE_Y, 128);
    _txtScore.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txtScore.alignment = "right";
    _group.add(_txtScore);

    // 画面上のグループ登録
    this.add(_group);

    // ■敵情報
    _enemyInfo = new GuiEnemy();
    this.add(_enemyInfo);

    // ■ナイトメア情報
    _nightmareInfo = new GuiNightmare();
    this.add(_nightmareInfo);

    // ■ヘルプ
    _help = new FlxSpriteGroup();
    // ヘルプ座標(Y)
    _helpY = FlxG.height - HELP_DY;
    // ヘルプの背景
    _bgHelp = new FlxSprite(0, 0).makeGraphic(BG_W, HELP_DY, FlxColor.WHITE);
    _bgHelp.color = FlxColor.BLACK;
    _bgHelp.alpha = 0.7;
    _help.add(_bgHelp);
    // ヘルプテキスト
    _txtHelp = new FlxText(HELP_X, 0, 640);
    _txtHelp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _help.add(_txtHelp);
    this.add(_help);

    // ヘルプテキスト設定
    changeHelp(HELP_KEYINPUT);
  }

  /**
	 * 更新
	 **/
override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // フロア数
    var floor = Global.getFloor();
    _txtFloor.text = '${floor}F';

    var player = cast(FlxG.state, PlayState).player;
    var lv = player.params.lv;
    // レベル
    _txtLv.text = 'LV:${lv}';

    // HP
    var hp = player.params.hp;
    var hpmax = player.getHpMax();
    _txtHp.text = 'HP: ${hp}/${hpmax}';
    _hpBar.percent = 100 * hp / hpmax;

    // 満腹度
    var full = player.food;
    var fullmax = player.foodmax;
    _txtFood.text = '满腹度: ${full}/${fullmax}';

    // 所持金
    var money = Global.getMoney();
    _txtMoney.text = '${money}G';
    var moneyadd = Global.getMoneyAdd();
    if(_prevMoney != moneyadd) {
      // 数値が変わった
      // 差分を表示開始
      var str = '(${moneyadd})';
      if(moneyadd > 0) {
        str = '(+${moneyadd})';
      }
      _txtMoneyAdd.text = str;
      _tMoneyAdd = 120;
    }
    else {
      if(_tMoneyAdd > 0) {
        // 差分表示点滅中
        _tMoneyAdd--;
        _txtMoneyAdd.visible = true;
        if(_tMoneyAdd < 30 && _tMoneyAdd%4 < 2) {
          _txtMoneyAdd.visible = false;
        }
      }
    }
    _prevMoney = moneyadd;

    // スコア
    var score = Global.getScore();
    _txtScore.text = '${score}pt';

    // 表示アニメーション
    _groupOfsY *= 0.8;
    _group.y = _groupOfsY + MERGIN_Y;

    // ヘルプテキストのアニメーション
    {
      if(_helpOfsY > 0) {
        _helpOfsY *= 0.9;
      }
      _help.y = _helpY + _helpOfsY;
    }

    // 危険判定
    {
      // HP
      if(player.isDanger()) {
        _txtHp.color = FlxColor.PINK;
        _tDanger++;
        var step = Std.int(Math.sin(FlxAngle.TO_RAD * (_tDanger%180)) * 100);
        var color = FlxColor.interpolate(MyColor.MESSAGE_WINDOW, FlxColor.BROWN, 100);
        _bgStatus.color = color;
        _bgHelp.color = color;
        Message.setWindowColor(color);
      }
      else {
        _txtHp.color = FlxColor.WHITE;
        _bgStatus.color = FlxColor.BLACK;
        _bgHelp.color = FlxColor.BLACK;
        Message.setWindowColor(MyColor.MESSAGE_WINDOW);
      }
    }
    {
      // 満腹度
      var ratio = player.food;
      if(ratio <= 0) {
        _tDangerFood++;
        var color = FlxColor.WHITE;
        if(_tDangerFood%64 < 32) {
          color = FlxColor.RED;
        }
        _txtFood.color = color;
      }
      else {
        _txtFood.color = FlxColor.WHITE;
      }
    }
  }

  /**
   * 敵の情報を表示するかどうかチェックする
   **/
  public function checkEnemyInfo() {
    var player = cast(FlxG.state, PlayState).player;
    if(player.existsEnemyInFront()) {
      // 表示する
      var enemy:Enemy = null;
      var pt = FlxPoint.get(player.xchip, player.ychip);
      pt = DirUtil.move(player.dir, pt);
      Enemy.parent.forEachAlive(function(e:Enemy) {
        if(e.existsPosition(Std.int(pt.x), Std.int(pt.y))) {
          enemy = e;
        }
      });
      pt.put();
      _enemyInfo.setEnemy(enemy);
    }
    else {
      // 表示しない
      _enemyInfo.setEnemy(null);
    }
  }

  /**
   * ヘルプの表示を変更する
   **/
  public function changeHelp(mode:Int) {
    if(_helpMode == mode) {
      // 変更不要
      return;
    }

    _helpMode = mode;
    var text = "";
    switch(_helpMode) {
      case HELP_NONE:
        // 非表示
      case HELP_KEYINPUT:
        text = UIText.getText(UIText.HELP_KEYINPUT);
      case HELP_INVENTORY:
        text = UIText.getText(UIText.HELP_INVENCTORY);
      case HELP_DIALOG_YN:
        text = UIText.getText(UIText.HELP_DIALOG);
      case HELP_INVENTORYCOMMAND:
        text = UIText.getText(UIText.HELP_INVENCTORYCOMMAND);
      case HELP_SHOP_SELL:
        text = UIText.getText(UIText.HELP_SHOP_SELL);
      case HELP_SHOP_BUY:
        text = UIText.getText(UIText.HELP_SHOP_BUY);
    }

    _txtHelp.text = text;
    _help.y = FlxG.height;

    // アニメーション開始
    _helpOfsY = HELP_DY*1.5;
  }
}
