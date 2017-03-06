package jp_2dgames.game.item;

import jp_2dgames.game.item.ItemUtil.IType;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.particle.ParticleSmoke;
import jp_2dgames.game.actor.Enemy;
import flixel.math.FlxPoint;
import jp_2dgames.game.actor.Params.ParamsUtil;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.math.FlxRandom;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.Player;
import flixel.math.FlxRandom;
import jp_2dgames.lib.CsvLoader;

/**
 * アイテム種別
 **/
enum IType {
  None;   // なし
  Weapon; // 武器
  Armor;  // よろい
  Scroll; // 巻物
  Wand;   // 杖
  Potion; // ポーション
  Ring;   // 指輪
  Money;  // お金
  Food;   // 食べ物
  Orb;    // 宝珠
}

/**
 * アイテムユーティリティ
 **/
class ItemUtil {
  // 無効なアイテム番号
  public static inline var NONE = -1;
  static inline var ID_OFFSET:Int = 1000;

  // アイテムデータを定義しているCSV
  public static var csvConsumable:CsvLoader = null;
  public static var csvEquipment:CsvLoader = null;

  // アンロック対象のアイテムリスト
  private static var _unlocks:Array<Int> = null;

  /**
   * 生成
   **/
  public static function create():Void {
    csvConsumable = new CsvLoader("assets/levels/item_consumable.csv");
    csvEquipment  = new CsvLoader("assets/levels/item_equipment.csv");

    // アンロック対象のアイテムをリストアップ
    var tbl = [
      IType.Weapon,
      IType.Armor,
      IType.Ring,
      IType.Food,
      IType.Potion,
      IType.Wand,
      IType.Scroll,
      IType.Orb
    ];
    var list = new Array<Int>();
    for(type in tbl) {
      var l = getCategoryUnlockList(type);
      list = list.concat(l);
    }
    _unlocks = list;
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    csvConsumable = null;
    csvEquipment  = null;
    _unlocks       = null;
  }

  public static function getCsv(id:Int):CsvLoader {
    if(isConsumable(id)) {
      return csvConsumable;
    }
    else {
      return csvEquipment;
    }
  }

  /**
   * アイテム名を取得する
   **/
  public static function getName(item:ItemData):String {
    var csv = getCsv(item.id);
    var name = csv.searchItem("id", '${item.id}', "name");
    switch(ItemUtil.getType(item.id)) {
      case IType.Weapon, IType.Armor:
        // 武器と防具
        if(item.param.value != 0) {
          // ±がある
          var val = '${item.param.value}';
          if(item.param.value > 0) {
            val = '+${val}';
          }
          name = '${name}${val}';
        }
        else {
          name = '${name}';
        }

      case IType.Wand:
        // 杖は使用回数制限がある
        name = '${name}[${item.param.value}]';
      default:
    }
    return name;
  }

  /**
   * 攻撃力を取得する
   **/
  public static function getAtk(item:ItemData):Int {
    var atk = getParam(item.id, "atk");
    atk += item.param.value;
    return atk;
  }
  /**
   * 防御力を取得する
   **/
  public static function getDef(item:ItemData):Int {
    var def = getParam(item.id, "def");
    def += item.param.value;
    return def;
  }

  /**
   * アイテムの詳細説明文を取得する
   **/
  public static function getDetail(item:ItemData):String {
    var csv = getCsv(item.id);
    var detail = csv.searchItem("id", '${item.id}', "detail");
    return detail;
  }

  /**
   * アイテムの購入価格を取得する
   **/
  public static function getBuy(item:ItemData):Int {
    var csv = getCsv(item.id);
    var price:Float = csv.searchItemInt("id", '${item.id}', "buy");
    price = _calcAddedValue(item, price);
    return Std.int(price);
  }

  /**
   * アイテムの売却価格を取得する
   **/
  public static function getSell(item:ItemData):Int {
    var csv = getCsv(item.id);
    var price:Float = csv.searchItemInt("id", '${item.id}', "sell");
    price = _calcAddedValue(item, price);
    return Std.int(price);
  }

