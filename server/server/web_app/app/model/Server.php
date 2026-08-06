<?php
namespace app\model;
use think\Model;

class Server extends Model{
	
	protected $table = 'main_server';
	
    public function getServerList($post=null)
	{
		$page = isset($post['page'])?max(1,intval($post['page'])):1;
		$limit = isset($post['limit'])?max(1,min(100,intval($post['limit']))):10;
		$sortOrder = (isset($post['sortOrder']) && strtolower($post['sortOrder'])==='desc')?'desc':'asc';
		$sortMap = [
			'id' => 'id',
			'groupname' => 'groupname',
			'name' => 'name',
			'serverip' => 'serverip',
			'serverport' => 'serverport',
			'gmport' => 'gmport',
			'serverid' => 'serverid',
			'opentime' => 'opentime',
			'gmlocal' => 'gmlocal',
			'status' => 'status'
		];
		$sortKey = isset($post['sort'])?$post['sort']:'id';
		$sort = isset($sortMap[$sortKey]) ? $sortMap[$sortKey] : 'id';
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
