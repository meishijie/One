// BGM再生
BGM,op1
// マップ読み込み
MAP_LOAD,001.tmx
// プレイヤー生成
NPC_CREATE,0,player,13,5,down

// ネコ生成
NPC_CREATE,1,cat,6,4,random
NPC_CREATE,2,cat,18,5,random
NPC_CREATE,3,cat,8,7,random
NPC_CREATE,4,cat,14,6,random
// ネコの色設定
NPC_COLOR,1,0xfffa8072
NPC_COLOR,2,0xFF80A0FF
NPC_COLOR,3,0xffffffff
NPC_COLOR,4,0xffbfff00
// ランダム移動
NPC_RANDOM,1
NPC_RANDOM,2
NPC_RANDOM,3
NPC_RANDOM,4
FADE_IN,black
// メッセージ表示
MSG,1
MSG,2
FADE_OUT,white
WAIT,0.5
BGM_OFF
// ネコを消す
NPC_DESTROY,1
NPC_DESTROY,2
NPC_DESTROY,3
NPC_DESTROY,4
FADE_IN,white
MSG,3
NPC_DIR,0,left
WAIT,1
NPC_DIR,0,right
WAIT,1
NPC_MOVE,0,down,8
FADE_OUT,black
NPC_DESTROY,0
MAP_CLEAR

// ダンジョン前
FADE_IN,black
MSG,4
FADE_OUT,black
BGM,op2
MAP_LOAD,002.tmx
// ネコ生成
NPC_CREATE,1,cat,13,8,random
NPC_CREATE,2,cat,13,10,random
NPC_CREATE,3,cat,13,12,random
NPC_CREATE,4,cat,13,14,random
// ネコの色設定
NPC_COLOR,1,0xfffa8072
NPC_COLOR,2,0xFF80A0FF
NPC_COLOR,3,0xffffffff
NPC_COLOR,4,0xffbfff00
// ネコ移動
NPC_MOVE,1,up,20
NPC_MOVE,2,up,20
NPC_MOVE,3,up,20
NPC_MOVE,4,up,20
// ネコ消滅
NPC_DESTROY,1,fade,0.2
NPC_DESTROY,2,fade,0.2
NPC_DESTROY,3,fade,0.2
NPC_DESTROY,4,fade,0.2
FADE_IN,black
MSG,5
MSG,6
FADE_OUT,black
NPC_DESTROY_ALL

// プレイヤー移動
NPC_CREATE,0,player,13,10,up
NPC_MOVE,0,up,7
NPC_DIR,0,left
NPC_WAIT,0,0.5
NPC_DIR,0,right
NPC_WAIT,0,0.5
NPC_MOVE,0,down,1
NPC_WAIT,0,1
FADE_IN,black
MSG,7
MSG,8
MSG,9
NPC_MOVE,0,up,3
NPC_DESTROY,0,fade,0.5
FADE_OUT,black
SE,foot
WAIT,1