  /**
   * アイテムの拡張パラメータを取得する
   **/
  public static function getExtra(itemid:Int):String {
    if(itemid == ItemUtil.NONE) {
      return "";
    }
    return getParamString(itemid, "extra");
  }
  public static function getExtVal(itemid:Int):Int {
    if(itemid == ItemUtil.NONE) {
      return 0;
    }
    return getParam(itemid, "extval");
  }

  private static function _calcAddedValue(item:ItemData, price:Float):Float {
    switch(item.type) {
      case IType.Weapon, IType.Armor:
        // +1 は 100Gの価値がある
        var added = 100 * item.param.value;
        if(item.id == ItemConst.WEAPON8) {
          // ドリルは消耗品なので残存価値を計算する
          var d = price * 0.1;
          price = (d * 0.2) + (d * item.param.condition) + added;
        }
        else {
          // それ以外は普通に計算
          price += added;
        }
        if(price <= 0) {
          price = 1;
        }
      case IType.Wand:
        var d = price * 0.15;
        price = (price - d) + (d * item.param.value);
      default:
    }

    return price;
  }

  /**
	 * アイテムIDからアイテム種別を求める
	 **/
  public static function getType(id:Int):IType {
    var csv = getCsv(id);
    var str = csv.searchItem("id", '${id}', "type", false);
    if(str == "") {
      // 無効なアイテム
      return IType.None;
    }
    return fromString(str);
  }

  /**
	 * 指定のパラメータ名に対応するパラメータを取得する
	 **/
  public static function getParam(id:Int, key:String):Int {
    var csv = getCsv(id);
    return csv.searchItemInt("id", '${id}', key, false);
  }
  public static function getParamString(id:Int, key:String):String {
    var csv = getCsv(id);
    return csv.searchItem("id", '${id}', key);
  }

  public static function toString(type:IType):String {
    return '${type}';
  }

  public static function fromString(str:String):IType {
    // switchの条件に'${IType.###}'は使えない
    //		switch(str) {
    //			case '${IType.Weapon}': return IType.Weapon;
    //			case '${IType.Armor}': return IType.Armor;
    //			case '${IType.Scroll}': return IType.Scroll;
    //			case '${IType.Wand}': return IType.Wand;
    //			case '${IType.Potion}': return IType.Potion;
    //			case '${IType.Ring}': return IType.Ring;
    //			case '${IType.Food}': return IType.Food;
    //			default: throw "Error"; return IType.None;
    //		}
    if(str == '${IType.Weapon}') {
      return IType.Weapon;
    }
    else if(str == '${IType.Armor}') {
      return IType.Armor;
    }
    else if(str == '${IType.Scroll}') {
      return IType.Scroll;
    }
    else if(str == '${IType.Wand}') {
      return IType.Wand;
    }
    else if(str == '${IType.Potion}') {
      return IType.Potion;
    }
    else if(str == '${IType.Ring}') {
      return IType.Ring;
    }
    else if(str == '${IType.Money}') {
      return IType.Money;
    }
    else if(str == '${IType.Food}') {
      return IType.Food;
    }
    else if(str == '${IType.Orb}') {
      return IType.Orb;
    }
    else {
      return IType.None;
    }
  }

  // 装備アイテムかどうか

  public static function isEquip(id:Int):Bool {
    if(id < ID_OFFSET) {
      return false;
    }
    else {
      return true;
    }
  }

  // 消費アイテムかどうか
  public static function isConsumable(id:Int):Bool {
    // 装備アイテムでなければ消費アイテム
    return !isEquip(id);
  }

  // ランダムでアイテムを取得する
  public static function random(type:IType):Int {
    switch(type) {
      case IType.Weapon, IType.Armor, IType.Ring, IType.Food, IType.Potion, IType.Scroll, IType.Wand, IType.Orb:
        var list = getCategoryUnlockList(type);
        return list[FlxG.random.int(0, list.length-1)];

      case IType.Money:
        return FlxG.random.int(100, 1000);
      default:
        trace('Warning: invalid type ${type}');
        return 0;
    }
  }

  // ランダムでアイテム種別を取得する
  public static function randomType():IType {
    var tbl = [
      IType.Weapon,
      IType.Armor,
//      IType.Scroll,
//      IType.Wand,
      IType.Potion,
//      IType.Ring,
//      IType.Money,
      IType.Food
    ];
    return tbl[FlxG.random.int(0, tbl.length-1)];
  }

