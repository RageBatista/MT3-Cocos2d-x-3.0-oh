<?php /*a:1:{s:57:"/www/wwwroot/web_app/app/admin/view/player/bind_list.html";i:1777196143;}*/ ?>
<!DOCTYPE html>
<html lang="zh">

<head>
	<link rel="stylesheet" type="text/css" href="/static/template/css/materialdesignicons.min.css">
	<link rel="stylesheet" type="text/css" href="/static/template/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="/static/template/css/style.min.css">
	<!--表格插件css-->
	<link rel="stylesheet" href="/static/template/js/bootstrap-table/bootstrap-table.min.css">
</head>

<body>
	<div class="container-fluid">

		<div class="row">

			<div class="col-lg-12">
				<div class="card">
					<header class="card-header">
						<div class="card-title">绑定列表</div>
					</header>
					<div class="card-body">
						<div class="card-search mb-2-5">
							<form class="search-form" onsubmit="return false;" role="form">

								<div class="row">
									<div class="col-md-3">
										<div class="row">
											<label class="col-sm-2 col-form-label">账号</label>
											<div class="col-sm-10">
												<input type="text" class="form-control pull-left" name="username"
													value="" placeholder="账号" />
											</div>
										</div>
									</div>
									<div class="col-md-3">
										<div class="row">
											<label class="col-sm-2 col-form-label">角色ID</label>
											<div class="col-sm-10">
												<input type="text" class="form-control pull-left" name="playerid"
													value="" placeholder="账号" />
											</div>
										</div>
									</div>
									<div class="col-md-3">
										<div class="row">
											<label class="col-sm-4 col-form-label">角色名称</label>
											<div class="col-sm-8">
												<input type="text" class="form-control pull-left" name="playername"
													value="" placeholder="账号" />
											</div>
										</div>
									</div>
									<div class="col-md-3">
										<button type="button" class="btn btn-primary me-1"
											onclick="searchBind()">搜索</button>
										<button type="button" class="btn btn-default"
											onclick="resetBindSearch()">重置</button>
									</div>
								</div>

							</form>
						</div>
						<div id="toolbar" class="toolbar-btn-action"></div>
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
	<script src="/static/template/alert/sweetalert2.all.min.js"></script>
	<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>

	<script>
		// ===== 安全修复：XSS 防护函数（全局作用域）=====
		function htmlEncode(str) {
			if (str === null || str === undefined) return '';
			return String(str).replace(/[&<>"'\/]/g, function (s) {
				return {
					"&": "&amp;",
					"<": "&lt;",
					">": "&gt;",
					'"': "&quot;",
					"'": "&#39;",
					"/": "&#x2F;"
				}[s];
			});
		}

		var searchDefaults = {
			username: '',
			playerid: '',
			playername: ''
		};

		if (window.lyearSearchState && typeof lyearSearchState.apply === 'function') {
			lyearSearchState.apply(searchDefaults);
		}
		$('.search-form').on('submit', function (event) {
			event.preventDefault();
			searchBind();
		});

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
		var table = Object.assign({}, icon, pagination, button, {
			classes: 'table table-bordered table-hover table-striped lyear-table',
			// 请求地址
			url: '/index.php?s=/<?php echo htmlentities($app); ?>/player/bind_list_table',
			// 唯一ID字段
			uniqueId: 'id',
			// 每行的唯一标识字段
			idField: 'id',
			// 是否启用点击选中行
			clickToSelect: true,
			// 是否显示详细视图和列表视图的切换按钮(clickToSelect同时设置为true时点击会报错)
			// showToggle: true,
			// 请求得到的数据类型
			dataType: 'json',
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
			sortOrder: "asc"
		});

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
			field: 'username',
			align: 'center',
			title: '所属账号',  // 自定义方法
			formatter: function (value, row, index) {
				var username = (row.username || '').toString().trim();
				if (!username) {
					return '<span class="btn btn-warning btn-sm">账号待同步</span>';
				}
				var safeUsername = htmlEncode(username);
				return '<a href="/index.php?s=/<?php echo htmlentities($app); ?>/player/list&username=' + encodeURIComponent(username) + '&lastagent=0"><span class="btn btn-primary">' + safeUsername + '</span></a>';
			}
		}, {
			field: 'name',
			align: 'center',
			title: '所属大区',
		}, {
			field: 'playerid',
			align: 'center',
			title: '角色ID'
		}, {
			field: 'playername',
			align: 'center',
			title: '角色名称'
		}, {
			field: 'gm',
			align: 'center',
			title: 'GM操作',
			formatter: function (value, row, index) {
				return '<a href="/index.php?s=/<?php echo htmlentities($app); ?>/gm/player&playerid=' + row.playerid + '"><span class="btn btn-danger">点击操作</span></a>' +
					'<a href="#!" class="btn btn-primary modify-btn"   data-bs-toggle="tooltip">补充充值</a>';
			},
			events: {
				'click .modify-btn': function (event, value, row, index) {
					event.stopPropagation();
					modifyUser(row);
				},
			}
		}];
		function modifyUser(row) {
			// HTML 转义函数，防止 XSS
			function htmlEncode(str) {
				return String(str).replace(/[&<>"'\/]/g, function (s) {
					return {
						"&": "&amp;",
						"<": "&lt;",
						">": "&gt;",
						'"': "&quot;",
						"'": "&#39;",
						"/": "&#x2F;"
					}[s];
				});
			}

			var id = row.id;
			var playername = htmlEncode(row.playername || '未知');
			var playerid = htmlEncode(row.playerid || '未知');

			// 使用 Sweetalert2 的 HTML 功能创建输入框表单
			Swal.fire({
				title: '补充充值',
				html: '<div style="text-align: left; padding: 10px;">' +
					'<div style="background: #e3f2fd; padding: 12px; border-radius: 8px; margin-bottom: 20px;">' +
					'<p style="margin: 5px 0;"><strong>角色名称:</strong> ' + playername + '</p>' +
					'<p style="margin: 5px 0;"><strong>角色ID:</strong> ' + playerid + '</p>' +
					'</div>' +
					'<div style="margin-bottom: 20px;">' +
					'<label style="display: block; margin-bottom: 8px; font-weight: bold; color: #333;">补充金额 (元)</label>' +
					'<input id="money-input" type="number" class="swal2-input" placeholder="请输入要补充的金额" min="0" step="0.01" style="width: 90%; margin: 0; height: 45px; font-size: 16px;">' +
					'</div>' +
					'</div>',
				icon: 'info',
				showCancelButton: true,
				confirmButtonText: '确认补充充值',
				cancelButtonText: '取消',
				confirmButtonColor: '#28a745',
				cancelButtonColor: '#6c757d',
				width: '450px',
				focusConfirm: false,
				preConfirm: function () {
					var money = document.getElementById('money-input').value;

					if (!money || money <= 0) {
						Swal.showValidationMessage('请输入有效的充值金额');
						return false;
					}

					return { money: money };
				}
			}).then(function (result) {
				if (result.isConfirmed) {
					var data = result.value;

					// 显示加载状态
					Swal.fire({
						title: '处理中...',
						html: '正在提交补充充值请求',
						allowOutsideClick: false,
						didOpen: function () {
							Swal.showLoading();
						}
					});

					// 提交到后端
					$.post("/index.php?s=/<?php echo htmlentities($app); ?>/player/modify", {
						id: id,
						money: data.money,
						csrf_token: "<?php echo htmlentities($csrf_token); ?>"
					}, function (res) {
						console.log(res);
						if (res.code == 1) {
							Swal.fire({
								icon: 'success',
								title: '补充充值成功',
								html: '<div style="text-align: left; padding: 10px;">' +
									'<p><strong>角色:</strong> ' + playername + ' (ID: ' + playerid + ')</p>' +
									'<p><strong>补充金额:</strong> ' + htmlEncode(data.money) + ' 元</p>' +
									'</div>',
								confirmButtonColor: '#28a745'
							}).then(function () {
								// 刷新表格
								$('#table').bootstrapTable('refresh');
							});
						} else {
							Swal.fire({
								icon: 'error',
								title: '操作失败',
								text: res.msg,
								confirmButtonColor: '#dc3545'
							});
						}
					}).fail(function () {
						Swal.fire({
							icon: 'error',
							title: '网络错误',
							text: '请求失败，请检查网络连接',
							confirmButtonColor: '#dc3545'
						});
					});
				}
			});
		}

		var $bindTable = $('#table');
		if ($bindTable.data('bootstrap.table')) {
			$bindTable.bootstrapTable('destroy');
		}
		$bindTable.bootstrapTable(Object.assign({}, table, {
			// 自定义的查询参数（重构：搜索参数通过请求传递，不再依赖 Session）
			queryParams: function (params) {
				return {
					limit: params.limit,
					offset: params.offset,
					page: (params.offset / params.limit) + 1,
					sort: params.sort,
					sortOrder: params.order,
					username: $('input[name="username"]').val(),
					playerid: $('input[name="playerid"]').val(),
					playername: $('input[name="playername"]').val()
				};
			},
			columns: columns,
			onLoadSuccess: function (data) {
				$("[data-bs-toggle='tooltip']").tooltip();
			}
		}));

		function searchBind() {
			if (window.lyearSearchState && typeof lyearSearchState.sync === 'function') {
				lyearSearchState.sync({
					username: $('input[name="username"]').val(),
					playerid: $('input[name="playerid"]').val(),
					playername: $('input[name="playername"]').val()
				}, searchDefaults);
			}
			$('#table').bootstrapTable('refresh', { pageNumber: 1 });
		}

		function resetBindSearch() {
			$('input[name="username"]').val('');
			$('input[name="playerid"]').val('');
			$('input[name="playername"]').val('');
			if (window.lyearSearchState && typeof lyearSearchState.sync === 'function') {
				lyearSearchState.sync(searchDefaults, searchDefaults);
			}
			$('#table').bootstrapTable('refresh', { pageNumber: 1 });
		}
	</script>

</body>

</html>
