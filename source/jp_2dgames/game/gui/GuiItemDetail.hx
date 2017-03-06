package jp_2dgames.game.gui;
import jp_2dgames.game.util.MyColor;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * アイテム表示・詳細
 **/
class GuiItemDetail extends FlxSpriteGroup {
  // 背景の枠
  private static inline var BG_WIDTH = 200;
  private static inline var BG_HEIGHT = 100;

  // テキストの幅
  private static inline var TXT_WIDTH = BG_WIDTH;

  private static inline var MSG_X = 8;
  private static inline var MSG_Y = 8;

  // テキスト
  private var _txt:FlxText; // Str

  private var _orgY:Float = 0;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    _orgY = Y;
    super(X, Y);

    // 背景
    var back = new FlxSprite(0, 0, "assets/images/ui/window200x100.png");
    back.color = MyColor.DETAIL_FRAME;
    this.add(back);

    // 説明文テキスト
    _txt = new FlxText(MSG_X, MSG_Y, TXT_WIDTH-16);
    _txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txt);
  }

  private function _updateText(item:ItemData):Void {

    _txt.text = ItemUtil.getDetail(item);
  }

  /**
   * 更新
   **/
override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }

  /**
   * 表示する
   **/
  public function show(item:ItemData) {
    _updateText(item);
  }

  /**
   * 選択中のアイテムを設定する
   **/
  public function setSelectedItem(item:ItemData) {
    _updateText(item);
  }
}