  // デバッグ用のアイテム種別を取得する
  public static function getDebugItemType():IType {
    if(FlxG.keys.pressed.U) {
      return IType.Weapon;
    }
    if(FlxG.keys.pressed.I) {
      return IType.Armor;
    }
    if(FlxG.keys.pressed.O) {
      return IType.Ring;
    }
    if(FlxG.keys.pressed.J) {
      return IType.Food;
    }
    if(FlxG.keys.pressed.K) {
      return IType.Potion;
    }
    if(FlxG.keys.pressed.L) {
      return IType.Money;
    }
    if(FlxG.keys.pressed.M) {
      return IType.Scroll;
    }
    if(FlxG.keys.pressed.COMMA) {
      return IType.Wand;
    }
    if(FlxG.keys.pressed.PERIOD) {
      return IType.Orb;
    }

    // 該当するキーを押していない
    return IType.None;
  }

  /**
   * 青オーブを使用できるかどうか
   **/
  public static function canUseBlueOrb():Bool {
    if(Global.getFloor() >= 30) {
      // 30F以降は使えない
      return false;
    }

    // 使える
    return true;
  }

  /**
   * 消費アイテムを使用する
   **/
  public static function use(actor:Actor, item:ItemData, bMsg=true):Void {
    // 拡張パラメータ
    var extra = ItemUtil.getParamString(item.id, "extra");
    var extval = ItemUtil.getParam(item.id, "extval");

    switch(item.type) {
      case IType.Potion:
        // 薬
        var val = ItemUtil.getParam(item.id, "hp");
        if(val > 0) {
          actor.addHp(val);
          Message.push2(Msg.RECOVER_HP, [actor.name, val]);
        }

        if(extra != "") {
          // 特殊効果あり
          useExtra(actor, extra, extval);
        }

        // 満腹度も少し回復
        var val2 = ItemUtil.getParam(item.id, "food");
        actor.addFood(val2);
        FlxG.sound.play("recover");

      case IType.Food:
        // 食糧
        var val = ItemUtil.getParam(item.id, "food");
        actor.addFood(val);
        if(actor.isFoodMax()) {
          // 満腹になった
          Message.push2(Msg.RECOVER_FOOD_MAX);
        }
        else {
          Message.push2(Msg.RECOVER_FOOD);
        }
        switch(extra) {
          case "poison":
          // 毒状態になる
          actor.changeBadStatus(BadStatus.Poison);
        }
        FlxG.sound.play("eat");

      case IType.Scroll:
        // 巻物
        switch(extra) {
          case "itemadd":
            // アイテム所持限度の上昇
            var addval = Global.addItemMaxInventory(extval);
            if(addval > 0) {
              // 増えた
              var max = Inventory.instance.getItemMax();
              Snd.playSe("recover");
              Message.push2(Msg.ITEM_LIMIT_ADD, [addval, max]);
            }
            else {
              // 何も起きない
              Message.push2(Msg.NOTHING_HAPPENED);
              Snd.playSe("error");
            }

          case "weapon":
            // 武器強化
            var weapon = Inventory.getWeaponData();
            if(weapon == null) {
              // 何も起きない
              Message.push2(Msg.NOTHING_HAPPENED);
              Snd.playSe("error");
            }
            else {
              // 武器を強化
              weapon.param.value += 1;
              var name = ItemUtil.getName(weapon);
              Message.push2(Msg.WEAPON_ADD, [name]);
              Snd.playSe("powerup");
            }

          case "armor":
            // 防具強化
            var armor = Inventory.getArmorData();
            if(armor == null) {
              // 何も起きない
              Message.push2(Msg.NOTHING_HAPPENED);
              Snd.playSe("error");
            }
            else {
              // 防具を強化
              armor.param.value += 1;
              var name = ItemUtil.getName(armor);
              Message.push2(Msg.ARMOR_ADD, [name]);
              Snd.playSe("powerup");
            }

          case "nightmare":
            // ナイトメアの残り出現ターン数が増える
            NightmareMgr.delay(extval);
            Message.push2(Msg.NIGHTMARE_DELAY, [extval]);

          default:
            // 何もしない
        }

      case IType.Wand:
        // 杖
        if(item.param.value > 0) {
          // 使用回数を減らす
          item.param.value -= 1;
        }
        else {
          // 何も起こらなかった
          Message.push2(Msg.NOTHING_HAPPENED);
        }

      case IType.Orb:
        // オーブ
        switch(item.id) {
          case ItemConst.ORB2:
            // 青オーブ
            if(canUseBlueOrb()) {
              // 次のフロアへワープ
              actor.warpNextFloor(false);
              actor.visible = false;
            }
            else {
              // 青オーブは使えない
              Message.push2(Msg.CANT_USE_ORB_BLUE);
              Snd.playSe("error", true);
            }
          case ItemConst.ORB4:
            // 緑オーブ
            actor.changeBadStatus(BadStatus.Star);
            Message.push2(Msg.BAD_STAR, [actor.name]);
          default:
            // それ以外
            // TODO:
            // 何も起こらなかった
            Message.push2(Msg.NOTHING_HAPPENED);
        }

      default:
        // ここにくることはない
        trace('Error: Invalid item ${item.id}');
    }
  }

