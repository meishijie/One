package jp_2dgames.game.event;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

/**
 * イベント管理
 **/
class EventMgr extends FlxSpriteGroup {

  // NPCの最大数
  public static var NPC_MAX:Int = 32;

  // イベントスクリプト
  private var _script:EventScript;

  /**
   * コンストラクタ
   * @param directory イベントリソースのルートディレクトリ
   * @param script スクリプトファイル名
   **/
  public function new(directory:String, script:String) {
    super();

    // スクリプト生成
    _script = new EventScript(directory, script);
    this.add(_script);

    // NPC生成
    
	var m1 = new FlxTypedGroup<EventNpc>(NPC_MAX);
    //EventNpc.parent = new FlxTypedGroup<EventNpc>(NPC_MAX);
    for(i in 0...m1.maxSize) {
      var npc = new EventNpc();
      // ユニークIDを設定
      npc.ID = 1000 + i;
      this.add(npc);
      m1.add(npc);
    }

    // UI登録
    this.add(_script.ui);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    EventNpc.parent = null;
    EventNpc.isCollision = null;
    super.destroy();
  }

  /**
   * 更新
   **/
override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
    _script.proc();
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _script.isEnd();
  }
}
