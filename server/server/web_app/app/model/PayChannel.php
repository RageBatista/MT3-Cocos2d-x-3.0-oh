<?php
namespace app\model;
use think\Model;

class PayChannel extends Model{
	
	protected $table = 'main_pay_channel';
	
    public function getPayList($post=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		
		$channel = PayChannel::limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		$total = PayChannel::count();
		$data = $channel->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
    public function getAllPayList($condition=null)
	{	
		if($condition!=null){
			$pay = PayChannel::where($condition)->select();
		}else{
			$pay = PayChannel::select();
		}
		$data = $pay->toArray();
		return $data;
    }
    public function addChannel($data)
	{
		$pay = new PayChannel();
		$pay->save($data);
    }
    public function getChannel($id)
	{
		$pay = PayChannel::where('id', $id)->find();
		return $pay;
    }
    public function delChannel($id)
	{
		$pay = new PayChannel();
		$pay->where('id',$id)->delete();
    }
    public function editChannel($data)
	{
        $up = PayChannel::where('id', $data['id'])->find();
		$up->save($data);
    }
	
	
	
}
?>