  /**
   * 特殊アイテムを使った
   * @param actor    対象相手
   * @param extra    特殊効果名
   * @param extval   パラメータ
   * @param useActor アイテムを使った人
   **/
  public static function useExtra(actor:Actor, extra:String, extval:Int, useActor:Actor=null):Void {
    switch(extra) {
      case "hpmax":
        // 最大HP上昇
        actor.addHpMax(extval);
        Message.push2(Msg.GROW_HPMAX, [actor.name, extval]);
      case "food":
        // 最大満腹度上昇
        actor.addFoodMax(extval);
        Message.push2(Msg.GROW_FOOD, [extval]);
      case "str":
        // 力上昇
        actor.addStr(extval);
        Message.push2(Msg.GROW_STR, [extval]);
      case "poison":
        // 毒状態になる
        actor.changeBadStatus(BadStatus.Poison);
      case "sleep":
        // 眠り状態になる
        actor.changeBadStatus(BadStatus.Sleep);
      case "paralysis":
        // 麻痺状態になる
        actor.changeBadStatus(BadStatus.Paralysis);
      case "confusion":
        // 混乱状態になる
        actor.changeBadStatus(BadStatus.Confusion);
      case "anger":
        // 怒り状態になる
        actor.changeBadStatus(BadStatus.Anger);
      case "powerful":
        // 元気状態になる
        actor.changeBadStatus(BadStatus.Powerful);
      case "recover":
        // 状態異常回復
        actor.cureBadStatus();
        Message.push2(Msg.BAD_CURE, [actor.name]);
      case "closed":
        // 封印状態になる
        actor.changeBadStatus(BadStatus.Closed);
      case "warp":
        // ワープする
        var distance = Field.getLayerWidth()*Field.getLayerHeight()/4;
        var cnt = 1000; // 試行回数
        for(i in 0...cnt) {
          var pt:FlxPoint = null;
          if(FlxG.random.bool()) {
            // 部屋から探す
            pt = Field.searchRandom(Field.NONE);
          }
          else {
            pt = Field.searchRandom(Field.PASSAGE);
          }

          if(pt == null) {
            continue;
          }

          var px = Std.int(pt.x);
          var py = Std.int(pt.y);
          var dx = px - actor.xchip;
          var dy = py - actor.ychip;
          if(dx*dx + dy*dy < distance) {
            // もっと遠くの場所を探す
            distance--;
            continue;
          }

          if(Enemy.getFromPosition(px, py) == null) {
            // ワープ可能
            ParticleSmoke.start("warp", actor.x, actor.y);
            actor.warp(px, py, true);
            break;
          }
          pt.put();
        }
      case "change":
        // お互いの位置をチェンジ
        var use_xchip = useActor.xchip;
        var use_ychip = useActor.ychip;
        var target_xchip = actor.xchip;
        var target_ychip = actor.ychip;
        useActor.warp(target_xchip, target_ychip, false);
        actor.warp(use_xchip, use_ychip, false);
        // メッセージ表示
        Message.push2(Msg.POSITION_CHANGE, [useActor.name, actor.name]);

      case "hpswap":
        // HP交換
        var self_hp  = useActor.params.hp;
        var other_hp = actor.params.hp;
        actor.params.hp    = self_hp;
        useActor.params.hp = other_hp;
        useActor.trancateHp();
        actor.trancateHp();
        Message.push2(Msg.HP_SWAP, [actor.name]);
    }
  }

