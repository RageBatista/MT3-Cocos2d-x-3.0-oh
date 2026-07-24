<?php
namespace app\model;
use think\Model;

class Iplogs extends Model{
	
	protected $table = 'ip_log';
	
    public function addIps($data)
	{
		
		$user = new Iplogs();
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
	    $iporder = Iplogs::where('ip', $ip)->whereBetween('time', [$oneMinuteAgo, $times])->count();
	//	$iporder = Logins::where('ip', $ip)->count();

		return $iporder;
    }
 
}
?>