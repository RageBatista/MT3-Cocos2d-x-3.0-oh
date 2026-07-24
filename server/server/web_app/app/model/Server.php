<?php
namespace app\model;
use think\Model;

class Server extends Model{
	
	protected $table = 'main_server';
	
    public function getServerList($post=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		$server = Server::limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		$total = Server::count();
		$data = $server->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
    public function getAllServerList()
	{
		$server = Server::select();
		$data = $server->toArray();
		return $data;
    }
    public function addServer($data)
	{
		$user=Server::save($data);
		return $user;
    }
    public function getServer($id)
	{
		$server = Server::where('id', $id)->find();
		return $server;
    }
    public function getServerId($serverid)
	{
		$server = Server::where('serverid', $serverid)->find();
		return $server;
    }
    public function upServer($data)
	{
		Server::update($data);
    }
    public function delServer($id)
	{
		Server::where('id',$id)->delete();
    }
    public function makeServerList()
	{
		$server = Server::where('status',1)->select();
		$data = $server->toArray();
		return $data;
    }
}
?>