package jp_2dgames.game.state;
import jp_2dgames.game.save.GameData;
import jp_2dgames.game.unlock.UnlockMgr;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import jp_2dgames.game.event.EventMgr;
import flixel.FlxG;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState{

  var _event:EventMgr;
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // カーソル表示
    FlxG.mouse.visible = true;

    // スクリプト生成
    _event = new EventMgr("assets/events/", "ending.cpp");
    this.add(_event);

    // スキップボタン
    var btn = new FlxButton(FlxG.width-88, -32, "SKIP", function() {
      // リザルトに進む
      FlxG.switchState(new ResultState());
    });
    FlxTween.tween(btn, {y:8}, 2, {ease:FlxEase.expoOut});
    this.add(btn);

    // アンロックチェック
    this.add(UnlockMgr.createInstance());
    if(Global.isGameClear()) {
      trace(Global.getFloor());
      if(Global.getFloor() > Global.FLOOR_MAX) {
        // 全踏破
        UnlockMgr.check("floor_all", 0);
      }
      else {
        // オーブを4つ集めた
        UnlockMgr.check("orb", 4);
      }
    }
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    // カーソル非表示
    FlxG.mouse.visible = false;

    // アンロック管理を破棄
    UnlockMgr.destroyInstance();

    super.destroy();
  }

  /**
   * 更新
   **/
override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

    if(_event.isEnd()) {
      // リザルトに進む
      FlxG.switchState(new ResultState());
    }

    // デバッグ処理
#if debug
    updateDebug();
#end
  }

  private function updateDebug():Void {
#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end

    // デバッグ処理
    if(FlxG.keys.justPressed.R) {
      FlxG.switchState(new EndingState());
    }
  }
}
