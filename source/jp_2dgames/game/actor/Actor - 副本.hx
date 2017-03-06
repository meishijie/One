package jp_2dgames.game.actor;

import jp_2dgames.game.util.CauseOfDeathMgr;
import jp_2dgames.game.util.Calc;
import jp_2dgames.game.util.Key;
import jp_2dgames.game.util.DirUtil;
import jp_2dgames.game.gui.InventoryUtil;
import flixel.FlxG;
import jp_2dgames.game.particle.ParticleSmoke;
import jp_2dgames.game.item.ItemConst;
import flixel.math.FlxRandom;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.game.particle.ParticleRecovery;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.gui.Message;
import flixel.util.FlxColor;
import jp_2dgames.game.util.DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 状態
 **/
enum State {
  KeyInput;      // キー入力待ち
  InventoryOpen; // イベントリを開く
  FootMenu;      // 足下メニューを開く
  Standby;       // 待機中
  // 行動
  ActBegin; // 行動開始
  Act;      // 行動中
  ActEnd;   // 行動終了
  // 移動
  MoveBegin; // 移動開始
  Move;      // 移動中
  MoveEnd;   // 移動終了
  // ターン終了
  TurnEnd; // ターン終了
}

/**
 * 行動タイプ
 **/
enum Action {
  None;          // なし
  Standby;       // 待機中
  InventoryOpen; // インベントリを開く
  FootMenu;      // 足下メニュー
  Act;           // 攻撃
  ActExec;       // 攻撃実行中
  Move;          // 移動
  MoveExec;      // 移動実行中
  TurnEnd;       // ターン終了
}

/**
 * 共通キャラクタークラス
 **/
class Actor extends FlxSprite {

  // 1マス進むのにかかるフレーム数
  private static inline var TIMER_WALK:Int = 12;
  // ダメージアニメーションのフレーム数
  private static inline var TIMER_DAMAGE:Int = 8;
  // バッドステータスが有効なターン数
  private static inline var BADSTATUS_TURN:Int           = 10; // 基本は10ターン有効
  private static inline var BADSTATUS_TURN_PARALYSIS:Int = 3; //  麻痺は3ターンのみ
  private static inline var BADSTATUS_TURN_POISON:Int    = 6; //  毒は6ターンのみ
  private static inline var BADSTATUS_TURN_CONFUSION:Int = 5; //  混乱は5ターンのみ
  // 毒で減るHPの割合
  private static inline var DAMAGE_POISON:Int = 5; // 5%

  // 次のフロアへワープすると判定する座標
  public static inline var WARP_NEXT_FLOOR_POS:Int = -1; // (-1, -1)に存在したら次のフロアへワープ

  // 状態
  private var _state:State;
  private var _stateprev:State; // 1つ前の状態
  private var _tMove:Int = 0;
  // 向き
  private var _dir:Dir = Dir.Down;
  // アニメーション状態
  private var _bStop = true;
  // ダメージ揺らし用のタイマー
  private var _tShake:Int = 0;
  // 移動元座標
  private var _xprev:Float = 0;
  private var _yprev:Float = 0;
  // 移動先座標
  private var _xnext:Float = 0;
  private var _ynext:Float = 0;
  // 行動先座標
  private var _xtarget:Int = 0;
  private var _ytarget:Int = 0;
  // ステータスパラメータ
  private var _params:Params;
  // 拡張パラメータ (一時的なパラメータの増減値)
  private var _extParams:Params;
  // ID
  private var _id:Int = 1;
  // 名前
  private var _name:String = "";
  // バッドステータス
  private var _badstatus:BadStatus = BadStatus.None;
  // 早歩き
  private var _bRun:Bool = false;

  // プロパティ
  // チップ座標(X)
  public var xchip(get_xchip, never):Int;
  private function get_xchip() {
    return Std.int(_xnext);
  }
  // チップ座標(Y)
  public var ychip(get_ychip, never):Int;

  private function get_ychip() {
    return Std.int(_ynext);
  }
  // 方向
  public var dir(get_dir, never):Dir;
  private function get_dir() {
    return _dir;
  }
  // ID
  public var id(get_id, never):Int;

  private function get_id() {
    return _id;
  }
  // プレイヤーかどうか
  public function isPlayer():Bool {
    return id == 0;
  }
  // パラメータ
  public var params(get_params, never):Params;
  private function get_params() {
    return _params;
  }
  // 拡張パラメータ
  public var extParams(get, never):Params;
  private function get_extParams() {
    return _extParams;
  }
  // 名前
  public var name(get_name, never):String;

