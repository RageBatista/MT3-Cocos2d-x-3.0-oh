<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;

class Faq extends BaseController
{
    public function search()
    {
		$question = $this->request->param('q');
		if(!isset($question)){
			return ;
		}
		//file_put_contents($question, base64_encode($question));
		
		$data = [
			'count'=>1,
			'info'=>[
				'content'=>'<T t="您好，可能是因为您的问题描述的不够详细，暂时无法给您答案" ></T><B/><T t="您可以点击精灵界面的推荐与热点问题查看适合您等级的玩法" ></T>'
			]
		];
		/*
		$data = [
			'count'=>0,
			'q'=>$question,
			'list'=>[
				'faq_id'=>'<T t="gun，暂时无答案" ></T>',
				'title'=>'<T t="等级的玩法" ></T><T t="#907" ></T>'
			]
		];*/
        return json_encode(array('data'=>$data),JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
    }
	
    public function index()
    {
		// 安全修复：已删除不安全的反序列化调试代码
		// 原代码存在以下安全风险：
		// 1. 硬编码的 unserialize() 调用可能被利用
		// 2. 暴露了支付配置信息（API地址、PID、KEY）
		// 3. 调试代码不应该存在于生产环境
		
		return json_encode([
			'code' => 0,
			'msg' => 'API ready'
		]);
    }
}
