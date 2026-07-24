<?php
namespace app\model;
use think\Model;

class AdminLog extends Model{
	
	protected $table = 'admin_log';
	
    public function addAdminLog($username,$info,$genericVariable)
	{
		$user = new AdminLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		$user->ip    = $genericVariable['ip'];
		$user->city    = $genericVariable['city'];
		$user->save();
    }
}
?>