  private function get_name() {
    return _name;
  }
  // 行動タイプ
  public var action(get_action, never):Action;

  private function get_action() {
    switch(_state) {
      case State.Standby:
        return Action.Standby; // 待機中
      case State.KeyInput:
        return Action.Standby; // 待機中
      case State.InventoryOpen:
        return Action.InventoryOpen; // イベントリを開く
      case State.FootMenu:
        return Action.FootMenu; // 足下メニューを開く
      case State.ActBegin:
        return Action.Act; // 攻撃開始
      case State.Act:
        return Action.ActExec; // 攻撃実行中
      case State.MoveBegin:
        return Action.Move; // 移動開始
      case State.Move:
        return Action.MoveExec; // 移動中
      case State.TurnEnd:
        return Action.TurnEnd; // ターン終了
      default:
        // 通常はここにこない
        trace('error: ${_state}');
        return Action.None;
    }
  }

  // 死亡チェック
  public function isDead():Bool {
    return params.hp <= 0;
  }

  // HP(0〜100%で返す)
  public var hpratio(get, never):Float;
  private function get_hpratio() {
//    return 100 * _params.hp / getHpMax();
    return 100 * _params.hp / getHpMax();
  }

  /**
   * HPを最大HPに丸める
   **/
  public function trancateHp():Void {
    if(_params.hp > getHpMax()) {
      _params.hp = getHpMax();
    }
  }

  public function addHp(val:Int, bEffect=true):Void {
    _params.hp += val;
    if(_params.hp > getHpMax()) {
      _params.hp = getHpMax();
    }

    if(bEffect) {
      // エフェクト再生開始
      ParticleRecovery.start(x, y-height/2, val);
    }
  }

  public function addHp2(val:Int, bEffect=true):Int {
    // パーセンテージで回復
    var val2 = getHpMax() * val / 100;
    if(val2 < 1) {
      val2 = 1;
    }
    addHp(Std.int(val2), bEffect);
    return Std.int(val2);
  }

  public function subHp(val:Int):Bool {
    _params.hp -= val;
    if(_params.hp <= 0) {
      // 死亡
      _params.hp = 0;
      return true;
    }
    // まだ生きている
    return false;
  }
  // 最大HP
  public function addHpMax(val:Int):Void {
    _params.hpmax += val;
  }

  public function subHpMax(val:Int):Void {
    _params.hpmax -= val;
    if(_params.hp < getHpMax()) {
      _params.hp = getHpMax();
    }
  }

  public function getHpMax():Int {
    return _params.hpmax + _extParams.hpmax;
  }

  /**
   * 毒ダメージの値を取得する
   **/
  public function getPoisonDamage():Int {
    var v = getHpMax() * DAMAGE_POISON / 100;
    if(v < 1) {
      v = 1;
    }
    return Std.int(v);
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    if(hpratio < 30) {
      // 30%以下は危険状態
      return true;
    }
    if(params.hp <= 15) {
      // 15以下になっても危険
      return true;
    }

    return false;
  }

  // 満腹度
  public var food(get, null):Int;

  private function get_food() {
    // 満腹度は100倍
    // 端数切り上げ
    return Std.int(Math.ceil(_params.food / 100));
  }

  // 空腹状態かどうか
  public function isHunger():Bool {
    return _params.food <= 0;
  }

  public function addFood(ratio:Float):Void {
    _params.food += Std.int(ratio * 100);
    if(_params.food > _params.foodmax) {
      _params.food = _params.foodmax;
    }
  }
  public function addFood2(ratio:Float):Int {
    var val = Std.int(foodmax * ratio / 100);
    addFood(val);
    return val;
  }

  public function subFood(ratio:Float):Bool {
    _params.food -= Std.int(ratio * 100);
    if(_params.food < 0) {
      // 空腹状態
      _params.food = 0;
      return true;
    }
    // まだ満腹度は残っている
    return false;
  }
  // 最大満腹度
  public var foodmax(get, null):Int;
  private function get_foodmax() {
    // 最大満腹度は100倍
    return Std.int(_params.foodmax / 100);
  }

  // 満腹かどうか
  public function isFoodMax():Bool {
    return _params.food == _params.foodmax;
  }

  public function addFoodMax(ratio:Float):Void {
    _params.foodmax += Std.int(ratio * 100);
  }

  public function subFoodMax(ratio:Float):Void {
    _params.foodmax -= Std.int(ratio * 100);
    if(_params.foodmax < _params.food) {
      _params.food = _params.foodmax;
    }
  }

  // 経験値
  public function addExp(exp:Int):Void {
    _params.exp += exp;
  }

