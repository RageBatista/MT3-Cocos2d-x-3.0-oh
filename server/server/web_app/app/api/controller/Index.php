<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use think\facade\Db;
use app\model\UserLog as ULog;
use app\model\BlackIP as BIP;
use app\model\Bind as B;

class Index extends BaseController
{
    public function index()
    {
		$a = 160001 / 1000 % 10;
		var_dump($a);
				// $bind = new B();
				// $upBindCharge = $bind->upBindCharge(2,1);
				// var_dump($upBindCharge);
		// $a = Db::table('user_order')->where('status', 1)->select()->toArray();
		// foreach($a as $key=>$val){
			// $user = json_decode($val['user'],true);
			// $playerid = $user['playerid'];
			
			// Db::table('user_bind')->where('playerid', $playerid)->inc('charge', intval($val['realmoney']))->update();
			
			// var_dump($val['realmoney']);
		// }
    }
}
