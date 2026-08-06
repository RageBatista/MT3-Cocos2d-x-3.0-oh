<?php /*a:1:{s:52:"/www/wwwroot/web_app/app/admin/view/player/list.html";i:1777196143;}*/ ?>
<!DOCTYPE html>
<html lang="zh">

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
						<div class="card-title">玩家列表</div>
					</header>
					<div class="card-body">
						<div class="card-search mb-2-5">
							<form class="search-form" onsubmit="return false;" role="form">

								<div class="row">
									<div class="col-md-4">
										<div class="row">
											<label class="col-sm-4 col-form-label"><span class="text-danger">*</span>
												账号</label>
											<div class="col-sm-8">
												<input type="text" class="form-control pull-left" name="username"
													value="" placeholder="账号" />
											</div>
										</div>
									</div>
									<div class="col-md-4">
										<div class="row">
											<label class="col-sm-4 col-form-label"><span class="text-danger">*</span>
												所属代理</label>
											<div class="col-sm-8">
												<select name="lastagent" class="form-select">
													<option value="0">全部</option>
													<?php foreach($getAgentList as $key=>$val): ?>
													<option value="<?php echo htmlentities($val['id']); ?>"><?php echo htmlentities($val['username']); ?></option>
													<?php endforeach; ?>
												</select>
											</div>
										</div>
									</div>
									<div class="col-md-4">
										<button type="button" class="btn btn-primary me-1"
											onclick="searchPlayer()">搜索</button>
										<button type="button" class="btn btn-default"
											onclick="resetPlayerSearch()">重置</button>
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


	<script>
		// ===== 安全修复：XSS 防护函数 =====
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

		// ===== 代码优化：公共 Toast 函数（消除重复代码） =====
		function showToast(icon, title) {
			var Toast = Swal.mixin({
				toast: true,
				position: "top",
				showConfirmButton: false,
				timer: 1500,
				timerProgressBar: true,
				didOpen: function (toast) {
					toast.onmouseenter = Swal.stopTimer;
					toast.onmouseleave = Swal.resumeTimer;
				}
			});
			Toast.fire({ icon: icon, title: title });
		}

		var searchDefaults = {
			username: '',
			lastagent: '0'
		};

		if (window.lyearSearchState && typeof lyearSearchState.apply === 'function') {
			lyearSearchState.apply(searchDefaults);
		}
		$('.search-form').on('submit', function (event) {
			event.preventDefault();
			searchPlayer();
		});

		/**
		 * 分页相关的配置
		 **/
		var pagination = {
			sidePagination: "server",
			pageNumber: 1,
			pageSize: 10,
			pageList: [5, 10, 25, 50, 100],
			paginationLoop: true,
			paginationPagesBySide: 2
		};

		/**
		 * 按钮相关配置
		 **/
		var button = {
			buttonsClass: 'default',
			buttonsPrefix: 'btn'
		}

		/**
		 * 图标相关配置
		 **/
		var icon = {
			iconsPrefix: 'mdi',
			iconSize: 'mini',
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
			url: '/index.php?s=/<?php echo htmlentities($app); ?>/player/list_table',
			uniqueId: 'id',
			idField: 'id',
			clickToSelect: true,
			dataType: 'json',
			method: 'post',
			toolbar: '#toolbar',
			pagination: true,
			showColumns: true,
			showRefresh: true,
			showButtonIcons: true,
			showButtonText: false,
			showFullscreen: true,
			showPaginationSwitch: true,
			totalField: 'total',
			undefinedText: '-',
			sortOrder: "asc"
		});

		/**
		 * 列信息
		 **/
		var columns = [{
			field: 'example',
			checkbox: true,
			width: 3,
			widthUnit: 'rem'
		}, {
			field: 'id',
			title: 'ID',
			align: 'center',
			sortable: true,
			sortName: 'id',
			switchable: false,
			width: 3,
			widthUnit: 'rem'
		}, {
			field: 'username',
			align: 'center',
			title: '账号',
			formatter: function (value) {
				return htmlEncode(value);
			}
		}, {
			field: 'last_username',
			align: 'center',
			title: '所属代理',
			formatter: function (value) {
				return htmlEncode(value);
			}
		}, {
			field: 'platform',
			align: 'center',
			title: '所属平台',
			formatter: function (value, row) {
				return '<span class="badge bg-secondary">' + htmlEncode(row.platform) + '</span>';
			}
		}, {
			field: 'username',
			align: 'center',
			title: '查看角色',
			formatter: function (value, row) {
				return '<a href="/index.php?s=/<?php echo htmlentities($app); ?>/player/bindlist/selected/1&username=' + encodeURIComponent(row.username) + '"><span class="btn btn-primary">点击查看</span></a>';
			}
		}, {
			field: 'status',
			title: '状态',
			formatter: function (value, row) {
				if (row.status == '0') {
					return '<a href="#!" class="btn btn-sm btn-danger status-btn" title="禁用" data-bs-toggle="tooltip"><span>禁用</span></a>';
				} else if (row.status == '1') {
					return '<a href="#!" class="btn btn-sm btn-success status-btn" title="正常" data-bs-toggle="tooltip"><span>正常</span></a>';
				}
				return '<span class="badge bg-secondary">未知</span>';
			},
			events: {
				'click .status-btn': function (event, value, row, index) {
					event.stopPropagation();
					statusUser(row);
				}
			}
		}, {
			field: 'zhiboqu',
			title: '直播区权限',
			formatter: function (value, row) {
				if (row.zhiboqu == '0') {
					return '<a href="#!" class="btn btn-sm btn-danger zhiboqu-btn" title="禁用" data-bs-toggle="tooltip"><span>禁用</span></a>';
				} else if (row.zhiboqu == '1') {
					return '<a href="#!" class="btn btn-sm btn-success zhiboqu-btn" title="正常" data-bs-toggle="tooltip"><span>正常</span></a>';
				}
				return '<span class="badge bg-secondary">未知</span>';
			},
			events: {
				'click .zhiboqu-btn': function (event, value, row, index) {
					event.stopPropagation();
					zhiboquUser(row);
				}
			}
		}, {
			field: 'operate',
			title: '操作',
			formatter: function () {
				return '<a href="#!" class="btn btn-sm btn-default me-1 edit-btn" title="编辑" data-bs-toggle="tooltip"><i class="mdi mdi-pencil"></i></a>' +
					'<a href="#!" class="btn btn-sm btn-default del-btn" title="删除" data-bs-toggle="tooltip"><i class="mdi mdi-window-close"></i></a>';
			},
			events: {
				'click .edit-btn': function (event, value, row, index) {
					event.stopPropagation();
					editUser(row);
				},
				'click .del-btn': function (event, value, row, index) {
					event.stopPropagation();
					delUser(row);
				}
			}
		}];

		// 操作方法 - 编辑
		function editUser(row) {
			location.href = '/index.php?s=/<?php echo htmlentities($app); ?>/player/edit&id=' + parseInt(row.id);
		}

		// 操作方法 - 删除（增加二次确认）
		function delUser(row) {
			Swal.fire({
				title: '确认删除？',
				text: '确定要删除玩家 "' + htmlEncode(row.username) + '" 吗？此操作不可撤销。',
				icon: 'warning',
				showCancelButton: true,
				confirmButtonColor: '#d33',
				cancelButtonColor: '#3085d6',
				confirmButtonText: '确定删除',
				cancelButtonText: '取消'
			}).then(function (result) {
				if (result.isConfirmed) {
					$.post("/index.php?s=/<?php echo htmlentities($app); ?>/player/del", { id: parseInt(row.id), csrf_token: "<?php echo htmlentities($csrf_token); ?>" }, function (res) {
						if (res.code == 1) {
							showToast("success", res.msg);
							setTimeout(function () { $('#table').bootstrapTable('refresh'); }, 1000);
						} else {
							showToast("error", res.msg);
						}
					}).fail(function () {
						showToast("question", "服务异常");
					});
				}
			});
		}

		$('table').bootstrapTable(Object.assign({}, table, {
			queryParams: function (params) {
				return {
					limit: params.limit,
					offset: params.offset,
					page: (params.offset / params.limit) + 1,
					sort: params.sort,
					sortOrder: params.order,
					username: $('input[name="username"]').val(),
					lastagent: $('select[name="lastagent"]').val()
				};
			},
			columns: columns,
			onLoadSuccess: function (data) {
				$("[data-bs-toggle='tooltip']").tooltip();
			}
		}));

		function searchPlayer() {
			if (window.lyearSearchState && typeof lyearSearchState.sync === 'function') {
				lyearSearchState.sync({
					username: $('input[name="username"]').val(),
					lastagent: $('select[name="lastagent"]').val()
				}, searchDefaults);
			}
			$('#table').bootstrapTable('refresh', { pageNumber: 1 });
		}

		function resetPlayerSearch() {
			$('input[name="username"]').val('');
			$('select[name="lastagent"]').val('0');
			if (window.lyearSearchState && typeof lyearSearchState.sync === 'function') {
				lyearSearchState.sync(searchDefaults, searchDefaults);
			}
			$('#table').bootstrapTable('refresh', { pageNumber: 1 });
		}

		// 操作方法 - 状态
		function statusUser(row) {
			$.post("/index.php?s=/<?php echo htmlentities($app); ?>/player/status", { id: parseInt(row.id), csrf_token: "<?php echo htmlentities($csrf_token); ?>" }, function (res) {
				if (res.code == 1) {
					showToast("success", res.msg);
					setTimeout(function () { $('#table').bootstrapTable('refresh'); }, 1000);
				} else {
					showToast("error", res.msg);
				}
			}).fail(function () {
				showToast("question", "服务异常");
			});
		}

		// 操作方法 - 直播区
		function zhiboquUser(row) {
			$.post("/index.php?s=/<?php echo htmlentities($app); ?>/player/zhiboqu", { id: parseInt(row.id), csrf_token: "<?php echo htmlentities($csrf_token); ?>" }, function (res) {
				if (res.code == 1) {
					showToast("success", res.msg);
					setTimeout(function () { $('#table').bootstrapTable('refresh'); }, 1000);
				} else {
					showToast("error", res.msg);
				}
			}).fail(function () {
				showToast("question", "服务异常");
			});
		}
	</script>

</body>

</html>