  // 力上昇
  public function addStr(val:Int):Void {
    _params.str += val;
  }
  public function getStr():Int {
    return _params.str + _extParams.str;
  }
  public function getVit():Int {
    return _params.vit + _extParams.vit;
  }

  // 指定した方向を向く
  public function look(i:Int, j:Int):Void {
    _dir = DirUtil.look(_xprev, _yprev, i, j);
  }

  public var badstatus(get, never):BadStatus;
  private function get_badstatus() {
    return _badstatus;
  }

  /**
   * バッドステータスを設定する
   * @param stt 変化するステータス
   * @param bSilent 変化してもメッセージやSEを再生しない
   **/
  public function changeBadStatus(stt:BadStatus, bSilent:Bool=false):Bool {

    if(_badstatus == BadStatus.Star) {
      if(_params.badstatus_turn > 0) {
        // 無敵状態なので状態変化しない
        Message.push2(Msg.NOTHING_HAPPENED);
        return false;
      }
    }
    if(isPlayer()) {
      var check = function() {
        var extra = InventoryUtil.getRingExtra();
        switch(stt) {
          case BadStatus.Sleep:
            return extra == "sleep";
          case BadStatus.Confusion:
            return extra == "confusion";
          default:
        }
        // 防げない
        return false;
      };
      if(check()) {
        // 無効化した
        return false;
      }
    }

    _badstatus = stt;
    params.badstatus = BadStatusUtil.toString(stt);
    var turn:Int = 0;
    switch(stt) {
      case BadStatus.None: turn = 0;
      case BadStatus.Paralysis: turn = BADSTATUS_TURN_PARALYSIS;
      case BadStatus.Poison:    turn = BADSTATUS_TURN_POISON;
      case BadStatus.Confusion: turn = BADSTATUS_TURN_CONFUSION;
      default: turn = BADSTATUS_TURN;
    }

    // 有効ターン数設定
    _params.badstatus_turn = turn;
    _balloon.show(stt);

    var msgid = 0;
    switch(stt) {
      case BadStatus.Poison: msgid = Msg.BAD_POISON;
      case BadStatus.Star: msgid = Msg.BAD_STAR;
      case BadStatus.Sleep: msgid = Msg.BAD_SLEEP;
      case BadStatus.Anger: msgid = Msg.BAD_ANGER;
      case BadStatus.Confusion: msgid = Msg.BAD_CONFUSION;
      case BadStatus.Paralysis: msgid = Msg.BAD_PARALYSIS;
      case BadStatus.Powerful: msgid = Msg.BAD_POWERFUL;
      case BadStatus.Sickness: msgid = Msg.BAD_SICKNESS;
      case BadStatus.Closed:
        if(isPlayer()) {
          msgid = Msg.BAD_CLOSED_PLAYER;
        }
        else {
          msgid = Msg.BAD_CLOSED_ENEMY;
        }
      case BadStatus.None:
    }
    if(msgid > 0 && bSilent == false) {
      // バッドステータスになった
      Message.push2(msgid, [name]);
      Snd.playSe("badstatus", true);
    }

    return true;
  }
  // バッドステータスを回復する
  public function cureBadStatus() {
    Snd.playSe("recover", true);
    changeBadStatus(BadStatus.None);
  }
  // バッドステータスアイコン
  private var _balloon:ActorBalloon;
  public var balloon(get, never):ActorBalloon;
  private function get_balloon() {
    return _balloon;
  }

  /**
	 * コンストラクタ
	 **/
  public function new() {
    super();

    // バッドステータスアイコン
    _balloon = new ActorBalloon();
  }

  /**
   * 消滅
   **/
  override public function kill() {
    // バッドステータスアイコンを消しておく
    _balloon.show(BadStatus.None);
    super.kill();
  }

