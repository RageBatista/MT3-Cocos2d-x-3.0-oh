<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use think\facade\Session;
use app\model\Fankui as F;
use app\model\Bind;
use app\model\Server;
use app\gm\Gm as Game;

class Fankui extends BaseController
{
    public function fankuiList()
    {
		$get = $this->request->get();
		$table_fankui = null;
		if(isset($get['info'])){
			if($get['info']!=null){
				$info = $this->validateInput($get['info']);
				$table_fankui[] = ['info','like','%'.$info.'%'];
			}
			Session::set('table_fankui', $table_fankui);
		}else{
			$table_fankui = null;
			Session::delete('table_fankui');
		}
		
		
        return view('fankui_list');
    }
    public function fankui_list_table()
    {
		$table_fankui = Session::get('table_fankui');
		$post = $this->request->post();
		$fankui = new F();
		$getFankuiList = $fankui->getFankuiList($post,$table_fankui);
        return jsonp($getFankuiList);
    }
	
    public function mail()
    {
		$id = $this->request->get('id',null);
		$fankui = new F();
		$getFankuiId = $fankui->getFankuiId($id);
		
		
        return view('mail',['getFankuiId'=>$getFankuiId]);
    }
	
    public function mailSub()
    {
		$id = $this->request->post('id',null);
		$info = $this->request->post('info',null);
		if($id==null){
			return notify(0,'反馈参数异常');
		}
		if($info==null){
			return notify(0,'请填写反馈意见');
		}
		
		$fankui = new F();
		$getFankuiId = $fankui->getFankuiId($id);
		if(!$getFankuiId){
			return notify(0,'反馈工单不存在');
		}
		
		$bind = new Bind();
		$getPlayerById = $bind->getPlayerById($getFankuiId['role']);
		if(!$getPlayerById){
			return notify(0,'角色不存在或已删除');
		}
		
		$server = new Server();
		$getServerId = $server->getServerId($getPlayerById['serverid']);
		if(!$getServerId){
			return notify(0,'角色所在区服不存在');
		}
		
		$data = [
			'serverip'=>$getServerId['serverip'],
			'gmlocal'=>$getServerId['gmlocal'],
			'gmport'=>$getServerId['gmport'],
			'playerid'=>$getPlayerById['playerid'],
			'title'=>'客服答复',
			'content'=>$info,
			'duration'=>0,
			'awardContent'=>'345065|1',
		];
		$Game = new Game();
		$gameNotify = $Game->mail($data);
		
		// 检查邮件发送结果，成功后才标记为已处理
		if(isset($gameNotify[0]) && strpos($gameNotify[0],'success') !== false){
			$upStatus = $fankui->upStatus($id);
			return notify(1,'邮件回复成功');
		}else{
			return notify(0,'邮件发送失败，请检查角色是否在线或区服是否正常');
		}
    }
}
