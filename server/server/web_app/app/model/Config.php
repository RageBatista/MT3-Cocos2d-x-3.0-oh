<?php
namespace app\model;
use think\Model;

class Config extends Model{
	
	protected $table = 'main_config';
	
    public function getConfig()
	{
		$configData = [];
		$config = Config::select();
		$config = $config->toArray();
		foreach($config as $res){
			if (isset($res['keys'])) {
				$configData[$res['keys']] = $res['values'] ?? null;
			}
		}
		return $configData;
    }
    public function upConfig($data)
	{
        $up = Config::where('keys', $data['keys'])->find();
		$up->values = $data['values'];
        $up->save();
    }
}
?>