  /**
   * 巻物を使った
   **/
  public static function useScroll(actor:Actor, item:ItemData):Void {

  }

  /**
   * 指輪を装備する
   **/
  public static function equipRing(actor:Actor, item:ItemData):Void {
    // 拡張パラメータを初期化
    ParamsUtil.init(actor.extParams);

    var str = getParam(item.id, "atk");
    actor.extParams.str += str;
    var vit = getParam(item.id, "def");
    actor.extParams.vit += vit;
    var extra = getParamString(item.id, "extra");
    var ext_val = getParam(item.id, "ext_val");
    switch(extra) {
      case "hpmax":
        actor.extParams.hpmax += ext_val;
      default:
    }

    actor.trancateHp();
  }

  /**
   * 指輪を外す
   **/
  public static function unequipRing(actor:Actor, item:ItemData):Void {
    // 拡張パラメータを初期化
    ParamsUtil.init(actor.extParams);

    actor.trancateHp();
  }

  public static function count(type:IType):Int {
    switch(type) {
      case IType.None:   return 0; // なし
      case IType.Weapon: return 1 + ItemConst.WEAPON20 - ItemConst.WEAPON1; // 武器
      case IType.Armor:  return 1 + ItemConst.ARMOR20  - ItemConst.ARMOR1;  // よろい
      case IType.Scroll: return 1 + ItemConst.SCROLL16 - ItemConst.SCROLL1; // 巻物
      case IType.Wand:   return 1 + ItemConst.WAND16   - ItemConst.WAND1;   // 杖
      case IType.Potion: return 1 + ItemConst.POTION32 - ItemConst.POTION1; // ポーション
      case IType.Ring:   return 1 + ItemConst.RING20   - ItemConst.RING1;   // 指輪
      case IType.Money:  return 0; // お金
      case IType.Food:   return 1 + ItemConst.FOOD16   - ItemConst.FOOD1; // 食べ物
      case IType.Orb:    return 1 + ItemConst.ORB8     - ItemConst.ORB1;  // 宝珠
    }
  }

  public static function firstID(type:IType):Int {
    switch(type) {
      case IType.None:   return 0; // なし
      case IType.Weapon: return ItemConst.WEAPON1; // 武器
      case IType.Armor:  return ItemConst.ARMOR1;  // よろい
      case IType.Scroll: return ItemConst.SCROLL1; // 巻物
      case IType.Wand:   return ItemConst.WAND1;   // 杖
      case IType.Potion: return ItemConst.POTION1; // ポーション
      case IType.Ring:   return ItemConst.RING1;   // 指輪
      case IType.Money:  return 0; // お金
      case IType.Food:   return ItemConst.FOOD1; // 食べ物
      case IType.Orb:    return ItemConst.ORB1;  // 宝珠
    }
  }

  /**
   * 指定のカテゴリのアンロック対象のアイテムリストを取得する
   **/
  public static function getCategoryUnlockList(type:IType):Array<Int> {
    var list = new Array<Int>();
    var cnt = ItemUtil.count(type);
    for(i in 0...cnt) {
      var id = ItemUtil.firstID(type) + i;
      var bLog = ItemUtil.getParam(id, "log") == 1;
      if(bLog) {
        list.push(id);
      }
    }
    return list;
  }

  /**
   * アンロックの割合を取得する
   * @return 全アイテム獲得で 1.0
   **/
  public static function getUnlockRatio(logs:Array<Int>):Float {
    var cnt = 0;
    for(itemID in _unlocks) {
      if(logs.indexOf(itemID) != -1) {
        cnt++;
      }
    }

    return cnt / _unlocks.length;
  }
}
