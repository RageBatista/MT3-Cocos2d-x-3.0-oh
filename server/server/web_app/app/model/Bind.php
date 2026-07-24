<?php
namespace app\model;
use think\Model;

class Bind extends Model{

	protected $table = 'user_bind';

    public function getPlayerById($id)
	{
		$bind = Bind::where('id', $id)->find();
		return $bind;
    }
    public function getPlayerId($playerid)
	{
		$bind = Bind::where('playerid', $playerid)->find();
		return $bind;
    }
    public function getPlayerByUid($userid)
	{
		$bind = Bind::where('userid', $userid)->find();
		return $bind;
    }

    public function getBindArr($arr)
	{
		$bind = Bind::where($arr)->find();
		return $bind;
    }
    public function addBind($data)
	{
		$bind = new Bind();
		$bind->userid     = $data['userid'];
		$bind->serverid     = $data['serverid'];
		$bind->playerid     = $data['playerid'];
		$bind->playername     = $data['playername'];
		$bind->save();
    }
    public function getBindData($condition)
	{
		$bind = Bind::where($condition)->find();
		return $bind;
    }
    public function getBindNum()
	{
		$num = Bind::count();
		return $num;
    }
    public function getBindList($post=null,$table=null,$agent=null)
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
			if($agent!=null){
				$condition[] = ['u.lastagent','=',$agent];
			}
			$bind = Bind::alias('b')->join('user_account u', 'b.userid = u.id')->join('main_server ms', 'b.serverid = ms.serverid')->field('u.id as uid,ms.id as msid,u.username,ms.name,b.*')->where($condition)->order($sort ,$sortOrder)->limit($limit)->page($page)->select();

		}else{
			if($agent!=null){
				$condition = [];
				$condition[] = ['u.lastagent','=',$agent];
				$bind = Bind::alias('b')->join('user_account u', 'b.userid = u.id')->join('main_server ms', 'b.serverid = ms.serverid')->field('u.id as uid,ms.id as msid,u.username,ms.name,b.*')->where($condition)->order($sort ,$sortOrder)->limit($limit)->page($page)->select();
			}else{
				$bind = Bind::alias('b')->join('user_account u', 'b.userid = u.id')->join('main_server ms', 'b.serverid = ms.serverid')->field('u.id as uid,ms.id as msid,u.username,ms.name,b.*')->order($sort ,$sortOrder)->limit($limit)->page($page)->select();
			}
		}
		$data = $bind->toArray();
		if(isset($condition)){
			$total = Bind::alias('b')->join('user_account u', 'b.userid = u.id')->join('main_server ms', 'b.serverid = ms.serverid')->field('u.id as uid,ms.id as msid,u.username,ms.name,b.*')->where($condition)->count();
		}else{
			$total = Bind::count();
		}
		$data=[
			'total'=>$total,
			'rows'=>$data
		];

		return $data;
    }
    public function getAllBindListUID($userid)
	{
		$bind = Bind::where('userid',$userid)->select();
		$data = $bind->toArray();
		return $data;
    }

    public function upLqDayCharge($id,$lq_daycharge)
	{
        $up = Bind::where('id', $id)->find();
		$up->lq_daycharge     = $lq_daycharge;
        $up->save();
    }

    public function upLqShouchong($id,$shouchong)
	{
        $up = Bind::where('id', $id)->find();
		$up->shouchong     = $shouchong;
        $up->save();
    }

    public function upLqRoleCharge($id,$lq_rolecharge)
	{
        $up = Bind::where('id', $id)->find();
		$up->lq_rolecharge     = $lq_rolecharge;
        $up->save();
    }


    public function upBindZhuanqu($id)
	{
        $up = Bind::where('id', $id)->find();
        $up->zhuanqu = 1;
        $up->save();
    }

    public function editBindData($data)
	{
        $up = Bind::where('id', $data['id'])->find();
        $up->charge	= $data['charge'];
        $up->chargedate	= date('Y-m-d');
        $up->daycharge	= $data['daycharge'];
        $up->save();
    }


    public function upChargeForZhuanQu($data)
	{
        $up = Bind::where('id', $data['id'])->find();
        $up->charge	= $data['charge'];
        $up->chargedate	= date('Y-m-d');
        $up->daycharge	= $data['daycharge'];
        $up->save();
    }

    public function upRoleLimit($id,$rolelimit)
	{
        $up = Bind::where('id', $id)->find();
        $up->rolelimit	= $rolelimit;
        $up->save();
    }

    public function upDayLimit($id,$daylimit)
	{
        $up = Bind::where('id', $id)->find();
        $up->daylimit	= $daylimit;
        $up->save();
    }

    public function upBindCharge($id,$charge,$daycharge)
	{

        $up = Bind::where('id', $id)->find();
        $up->charge	= $up['charge'] + $charge;
        $up->chargedate	= date('Y-m-d');
        $up->daycharge	= $daycharge;
        $up->save();
    }

    /**
     * 根据角色ID获取绑定信息（用于数据清理）
     */
    public function getByPlayerId($playerid)
    {
        $bind = Bind::where('playerid', $playerid)->find();
        if ($bind) {
            return $bind->toArray();
        }
        return null;
    }

    /**
     * 根据用户ID获取所有绑定记录（用于数据清理）
     */
    public function getByUserId($userid)
    {
        $binds = Bind::where('userid', $userid)->select();
        if ($binds) {
            return $binds->toArray();
        }
        return [];
    }

    /**
     * 删除指定用户的所有绑定记录（用于数据清理）
     */
    public function deleteByUserId($userid)
    {
        return Bind::where('userid', $userid)->delete();
    }


}

?>