  /**
	 * 初期化
	 **/
  public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool = false):Void {

    // 座標を設定
    setPositionChip(X, Y);

    _state = State.KeyInput;
    _stateprev = _state;
    _tMove = 0;
    // 向き
    _dir = dir;
    // ステータス
    _params = params;
    // 拡張パラメータ
    _extParams = new Params();
    // ID
    _id = params.id;
    // バッドステータス設定
    var bSilent = true;
    changeBadStatus(BadStatusUtil.fromString(_params.badstatus), bSilent);
  }

  /**
   * 座標を設定する
   **/
  public function setPositionChip(X:Int, Y:Int):Void {
    var px = Std.int(X);
    var py = Std.int(Y);
    _xprev = px;
    _yprev = py;
    _xnext = px;
    _ynext = py;
    var px2 = Field.toWorldX(X);
    var py2 = Field.toWorldY(Y);
    super.setPosition(px2, py2);
  }

  // 行動開始する
  public function beginAction():Void {
    switch(_state) {
      case State.ActBegin:
        _change(State.Act);
      case State.TurnEnd:
      // 何もしない
      default:
        trace('error:${_state}');
    }
  }
  // 移動開始する
  public function beginMove():Void {
    switch(_state) {
      case State.MoveBegin:
        _change(State.Move);
      case State.TurnEnd:
      // 何もしない
      default:
        trace('error:${_state}');
    }
  }

  // 何もせずターンを終了する
  public function standby():Void {
    _change(Actor.State.TurnEnd);
  }

  // ターン終了しているかどうか
  public function isTurnEnd():Bool {
    return _state == State.TurnEnd;
  }
  // ターン終了
  public function turnEnd():Void {
    // バッドステータスターン数経過
    if(_badstatus != BadStatus.None) {
      _params.badstatus_turn--;
      if(_params.badstatus_turn <= 0) {
        // バッドステータス治癒
        cureBadStatus();
      }
    }
    _change(State.KeyInput);
  }
  // 指定の座標に存在するかどうかをチェックする
  public function existsPosition(xc:Int, yc:Int):Bool {
    if(xc == xchip && yc == ychip) {
      // 座標が一致
      return true;
    }
    // 一致しない
    return false;
  }
  // 状態遷移
  private function _change(next:State):Void {
    _stateprev = _state;
    _state = next;
  }
  // 状態を1つ前に戻す
  public function changeprev():Void {
    var prev = _state;
    _state = _stateprev;
    _stateprev = prev;
  }

  /**
	 * 更新
	 **/
