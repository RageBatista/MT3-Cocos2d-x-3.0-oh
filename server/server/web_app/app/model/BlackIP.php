<?php
namespace app\model;
use think\Model;

class BlackIP extends Model{
	
	protected $table = 'user_black_ip';
	
    public function getIP($ip)
	{
		$ip = BlackIP::where('ip', $ip)->find();
		return $ip;
    }
	
    public function addIP($ip,$info)
	{
		$black_ip = new BlackIP();
		$black_ip->ip     = $ip;
		$black_ip->info     = $info;
		$black_ip->save();
    }
	
	
    public function delIP($ip)
	{
		$del = BlackIP::where('ip',$ip)->delete();
		return $del;
    }
}

?>