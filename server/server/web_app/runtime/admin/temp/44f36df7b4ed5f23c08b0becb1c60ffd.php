<?php /*a:1:{s:55:"/www/wwwroot/web_app/app/admin/view/item/item_list.html";i:1772268861;}*/ ?>
<!DOCTYPE html>
<html lang="zh">
<head>
<link rel="stylesheet" type="text/css" href="/static/template/css/materialdesignicons.min.css">
<link rel="stylesheet" type="text/css" href="/static/template/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/static/template/css/style.min.css">
<!--表格插件css-->
<link rel="stylesheet" href="/static/template/js/bootstrap-table/bootstrap-table.min.css">
<link rel="stylesheet" type="text/css" href="/static/template/css/style.min.css">
</head>
  
<body>
<div class="container-fluid">
  
  <div class="row">
    
    <div class="col-lg-12">
      <div class="card">
        <header class="card-header"><div class="card-title">物品列表</div></header>
        <div class="card-body">
          <div class="card-search mb-2-5">
            <form class="search-form" id="itemSearchForm" method="get" action="/index.php?s=/<?php echo htmlentities($app); ?>/item/itemList" role="form">
              
              <div class="row">
                <div class="col-md-3">
                  <div class="row">
                    <label class="col-sm-4 col-form-label">物品名称</label>
                    <div class="col-sm-8">
                      <input type="text" class="form-control pull-left" name="name" value="" placeholder="物品名称" />
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="row">
                    <label class="col-sm-4 col-form-label">物品ID</label>
                    <div class="col-sm-8">
                      <input type="text" class="form-control pull-left" name="itemid" value="" placeholder="物品ID" />
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="row">
                    <label class="col-sm-4 col-form-label">物品类型</label>
                    <div class="col-sm-8">
                      <select name="type" class="form-select">
                        <option value="0">全部</option>
                        <option value="1">宝石</option>
                        <option value="2">宠物物品</option>
                        <option value="3">任务物品</option>
                        <option value="4">食品</option>
                        <option value="5">杂货</option>
                        <option value="6">装备</option>
                        <option value="7">称谓</option>
                        <option value="8">奖励</option>
                        <option value="9">宠物技能</option>
                        <option value="10">宠物</option>
                        <option value="11">特技特效</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <button type="submit" class="btn btn-primary me-1">搜索</button>
                  <button type="reset" class="btn btn-default">重置</button>
                </div>
              </div>
              
            </form>
          </div>
          <div id="toolbar" class="toolbar-btn-action">
            <button type="button" onClick="testConnection()"  class="btn btn-info me-1">
				测试连接
            </button>
            <button type="button" onClick="itemSync(1)"  class="btn btn-success me-1">
				同步宝石
            </button>
            <button type="button" onClick="itemSync(2)"  class="btn btn-warning me-1">
				同步宠物物品
            </button>
            <button type="button" onClick="itemSync(3)"  class="btn btn-secondary me-1">
				同步任务物品
            </button>
            <button type="button" onClick="itemSync(4)"  class="btn btn-purple me-1">
				同步食品
            </button>
            <button type="button" onClick="itemSync(5)"  class="btn btn-cyan me-1">
				同步杂货
            </button>
            <button type="button" onClick="itemSync(6)"  class="btn btn-brown me-1">
				同步装备
            </button>  
            <button type="button" onClick="itemSync(7)"  class="btn btn-primary me-1">
				同步称谓
            </button>
            <button type="button" onClick="itemSync(8)"  class="btn btn-info me-1">
				同步奖励
            </button>
            <button type="button" onClick="itemSync(9)"  class="btn btn-danger me-1">
				同步宠物技能
            </button>
            <button type="button" onClick="itemSync(10)"  class="btn btn-dark me-1">
				同步宠物
            </button>
            <button type="button" onClick="itemSync(11)"  class="btn btn-pink me-1">
				同步特技特效
            </button>
            <button type="button" onClick="clearAllItems()"  class="btn btn-outline-danger me-1">
				清空数据
            </button>
          </div>
  	      <table id="table"></table>
          
        </div>
      </div>
    </div>
        
  </div>
  
