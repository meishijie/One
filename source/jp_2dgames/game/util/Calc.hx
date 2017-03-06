package jp_2dgames.game.util;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import Math;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.Actor;
import flixel.math.FlxRandom;
import flixel.FlxG;
/**
 * 各種計算式
 **/
class Calc {

  // 最大ダメージ
  private static inline var MAX_DAMAGE:Int = 9999;

  // 基本攻撃力
  private static inline var BASE_ATK:Int = 2;

  /**
	 * ダメージ計算
	 * @param act1 攻撃する人
	 * @param act2 攻撃される人
	 * @param item1 act1の装備アイテム
	 * @param item2 act2の装備アイテム
	 **/
  public static function damage(act1:Actor, act2:Actor, item1:ItemData, item2:ItemData):Int {
    // 力
    var str = act1.getStr();
    if(act1.badstatus == BadStatus.Anger) {
      // 怒り状態は攻撃力1.5倍
      str = Std.int(str * 1.5);
    }
    // 耐久力
    var vit = act2.getVit();
    // 攻撃力
    var atk = 0;
    if(item1 != null) {
      // 攻撃力を取得
      atk = ItemUtil.getParam(item1.id, "atk");
      atk += item1.param.value;
    }
    // 防御力
    var def = 0;
    if(item2 != null) {
      // 防御力を取得
      def = ItemUtil.getParam(item2.id, "def");
      def += item2.param.value;
    }

    // 威力
    var power = str + (atk * 0.5) + BASE_ATK;
    // 防具でダメージ軽減
    power -= (def * 0.7);

    // 力係数 (基礎体力の差)
    var str_rate = Math.pow(1.02, str - vit);

    // 威力係数 (装備アイテムの差)
    var power_rate = Math.pow(1.015, atk - def);

//    trace('power: ${power} str_rate:${str_rate} pow_rate:${power_rate}');

    // ダメージ量を計算
    var val = (power * str_rate * power_rate);
    if(val <= 0) {
      // 0ダメージはランダムで1〜3ダメージ
      val = FlxG.random.int(1, 3);
    }
    else {
      // ランダムで±10%変動
      var d = val * FlxG.random.float(-0.1, 0.1);
      if(Math.abs(d) < 3) {
        // 3より小さい場合は+1〜3する
        val += FlxG.random.int(1, 3);
      }
      else {
        val += d;
        if(val > MAX_DAMAGE) {
          // 最大ダメージ量を超えないようにする
          val = MAX_DAMAGE;
        }
      }
    }

    return Math.ceil(val);
  }

  /**
   * アイテムによるダメージ計算
   **/
  public static function damageItem(act:Actor, item:ItemData, armor:ItemData):Int {
    var str = 0;
    var vit = act.params.vit;
    var atk = ItemUtil.getParam(item.id, "atk");
    var def = 0;
    if(armor != null) {
      def = ItemUtil.getParam(armor.id, "def");
      def += armor.param.value;
    }
    var val = atk;

    // 威力
    var power = str + atk;

    // 力係数 (基礎体力の差)
    var str_rate = Math.pow(1.02, str - vit);

    // 威力係数 (装備アイテムの差)
    var power_rate = Math.pow(1.015, atk - def);

    // ダメージ量を計算
    var val = (power * str_rate * power_rate);
    if(val <= 0) {
      // 0ダメージはランダムで1〜3ダメージ
      val = FlxG.random.int(1, 3);
    }
    else {
      // ランダムで+5%変動
      var d = val * FlxG.random.float(0, 0.05);
      if(Math.abs(d) < 1) {
        // 1以下の場合は+1〜3する
        val += FlxG.random.int(1, 3);
      }
      else {
        val += d;
        if(val > MAX_DAMAGE) {
          // 最大ダメージ量を超えないようにする
          val = MAX_DAMAGE;
        }
      }
    }

    return Std.int(val);
  }

  /**
   * 攻撃が当たるかどうかをチェック
   * @param target 攻撃する対象
   **/
  public static function checkHitAttack(target:Actor):Bool {

    if(target.badstatus == BadStatus.Anger) {
      // 怒り状態のときは必ず当たる
      return true;
    }

    // 92%の確率で当たる
    return FlxG.random.bool(92);
  }

  /**
   * 敵の攻撃が当たるかどうかをチェック
   * @param target 攻撃する対象
   **/
  public static function checkHitAttackFromEnemy(target:Actor):Bool {

    if(target.badstatus == BadStatus.Anger) {
      // 怒り状態のときは必ず当たる
      return true;
    }

    // 87%の確率で当たる
    return FlxG.random.bool(87);
  }

  /**
   * アイテム投げが当たるかどうかチェック
   * @param target 攻撃する対象
   **/
  public static function checkHitThrow(target:Actor):Bool {

    if(target.badstatus == BadStatus.Anger) {
      // 怒り状態のときは必ず当たる
      return true;
    }

    // 87%の確率で当たる
    return FlxG.random.bool(87);
  }

  /**
   * ハートで回復する値を取得する
   **/
  public static function getHeartRecoveryRatio():Int {
    var v = FlxG.random.int(0, 99);
    if(v < 30) {
      return 25;
    }
    else if(v < 75) {
      return 50;
    }
    else if(v < 90) {
      return 75;
    }
    else {
      return 100;
    }
  }
}
