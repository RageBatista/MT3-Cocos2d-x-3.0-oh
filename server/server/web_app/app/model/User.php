<?php
namespace app\model;
use think\Model;

class User extends Model{

	protected $table = 'user_account';

    public function getUsername($username)
	{
		$user = User::where('username', $username)->find();
		return $user;
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

    public function getUserIP($id)
	{
		$user = User::where('id', $id)->find();
		if(isset($user['login_ip'])){
			if($user['login_ip']==0||$user['login_ip']=="127.0.0.1"||$user['login_ip']=="localhost"){
				return false;
			}else{
				return $user['login_ip'];
			}
		}else{
			return false;
		}
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

    public function getBidServer($id,$serverid)
	{
		$user = User::where('id', $id)->find();
		if($user['bidserver']==null){
			return false;
		}else{
			$newserver = json_decode($user['bidserver']);
			if(in_array($serverid,$newserver)){
				return true;
			}

		}
		return false;
    }
    public function checkUserId($id,$username)
	{
		$user = User::where([['id','<>',$id],['username','=',$username]])->find();
		return $user;
    }
    public function getUserNum($agent=null,$all=null)
	{
		if($agent!=null){
			$condition1 = [];
			$condition1[] = ['u.lastagent','=',$agent];
			if($all!=null){
				$condition2 = [];
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
		$page = isset($post['page'])?max(1,intval($post['page'])):1;
		$limit = isset($post['limit'])?max(1,min(100,intval($post['limit']))):10;
		$sortOrder = (isset($post['sortOrder']) && strtolower($post['sortOrder'])==='desc')?'desc':'asc';
		$allowedSorts = ['id','username','status','lastagent','platform','login_ip'];
		$sort = (isset($post['sort']) && in_array($post['sort'],$allowedSorts))?$post['sort']:'id';
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

    public function getAgentPlayerList($post=null,$table=null,$agentid=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'u.id';
		$condition = [];
		if($table!=null){
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}

		//$list = Db::name($table)->alias('b')->join('account a', 'b.userid = a.id')->join('servers s', 'b.serverid = s.serverid')->where($condition)->field('b.id as bid,b.*,a.*,s.*')->order($order ,$sort)->paginate($limit);

		$condition1 = $condition;
		$condition2 = $condition;

		$agentid = $agentid;
		$condition1[] = ['a.agent_tree','like','%@'.$agentid.'@%'];
		$condition2[] = ['a.id','=',$agentid];


		$user = User::alias('u')->join('admin_account a', 'u.lastagent = a.id')->whereOr([$condition1,$condition2])->field('a.id as aid,a.username as auser,a.agent_tree,u.*')->order($sort ,$sortOrder)->paginate($limit);

		// $user = User::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		$data = $user->toArray();
		$data=[
			'total'=>$data['total'],
			'rows'=>$data['data']
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

    public function zhiboqu($id)
	{
        $up = User::where('id', $id)->find();
        if($up['zhiboqu']==1){
            $up->zhiboqu	= 0;
            $msg = '禁用直播区权限成功';
        }else{
            $up->zhiboqu	= 1;
            $msg = '开启直播区权限成功';
        }
        $up->save();
		return $msg;
    }

    /**
     * 删除指定ID的用户（用于数据清理）
     */
    public function deleteById($id)
    {
        return User::where('id', $id)->delete();
    }

}
