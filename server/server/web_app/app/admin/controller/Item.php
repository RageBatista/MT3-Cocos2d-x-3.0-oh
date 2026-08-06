<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\Item as ItemMod;
use PhpOffice\PhpSpreadsheet\IOFactory;
use app\model\UserLog as ULog;
use think\facade\Db;
use think\facade\Log;

class Item extends BaseController
{
    /**
     * 测试接口 - 用于验证路由是否正常工作
     */
    public function test()
    {
        Log::info('测试接口被调用|method=' . $this->request->method() . '|url=' . $this->request->url());
        return json(['code' => 1, 'msg' => '测试接口正常工作', 'time' => date('Y-m-d H:i:s')]);
    }
    
    public function itemList()
    {
        return view('item_list');
    }
    public function list_table()
    {
		$post = $this->request->param();
		$table_item = $this->buildItemFilters($post);
		$item = new ItemMod();
		$getItemList = $item->getItemList($post,$table_item);
        return jsonp($getItemList);
    }

    /**
     * 从请求参数构建物品筛选条件
     * @param array $data
     * @return array|null
     */
    private function buildItemFilters($data)
    {
        $filters = [];
        $hasFilter = false;

        $name = isset($data['name']) ? trim((string)$data['name']) : '';
        if ($name !== '') {
            $filters[] = ['name', 'like', '%' . $this->validateInput($name) . '%'];
            $hasFilter = true;
        }

        $itemid = isset($data['itemid']) ? trim((string)$data['itemid']) : '';
        if ($itemid !== '' && $itemid !== '0') {
            $filters[] = ['itemid', 'like', '%' . $this->validateInput($itemid) . '%'];
            $hasFilter = true;
        }

        $type = isset($data['type']) ? intval($data['type']) : 0;
        if ($type > 0) {
            $filters[] = ['type', '=', $type];
            $hasFilter = true;
        }

        return $hasFilter ? $filters : null;
    }
	
	
	
