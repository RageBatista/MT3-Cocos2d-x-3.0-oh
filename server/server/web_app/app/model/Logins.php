<?php
namespace app\model;
use think\Model;

class Logins extends Model{
	
	protected $table = 'login_log';
	
    public function addLogins($data)
	{
		
		$user = new Logins();
		foreach($data as $key => $val){
			if($val===null||$val==''){
				return false;
			}
			
		}
		$user->save($data);
		return true;
    }
    
    public function geLoginsIp($ip)
	{
	    $times = date('Y-m-d H:i:s');
	    $oneMinuteAgo = date('Y-m-d H:i:s', strtotime('-24 hours'));
	    $iporder = Logins::where('ip', $ip)->whereBetween('time', [$oneMinuteAgo, $times])->count();
	//	$iporder = Logins::where('ip', $ip)->count();

		return $iporder;
    }
 
}
?>