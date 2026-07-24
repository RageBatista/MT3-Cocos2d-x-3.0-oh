<?php
namespace app\model;
use think\Model;

class ChargeAward extends Model{
	
	protected $table = 'main_charge_award';
	
	
    public function getAwardList($type,$status=1)
	{
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		$condition = []; 
		$condition[] = ["status",'=',$status];
		$condition[] = ["type",'=',$type];
		$item = ChargeAward::where($condition)->order($sort ,$sortOrder)->select();
		$data = $item->toArray();
		return $data;
    }
    public function getAwardById($id)
	{
		$award = ChargeAward::where('id', $id)->find();
		$data = $award->toArray();

		return $award;
		
    }
	
	public function getAllAwardList($post=null,$condition=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'value';
		$item = ChargeAward::where($condition)->order($sort ,$sortOrder)->select();
		$total = ChargeAward::where($condition)->count();
		$award = $item->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$award
		];
	
		return $data;
    }
	
	
	
	
    public function addUser($data,$ip)
	{
		$user = new User();
		$user->username     = $data['username'];
		$user->password     = $data['password'];
		$user->lastagent     = $data['lastagent'];
		$user->login_ip     = $ip;
		$user->save();
    }
	
    public function platform($id,$platform)
	{
        $up = User::where('id', $id)->find();
		$up->platform     = $platform;
        $up->save();
    }
    public function userIP($id,$ip)
	{
        $up = User::where('id', $id)->find();
		$up->login_ip     = $ip;
        $up->save();
    }
	
	
    public function getById($id)
	{
		$user = User::where('id', $id)->find();
		return $user;
    }
    public function upBidServer($id,$serverid)
	{
        $up = User::where('id', $id)->find();
		if($up['bidserver']==null){
			$up->bidserver     = json_encode(array($serverid));
		}else{
			$newserver = json_decode($up['bidserver']);
			if(!in_array($serverid,$newserver)){
				$newserver[] = $serverid;
			}
			$up->bidserver     = json_encode($newserver);
		}
        $up->save();
		return $up;
    }
	
    public function getUserNum($agent=null,$all=null)
	{
		if($agent!=null){
			$condition1 = [];
			$condition1[] = ['u.lastagent','=',$agent];
			if($all!=null){
				$condition2 = [];
				$agent = addslashes($agent);
				$condition2[] = ['a.agent_tree','like','%@'.$agent.'@%'];
				$num = User::alias('u')->join('admin_account a','u.lastagent = a.id')->whereOr([$condition1,$condition2])->field('a.agent_tree,u.*,a.*')->count();
			}else{
				$num = User::alias('u')->join('admin_account a','u.lastagent = a.id')->where($condition1)->field('a.agent_tree,u.*,a.*')->count();
			}
		}else{
			$num = User::count();
		}
		
		return $num;
    }
	
    public function upUser($data)
	{
        $up = User::where('id', $data['id'])->find();
		if(isset($data['username'])){
			$up->username     = $data['username'];
		}
		if(isset($data['password'])){
			$up->password     = $data['password'];
		}
		if(isset($data['lastagent'])){
			$up->lastagent     = $data['lastagent'];
		}
        $up->save();
    }
	
    public function upRebate($username)
	{
        $up = User::where('username', $username)->find();
		$up->rebate	= 1;
        $up->save();
    }
		
    public function del($id)
	{
		$user = new User();
		$user->where('id',$id)->delete();
    }
    public function getPlayerList($post=null,$table=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		if($table!=null){
			$condition = [];
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}
		if(isset($condition)){
			$user = User::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$total = User::where($condition)->count();
		}else{
			$user = User::limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$total = User::count();
		}
		$data = $user->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
	
		return $data;
    }
   
    public function status($id)
	{
        $up = User::where('id', $id)->find();
		if($up['status']==1){
			$up->status	= 0;
			$msg = '封禁成功';
		}else{
			$up->status	= 1;
			$msg = '解封成功';
		}
		$up->save();
		return $msg;
    }
	
	
}

?>