    public function itemSync()
    {
		try {
			$id = $this->request->post('id',null);
			Log::info('物品同步请求开始|id=' . $id . '|method=' . $this->request->method() . '|url=' . $this->request->url());
			
			if ($id === null) {
				Log::error('物品同步失败: 缺少id参数|all_params=' . json_encode($this->request->param()));
				return notify(0,'缺少物品类型参数');
			}
			
			$item = new ItemMod();
			$list = [];
			$input = '未知';
			
			Log::info('物品同步方法被调用|id=' . $id . '|time=' . date('Y-m-d H:i:s'));
			
			switch($id){
				case 1:
					$file_path = app()->getRootPath() ."public/excel/b宝石表.xlsm";
					Log::info('开始读取宝石表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('宝石表文件不存在|file=' . $file_path);
						return notify(0, '宝石表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('宝石表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '宝石';
					}
				break;
				case 2:
					$file_path = app()->getRootPath() ."public/excel/c宠物物品表.xlsm";
					Log::info('开始读取宠物物品表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('宠物物品表文件不存在|file=' . $file_path);
						return notify(0, '宠物物品表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('宠物物品表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '宠物物品';
					}
				break;
				case 3:
					$file_path = app()->getRootPath() ."public/excel/r任务物品表.xlsm";
					Log::info('开始读取任务物品表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('任务物品表文件不存在|file=' . $file_path);
						return notify(0, '任务物品表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('任务物品表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
						$data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '任务物品';
					}
				break;
				case 4:
					$file_path = app()->getRootPath() ."public/excel/s食品表.xlsm";
					Log::info('开始读取食品表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('食品表文件不存在|file=' . $file_path);
						return notify(0, '食品表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('食品表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '食品';
					}
				break;
				case 5:
					$file_path = app()->getRootPath() ."public/excel/z杂货表.xlsx";
					Log::info('开始读取杂货表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('杂货表文件不存在|file=' . $file_path);
						return notify(0, '杂货表文件不存在: ' . $file_path);
					}
					
					// 增加执行时间和内存限制
					set_time_limit(300);
					ini_set('memory_limit', '512M');
					Log::info('已设置执行时间和内存限制');
					
					Log::info('杂货表文件存在，开始加载');
					$PHPExcel = IOFactory::load($file_path);
					Log::info('Excel文件加载成功');
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('杂货表总行数|allRow=' . $allRow);
					
					// 分批处理，每批处理1000条
					$batchSize = 1000;
					$totalBatches = ceil(($allRow - 1) / $batchSize);
					Log::info('开始分批处理|batchSize=' . $batchSize . '|totalBatches=' . $totalBatches);
					
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '杂货';
						
						// 每处理1000条记录释放一次内存
						if (count($list) % $batchSize == 0) {
							$batchNum = floor(count($list) / $batchSize);
							Log::info('已处理批次|batchNum=' . $batchNum . '|currentCount=' . count($list));
							if (function_exists('gc_collect_cycles')) {
								gc_collect_cycles();
							}
						}
					}
					Log::info('杂货表读取完成|数据条数=' . count($list));
				break;
				case 6:
					$file_path = app()->getRootPath() ."public/excel/z装备表.xlsm";
					Log::info('开始读取装备表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('装备表文件不存在|file=' . $file_path);
						return notify(0, '装备表文件不存在: ' . $file_path);
					}
					
					set_time_limit(300);
					ini_set('memory_limit', '512M');
					
					try {
						$PHPExcel = IOFactory::load($file_path);
						$sheet = $PHPExcel->getSheet(0);
						$allRow = $sheet->getHighestRow();
						Log::info('装备表总行数|allRow=' . $allRow);
						
						for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
							$cellA = $PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue();
							if($cellA == null){
								break;
							}
							$data = [
								'itemid'=>$cellA,
								'name'=>$PHPExcel->getActiveSheet()->getCell("D" . $currentRow)->getValue()
							];
							$data['type'] = $id;
							$list[] = $data;
							$input = '装备';
						}
						Log::info('装备表读取完成|数据条数=' . count($list));
					} catch (\Exception $e) {
						Log::error('装备表读取失败|error=' . $e->getMessage());
						return notify(0, '装备表读取失败: ' . $e->getMessage());
					}
				break;
				case 7:
					$file_path = app()->getRootPath() ."public/excel/c称谓表.xlsx";
					Log::info('开始读取称谓表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('称谓表文件不存在|file=' . $file_path);
						return notify(0, '称谓表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('称谓表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("D" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '称谓';
					}
				break;
				case 8:
					$file_path = app()->getRootPath() ."public/excel/j奖励表.xlsx";
					Log::info('开始读取奖励表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('奖励表文件不存在|file=' . $file_path);
						return notify(0, '奖励表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('奖励表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '奖励';
					}
				break;
				case 9:
					$file_path = app()->getRootPath() ."public/excel/宠物技能.xlsx";
					Log::info('开始读取宠物技能表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('宠物技能表文件不存在|file=' . $file_path);
						return notify(0, '宠物技能表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('宠物技能表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '宠物技能';
					}
				break;
				case 10:
					$file_path = app()->getRootPath() ."public/excel/c宠物基本数据.xlsx";
					Log::info('开始读取宠物基本数据表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('宠物基本数据表文件不存在|file=' . $file_path);
						return notify(0, '宠物基本数据表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('宠物基本数据表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '宠物';
					}
				break;
				case 11:
					$file_path = app()->getRootPath() ."public/excel/特技特效表.xlsx";
					Log::info('开始读取特技特效表|file=' . $file_path);
					if (!file_exists($file_path)) {
						Log::error('特技特效表文件不存在|file=' . $file_path);
						return notify(0, '特技特效表文件不存在: ' . $file_path);
					}
					$PHPExcel = IOFactory::load($file_path);
					$sheet = $PHPExcel->getSheet(0);
					$allRow = $sheet->getHighestRow();
					Log::info('特技特效表总行数|allRow=' . $allRow);
					for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
						if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
							break;
						}
					   $data = [
							'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
							'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
						];
						$data['type'] = $id;
						$list[] = $data;
						$input = '特技特效';
					}
				break;
				default:
					Log::error('未定义的物品类型|id=' . $id);
					return notify(0,'未定义类型');
			}
			
			Log::info('开始数据库操作|type=' . $id . '|数据条数=' . count($list) . '|物品名称=' . $input);
			
			// 使用事务确保数据一致性：先删除旧数据，再插入新数据
			Db::startTrans();
			try {
				$dropItem = $item->drop($id);
				Log::info('旧数据删除成功|dropItem=' . $dropItem);
				
				if (empty($list)) {
					Log::warning('同步数据为空|type=' . $id . '|name=' . $input);
					Db::rollback();
					return notify(0, '同步数据为空，已取消本次同步');
				}
				
				// 对于杂货表（id=5）使用分批插入，避免大事务超时
				if ($id == 5 && count($list) > 1000) {
					Log::info('杂货表数据量大，使用分批插入|total=' . count($list));
					$batchSize = 500;
					$batches = array_chunk($list, $batchSize);
					$totalBatches = count($batches);
					$insertedTotal = 0;
					
					foreach ($batches as $index => $batch) {
						Log::info('开始插入批次|batch=' . ($index + 1) . '/' . $totalBatches . '|count=' . count($batch));
						$save_all = $item->save_all($batch);
						$insertedTotal += count($save_all);
						Log::info('批次插入成功|batch=' . ($index + 1) . '/' . $totalBatches . '|inserted=' . count($save_all));
						
						// 每批次后释放内存
						if (function_exists('gc_collect_cycles')) {
							gc_collect_cycles();
						}
					}
					Log::info('所有批次插入完成|totalInserted=' . $insertedTotal);
				} else {
					// 小数据量直接插入
					$save_all = $item->save_all($list);
					Log::info('数据插入成功|save_all=' . json_encode($save_all));
				}
				
				Db::commit();
				Log::info('事务提交成功');
				
				$info = '同步物品：'.$input;
				$userLog = new ULog();
				$userLog->addAdminLog($this->myAdmin['username'],$info,$this->genericVariable);
				Log::info('物品同步成功|type=' . $id . '|name=' . $input);
				return notify(1,'同步'.$input.'成功');
			} catch (\Exception $e) {
				Db::rollback();
				Log::error('数据库操作失败|error=' . $e->getMessage() . '|trace=' . $e->getTraceAsString());
				return notify(0,'同步'.$input.'失败: '.$e->getMessage());
			}
		} catch (\Exception $e) {
			Log::error('物品同步异常|error=' . $e->getMessage() . '|trace=' . $e->getTraceAsString());
			return notify(0,'同步失败: '.$e->getMessage());
		}
    }

    /**
     * 一键清空同步物品数据
     */
    public function clearAll()
    {
        try {
            $item = new ItemMod();
            $count = $item->count();
            if ($count <= 0) {
                return notify(1, '当前无可清空的数据');
            }
            $deleted = $item->dropAll();
            $info = '清空物品数据：删除记录数=' . $count;
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $info, $this->genericVariable);
            Log::warning('物品数据已清空|deleted=' . $deleted . '|by=' . $this->myAdmin['username']);
            return notify(1, '已清空物品数据，共删除 ' . $count . ' 条');
        } catch (\Exception $e) {
            Log::error('清空物品数据失败|error=' . $e->getMessage());
            return notify(0, '清空失败: ' . $e->getMessage());
        }
    }
	
}
