package jp_2dgames.game.state;
import flixel.ui.FlxButton;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.event.EventMgr;
import flixel.FlxG;
import flixel.FlxState;

/**
 * オープニング画面
 **/
class OpeningState extends FlxState {

  // イベント管理
  var _event:EventMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // カーソル表示
    FlxG.mouse.visible = true;

    // イベント開始
    _event = new EventMgr("assets/events/", "opening.cpp");
    this.add(_event);

    // スキップボタン
    var btn = new FlxButton(FlxG.width-88, -32, "SKIP", function() {
      FlxG.switchState(new PlayInitState());
    });
    FlxTween.tween(btn, {y:8}, 2, {ease:FlxEase.expoOut});
    this.add(btn);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    // カーソル非表示
    FlxG.mouse.visible = false;

    super.destroy();
  }

  /**
   * 更新
   **/
override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

    if(_event.isEnd()) {
      FlxG.switchState(new PlayInitState());
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
      FlxG.switchState(new OpeningState());
    }
  }
}
