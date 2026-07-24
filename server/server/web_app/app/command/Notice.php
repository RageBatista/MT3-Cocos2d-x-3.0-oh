<?php
namespace app\command;

use think\console\Command;
use think\console\Input;
use think\console\input\Argument;
use think\console\input\Option;
use think\console\Output;
use app\model\Server as S;
use app\gm\Gm;

class Notice extends Command
{
    protected function configure()
    {
        // 指令配置
        $this->setName('notice')
            ->setDescription('循环公告');
    }

    protected function execute(Input $input, Output $output)
    {
		$server = new S();
		$gm = new Gm();
		$getAllServerList = $server->getAllServerList();
		$i=0;
		foreach($getAllServerList as $key=>$val){
			$string = "Hello, world!";
			$substring = "world";
			 
			if (strpos($val['notice'], ';') !== false) {
				$notice = explode(";", $val['notice']);
				$noticekey = array_rand($notice);
				$notice = $notice[$noticekey];
			} else {
				$notice = $val['notice'];
			}
			
			
			if($notice!=''){
				$data = [
					'serverip'  => $val['serverip'],
					'gmlocal'  => $val['gmlocal'],
					'gmport'  => $val['gmport'],
					'playerid'  => 4096,
					'notice'  => $notice
				];
				$gameNotify = $gm->zmd($data);
				$output->writeln($gameNotify[0]);
				$i++;
			}
		}
		$output->writeln(time().' 本次共发送：'.$i.'条公告');
    }
}