override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
    if(_tShake > 0) {
      _tShake--;
      var ox = width / 2;
      ox += (_tShake % 4 < 2 ? _tShake : -_tShake) * 2;
      offset.set(ox, height / 2);
    }
    // バルーン座標更新
    if(_balloon.alive) {
      _balloon.x = x;
      _balloon.y = y - height + _balloon.height/2;
    }
  }

  public function proc():Void {
    // サブクラスで実装する
  }

  /**
	 * 更新・歩く
	 **/
  private function _updateWalk():Bool {
    // 経過フレームの割合を求める
    var tWait:Int = TIMER_WALK;
    if(_bRun) {
      // 早歩き
      tWait = Std.int(tWait / 3);
    }

    _tMove++;
    var t = _tMove / tWait;
    // 移動方向を求める
    var dx = _xnext - _xprev;
    var dy = _ynext - _yprev;
    // 座標を線形補間する
    x = Field.toWorldX(_xprev) + (dx * Field.GRID_SIZE) * t;
    y = Field.toWorldY(_yprev) + (dy * Field.GRID_SIZE) * t;
    if(_tMove >= tWait) {
      // 移動完了
      _bRun = false;
      _xprev = _xnext;
      _yprev = _ynext;
      return true;
    }
    else {
      // 移動中
      return false;
    }
  }

  /**
   * 座標を調整する
   **/
  public function adjustPosition():Void {
    x = Field.toWorldX(xchip);
    y = Field.toWorldY(ychip);
  }

  /**
	 * ダメージを与える
	 **/
  public function damage(val:Int):Bool {
    _tShake = TIMER_DAMAGE;

    var px = Field.toWorldX(xchip);
    var py = Field.toWorldY(ychip);
    if(_badstatus == BadStatus.Star) {
      // 無敵状態なのでダメージを受けない
      Particle.start(PType.Circle, px, py, FlxColor.RED);
      ParticleDamage.start(px, py, 0);
      return false;
    }

    if(isPlayer()) {
      // プレイヤーダメージ
      Message.push2(Msg.PLAYER_DAMAGE, [name, val]);
      Snd.playSe("hit", true);
    }
    else {
      // 敵ダメージ
      Message.push2(Msg.ENEMY_DAMAGE, [name, val]);
      Snd.playSe("hit", true);
    }

    if(_badstatus == BadStatus.Sleep) {
      // 睡眠状態だったら通常状態に戻る
      cureBadStatus();
      // ターン終了にする
      _change(Actor.State.TurnEnd);
    }

    Particle.start(PType.Circle, px, py, FlxColor.RED);
    var p = ParticleDamage.start(px, py, val);
    p.color = 0xFFFFC0C0;

    if(subHp(val)) {
      // 死亡
      return true;
    }

    // 生きている
    return false;
  }

  /**
   * アイテムをぶつける
   * @param actor アイテムを投げた人
   * @param item ぶつけるアイテム
   * @param bAlwaysHit 必中フラグ
   * @return 当たったら true / 外れたら false
   **/
  public function hitItem(actor:Actor, item:ItemData, bAlwaysHit=false):Bool {

    if(bAlwaysHit == false) {
      if(Calc.checkHitThrow(this) == false) {
        // 外した
        return false;
      }
    }

    if(damage(100)) {
      // 倒した
      Message.push2(Msg.ENEMY_DEFEAT, [name]);
      // 経験値獲得
      actor.addExp(params.xp);
      // エフェクト再生
      Particle.start(PType.Ring, x, y, FlxColor.YELLOW);

      kill();
    }

    return true;
  }

  /**
   * ぶつけたアイテムの効果発動
   * @return ぶつけたアイテムで倒したかどうか
   **/
  public function hitItemEffect(actor:Actor, item:ItemData, bPlayer:Bool, armor:ItemData):Bool {

    CauseOfDeathMgr.set(DeathType.EnemyAtk, actor.id);

    // 拡張パラメータ
    var extra = ItemUtil.getParamString(item.id, "extra");
    var extval = ItemUtil.getParam(item.id, "extval");

    switch(item.type) {
      case IType.Potion:
        var val = ItemUtil.getParam(item.id, "hp");
        if(val > 0) {
          // HP回復
          addHp(val);
          Message.push2(Msg.RECOVER_HP, [name, val]);
          return false;
        }
        else if(val < 0) {
          // ダメージ
          return damage(-val);
        }
        if(extra != "") {
          switch(extra) {
            case "hpmax", "food", "str", "powerful":
              // ダメージ
              return damage(FlxRandom.intRanged(1, 3));
            default:
              // 特殊効果あり
              ItemUtil.useExtra(this, extra, extval);
          }
        }
        return false;

      case IType.Weapon:
        // 武器はダメージ量が少しだけ多い
        var v = FlxRandom.intRanged(8, 12);
        return damage(v);
      case IType.Food:
        // リンゴは飛び道具として使える
        var v = FlxRandom.intRanged(5, 7);
        v += ItemUtil.getParam(item.id, "atk");
        switch(extra) {
          case "poison":
            // 毒状態になる
            changeBadStatus(BadStatus.Poison);
        }
        return damage(v);

      case IType.Wand:
        if(extra != "") {
          ItemUtil.useExtra(this, extra, extval, actor);
        }
        else {
          var v = Calc.damageItem(this, item, armor);
          return damage(v);
        }
        return false;

      case IType.Orb:
        switch(item.id) {
          case ItemConst.ORB1:
            // 赤オーブ
            return damage(9999);
          default:
            // それ以外は微量ダメージ
            var v = FlxRandom.intRanged(5, 7);
            return damage(v);
        }

      default:
        // それ以外は微量のダメージ
        var v = FlxRandom.intRanged(5, 7);
        return damage(v);
    }
  }

  /**
   * ワープする
   **/
  public function warp(X:Int, Y:Int, bMsg:Bool):Void {
    setPositionChip(X, Y);
    // ワープエフェクト再生
    ParticleSmoke.start("warp", x, y);
    Snd.playSe("warp", true);

    if(bMsg) {
      // ワープメッセージ表示
      Message.push2(Msg.WARP, [name]);
    }
  }

  // 次のフロアへワープする
  public function warpNextFloor(bMsg:Bool):Void {
    warp(WARP_NEXT_FLOOR_POS, WARP_NEXT_FLOOR_POS, bMsg);
  }

  // 次のフロアへワープするかどうか
  public function isWarpNextFloor():Bool {
    return xchip == WARP_NEXT_FLOOR_POS && ychip == WARP_NEXT_FLOOR_POS;
  }

  /**
   * スパイクダメージ
   **/
  public function damageSpike():Bool {
    var v = Std.int(getHpMax() * 0.3);
    if(v < 1) {
      v = 1;
    }
    CauseOfDeathMgr.set(DeathType.Spike, 0);
    return damage(v);
  }

  /**
   * 敵を倒した
   **/
  public function effectDestroyEnemy():Void {
    Message.push2(Msg.ENEMY_DEFEAT, [name]);
    // ドロップアイテム
    checkDropItem();
    kill();
    FlxG.sound.play("destroy");
    // 経験値獲得
    ExpMgr.add(params.xp);
    // エフェクト再生
    Particle.start(PType.Ring, x, y, FlxColor.YELLOW);
  }

  /**
   * ドロップアイテムの出現チェック
   **/
  public function checkDropItem():Void {
    // 派生クラスで実装する
  }
}