</div>
<script type="text/javascript" src="/static/template/js/jquery.min.js"></script>
<script type="text/javascript" src="/static/template/js/popper.min.js"></script>
<script type="text/javascript" src="/static/template/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/static/template/js/main.min.js"></script>
<!--表格插件js-->
<script src="/static/template/js/bootstrap-table/bootstrap-table.js"></script>
<script src="/static/template/js/bootstrap-table/locale/bootstrap-table-zh-CN.min.js"></script>
<!--通知弹窗-->
<link rel="stylesheet" type="text/css" href="/static/template/alert/sweetalert2.min.css">
<script  src="/static/template/alert/sweetalert2.all.min.js"></script>


<script>
	/**
	 * 测试连接 - 验证路由是否正常工作
	 */
	function testConnection() {
		$action = "/index.php?s=/<?php echo htmlentities($app); ?>/item/test";
		console.log('开始测试连接|action=' + $action);
		
		$.get($action, function(res) {
			console.log('测试连接返回|res=' + JSON.stringify(res));
			var Toast = Swal.mixin({
			  toast: true,
			  position: "top",
			  showConfirmButton: false,
			  timer: 3000,
			  timerProgressBar: true,
			  didOpen: (toast) => {
				toast.onmouseenter = Swal.stopTimer;
				toast.onmouseleave = Swal.resumeTimer;
			  }
			});
			Toast.fire({
			  icon: "success",
			  title: '连接正常: ' + res.msg
			});
		}).fail(function (jqXHR, textStatus, errorThrown) {
			console.error('测试连接失败|jqXHR=' + JSON.stringify(jqXHR) + '|textStatus=' + textStatus + '|errorThrown=' + errorThrown);
			var Toast = Swal.mixin({
			  toast: true,
			  position: "top",
			  showConfirmButton: false,
			  timer: 3000,
			  timerProgressBar: true,
			  didOpen: (toast) => {
				toast.onmouseenter = Swal.stopTimer;
				toast.onmouseleave = Swal.resumeTimer;
			  }
			});
			Toast.fire({
			  icon: "error",
			  title: '连接失败: ' + textStatus
			});
		});
	}

	function itemSync(id){
		//rows选中行的数据对象数组
		$action="/index.php?s=/<?php echo htmlentities($app); ?>/item/itemSync"
		console.log('开始同步物品|id=' + id + '|action=' + $action);
		
		// 显示加载提示
		Swal.fire({
			title: '正在同步数据',
			text: '请稍候，这可能需要几分钟时间...',
			icon: 'info',
			showConfirmButton: false,
			allowOutsideClick: false,
			allowEscapeKey: false,
			didOpen: () => {
				Swal.showLoading();
			}
		});
		
		$.ajax({
			url: $action,
			type: 'POST',
			data: {id: id},
			timeout: 300000, // 5分钟超时
			success: function(res) {
				console.log('同步请求返回|res=' + JSON.stringify(res));
				if(res.code==1){
					Swal.fire({
						icon: "success",
						title: "同步成功",
						text: res.msg,
						timer: 1500,
						showConfirmButton: false
					});
					setTimeout("self.location.reload();",1500);
				}else {
					console.error('同步失败|res=' + JSON.stringify(res));
					Swal.fire({
						icon: "error",
						title: "同步失败",
						text: res.msg,
						timer: 3000,
						showConfirmButton: false
					});
					setTimeout("self.location.reload();",3000);
				}
			},
			error: function (jqXHR, textStatus, errorThrown) {
				console.error('同步请求失败|jqXHR=' + JSON.stringify(jqXHR) + '|textStatus=' + textStatus + '|errorThrown=' + errorThrown);
				var errorMsg = '同步失败: ' + textStatus;
				if (textStatus === 'timeout') {
					errorMsg = '同步超时，请检查网络连接或联系管理员';
				} else if (jqXHR.status === 502) {
					errorMsg = '服务器网关错误，请稍后重试';
				} else if (jqXHR.status === 504) {
					errorMsg = '服务器网关超时，数据量较大，请稍后重试';
				}
				Swal.fire({
					icon: "error",
					title: "同步失败",
					text: errorMsg,
					timer: 5000,
					showConfirmButton: true
				});
			}
		});

		return false;
	}

	function clearAllItems(){
		var $action = "/index.php?s=/<?php echo htmlentities($app); ?>/item/clearAll";
		Swal.fire({
			title: '确认清空所有物品数据？',
			text: '该操作将删除已同步到数据库的全部物品数据，且不可恢复',
			icon: 'warning',
			showCancelButton: true,
			confirmButtonText: '确定清空',
			cancelButtonText: '取消'
		}).then(function(result){
			if(!result.isConfirmed){ return; }
			$.post($action, {}, function(res){
				if(res.code==1){
					Swal.fire({
						icon: "success",
						title: "清空成功",
						text: res.msg,
						timer: 1500,
						showConfirmButton: false
					});
					$('#table').bootstrapTable('refresh', {pageNumber: 1});
				}else{
					Swal.fire({
						icon: "error",
						title: "清空失败",
						text: res.msg || '操作失败',
						showConfirmButton: true
					});
				}
			}).fail(function(){
				Swal.fire({
					icon: "error",
					title: "请求失败",
					text: '服务异常，请稍后再试',
					showConfirmButton: true
				});
			});
		});
	}
	/**
	 * 分页相关的配置
	 **/
	var pagination = {
		// 分页方式：[client] 客户端分页，[server] 服务端分页
		sidePagination: "server",
		// 初始化加载第一页，默认第一页
		pageNumber: 1,
		// 每页的记录行数
		pageSize: 10,
		// 可供选择的每页的行数 - (亲测大于1000存在渲染问题)
		pageList: [5, 10, 25, 50, 100],
		// 在上百页的情况下体验较好 - 能够显示首尾页
		paginationLoop: true,
		// 展示首尾页的最小页数
		paginationPagesBySide: 2
	};
	
	/**
	 * 按钮相关配置
	 **/
	var button = {
		// 按钮的类
		buttonsClass: 'default',
		// 类名前缀
		buttonsPrefix: 'btn'
	}
	
	/**
	 * 图标相关配置
	 **/
	var icon = {
		// 图标前缀
		iconsPrefix: 'mdi',
		// 图标大小
		iconSize: 'mini',
		// 图标的设置
		icons: {
			paginationSwitchDown: 'mdi-door-closed',
			paginationSwitchUp: 'mdi-door-open',
			refresh: 'mdi-refresh',
			toggleOff: 'mdi-toggle-switch-off',
			toggleOn: 'mdi-toggle-switch',
			columns: 'mdi-table-column-remove',
			detailOpen: 'mdi-plus',
			detailClose: 'mdi-minus',
			fullscreen: 'mdi-monitor-screenshot',
			search: 'mdi-table-search',
			clearSearch: 'mdi-trash-can-outline'
		}
	};
	
	/**
	 * 表格相关的配置
	 **/
	var table = {
		classes: 'table table-bordered table-hover table-striped lyear-table',
		// 请求地址
		url: '/index.php?s=/<?php echo htmlentities($app); ?>/item/list_table',
		// 唯一ID字段
		uniqueId: 'id',
		// 每行的唯一标识字段
		idField: 'id',
		// 是否启用点击选中行
		clickToSelect: true,
		// 是否显示详细视图和列表视图的切换按钮(clickToSelect同时设置为true时点击会报错)
		// showToggle: true,
		// 请求得到的数据类型
		dataType: 'jsonp',
		// 请求方法
		method: 'post',
		// 工具按钮容器
		toolbar: '#toolbar',
		// 是否分页
		pagination: true,
		// 是否显示所有的列
		showColumns: true,
		// 是否显示刷新按钮
		showRefresh: true,
		// 显示图标
		showButtonIcons: true,
		// 显示文本
		showButtonText: false,
		// 显示全屏
		showFullscreen: true,
		// 开关控制分页
		showPaginationSwitch: true,
		// 总数字段
		totalField: 'total',
		// 当字段为 undefined 显示
		undefinedText: '-',
		// 排序方式
		sortOrder: "asc",
		...icon,
		...pagination,
		...button
	};
	
	/**
	 * 用于演示的列信息
	 **/
	var columns = [{
		field: 'example',
		checkbox: true,
		// 列的宽度
		width: 3,
		// 宽度单位
		widthUnit: 'rem'
	}, {
		field: 'id',
		title: 'ID',
		// 使用[align]，[halign]和[valign]选项来设置列和它们的标题的对齐方式。
		// h表示横向，v标识垂直
		align: 'center',
		// 是否作为排序列
		sortable: true,
		// 当列名称与实际名称不一致时可用
		sortName: 'id',
		switchable: false,
		// 列的宽度
		width: 3,
		// 宽度单位
		widthUnit: 'rem'
	}, {
		field: 'name',
		align: 'center',
		title: '名称'
	}, {
		field: 'itemid',
		align: 'center',
		title: '物品ID',
	}, {
        field: 'type',
        title: '状态',
        formatter:function(value, row, index){ 
			var value="";
			switch (row.type) {  
			  case 1:  
				value = '<span class="badge bg-success">宝石</span>' ;
				break;  
			  case 2:  
				value = '<span class="badge bg-warning">宠物物品</span>' ;
				break;  
			  case 3:  
				value = '<span class="badge bg-secondary">任务物品</span>' ;
				break;  
			  case 4:  
				value = '<span class="badge bg-purple">食品</span>' ;
				break;  
			  case 5:  
				value = '<span class="badge bg-cyan">杂货</span>' ;
				break;  
			  case 6:  
				value = '<span class="badge bg-brown">装备</span>' ;
				break;  
			  case 7:  
				value = '<span class="badge bg-primary">称谓</span>' ;
				break;  
			  case 8:  
				value = '<span class="badge bg-info">奖励</span>' ;
				break;  
			  case 9:  
				value = '<span class="badge bg-danger">宠物技能</span>' ;
				break;  
			  case 10:  
				value = '<span class="badge bg-dark">宠物</span>' ;
				break;  
			  case 11:  
				value = '<span class="badge bg-pink">特技特效</span>' ;
				break;  
			  default:  
				value = '<span class="badge bg-indigo">未知</span>' ;
				break;  
			}
			return value;
		}
    }];
    
	var $searchForm = $('#itemSearchForm');
	$('table').bootstrapTable({
		...table,
		// 自定义的查询参数
		queryParams: function (params) {
			return {
				// 每页数据量
				limit: params.limit,
				// sql语句起始索引
				offset: params.offset,
				page: (params.offset / params.limit) + 1,
				// 排序的列名
				sort: params.sort,
				// 排序方式 'asc' 'desc'
				sortOrder: params.order,
				name: $.trim($searchForm.find('input[name="name"]').val() || ''),
				itemid: $.trim($searchForm.find('input[name="itemid"]').val() || ''),
				type: $searchForm.find('select[name="type"]').val() || 0
			};
		},
		columns,
        onLoadSuccess: function(data){
            $("[data-bs-toggle='tooltip']").tooltip();
        }
	});

	// 搜索/重置：阻止表单跳转，改为刷新表格数据
	$searchForm.on('submit', function (e) {
		e.preventDefault();
		$('#table').bootstrapTable('refresh', {pageNumber: 1});
	});
	$searchForm.on('reset', function () {
		setTimeout(function () {
			$('#table').bootstrapTable('refresh', {pageNumber: 1});
		}, 0);
	});
</script>

</body>
</html>
