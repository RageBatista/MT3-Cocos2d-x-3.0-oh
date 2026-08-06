<?php /*a:1:{s:57:"/www/wwwroot/web_app/app/admin/view/player/role_list.html";i:1777196143;}*/ ?>
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
                        <div class="card-title">角色管理</div>
                    </header>
                    <div class="card-body">
                        <div class="card-search mb-2-5">
                            <form class="search-form" onsubmit="return false;" role="form">

                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="row">
                                            <label class="col-sm-4 col-form-label">角色ID</label>
                                            <div class="col-sm-8">
                                                <input type="text" class="form-control pull-left" name="roleid" value=""
                                                    placeholder="角色ID" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="row">
                                            <label class="col-sm-4 col-form-label">角色名称</label>
                                            <div class="col-sm-8">
                                                <input type="text" class="form-control pull-left" name="name" value=""
                                                    placeholder="角色名称" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="row">
                                            <label class="col-sm-4 col-form-label">所属账号</label>
                                            <div class="col-sm-8">
                                                <input type="text" class="form-control pull-left" name="username"
                                                    value="" placeholder="所属账号" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="row">
                                            <label class="col-sm-2 col-form-label"></label>
                                            <div class="col-sm-10">
                                                <button type="button" class="btn btn-primary"
                                                    onclick="searchRole()">搜索</button>
                                                <button type="button" class="btn btn-secondary"
                                                    onclick="resetSearch()">重置</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <table id="roleTable"></table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="/static/template/js/jquery.min.js"></script>
    <script type="text/javascript" src="/static/template/js/popper.min.js"></script>
    <script type="text/javascript" src="/static/template/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/static/template/js/main.min.js"></script>
    <!--表格插件-->
    <script src="/static/template/js/bootstrap-table/bootstrap-table.min.js"></script>
    <script src="/static/template/js/bootstrap-table/locale/bootstrap-table-zh-CN.min.js"></script>

    <!--通知弹窗-->
    <link rel="stylesheet" type="text/css" href="/static/template/alert/sweetalert2.min.css">
    <script src="/static/template/alert/sweetalert2.all.min.js"></script>

    <script type="text/javascript">
        var searchDefaults = {
            roleid: '',
            name: '',
            username: ''
        };

        if (window.lyearSearchState && typeof lyearSearchState.apply === 'function') {
            lyearSearchState.apply(searchDefaults);
        }
        $('.search-form').on('submit', function (event) {
            event.preventDefault();
            searchRole();
        });

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

        // 职业映射
        var professionMap = {
            0: '未知',
            11: '大唐官府',
            12: '方寸山',
            13: '狮驼岭',
            14: '阴曹地府',
            15: '龙宫',
            16: '普陀山',
            17: '魔王寨',
            18: '化生寺',
            19: '月宫',
            20: '女儿村',
            21: '小雷音',
            22: '花果山',
            23: '须弥海',
            24: '盘丝洞'
        };

        // 格式化时间戳
        function formatTimestamp(ts) {
            if (ts === null || ts === undefined || ts === '' || ts == 0) return '-';
            var n = Number(ts);
            if (!isFinite(n) || n <= 0) return '-';
            // 兼容秒(10位)与毫秒(13位)时间戳
            if (n < 100000000000) {
                n = n * 1000;
            }
            var d = new Date(n);
            if (isNaN(d.getTime())) return '-';
            var Y = d.getFullYear();
            var M = ('0' + (d.getMonth() + 1)).slice(-2);
            var D = ('0' + d.getDate()).slice(-2);
            var h = ('0' + d.getHours()).slice(-2);
            var m = ('0' + d.getMinutes()).slice(-2);
            var s = ('0' + d.getSeconds()).slice(-2);
            return Y + '-' + M + '-' + D + ' ' + h + ':' + m + ':' + s;
        }

        $('#roleTable').bootstrapTable({
            url: '/index.php?s=/<?php echo htmlentities($app); ?>/player/role_table',
            method: 'get',
            toolbar: '#toolbar',
            striped: true,
            cache: false,
            pagination: true,
            sortable: false,
            sortOrder: 'desc',
            sidePagination: 'server',
            pageNumber: 1,
            pageSize: 20,
            pageList: [10, 20, 50, 100],
            showRefresh: true,
            showColumns: true,
            clickToSelect: true,
            uniqueId: 'roleid',
            showToggle: true,
            cardView: false,
            smartDisplay: false,
            locale: 'zh-CN',
            formatShowingRows: function (pageFrom, pageTo, totalRows) {
                return '显示第 ' + pageFrom + ' 到第 ' + pageTo + ' 条记录，共 ' + totalRows + ' 条';
            },
            formatRecordsPerPage: function (pageNumber) {
                return '每页显示 ' + pageNumber + ' 条';
            },
            formatNoMatches: function () {
                return '没有找到匹配的记录';
            },
            formatRefresh: function () {
                return '刷新';
            },
            formatColumns: function () {
                return '列';
            },
            formatToggleOn: function () {
                return '显示卡片视图';
            },
            formatToggleOff: function () {
                return '隐藏卡片视图';
            },
            queryParams: function (params) {
                return {
                    limit: params.limit,
                    offset: params.offset,
                    roleid: $('input[name="roleid"]').val(),
                    name: $('input[name="name"]').val(),
                    username: $('input[name="username"]').val()
                };
            },
            columns: [
                {
                    field: 'roleid',
                    title: '角色ID',
                    align: 'center',
                    formatter: function (value) {
                        return htmlEncode(String(value));
                    }
                },
                {
                    field: 'name',
                    title: '角色名称',
                    align: 'center',
                    formatter: function (value) {
                        return htmlEncode(value || '');
                    }
                },
                {
                    field: 'level',
                    title: '等级',
                    align: 'center',
                    formatter: function (value) {
                        if (!value) return '<span class="badge bg-secondary">0</span>';
                        var color = 'secondary';
                        if (value >= 100) color = 'danger';
                        else if (value >= 69) color = 'warning';
                        else if (value >= 40) color = 'primary';
                        else if (value >= 20) color = 'info';
                        return '<span class="badge bg-' + color + '">' + value + '</span>';
                    }
                },
                {
                    field: 'profession',
                    title: '职业',
                    align: 'center',
                    formatter: function (value) {
                        if (value === null || value === undefined || value === '') {
                            return '未知';
                        }
                        return htmlEncode(professionMap[value] || ('未知(' + value + ')'));
                    }
                },
                {
                    field: 'username',
                    title: '所属账号',
                    align: 'center',
                    formatter: function (value, row) {
                        if (!value) {
                            var uid = parseInt(row.userid || 0, 10);
                            if (uid > 0) {
                                return '<span class="text-warning">UID:' + uid + '（账号未同步）</span>';
                            }
                            return '<span class="text-muted">无绑定</span>';
                        }
                        return '<a href="/index.php?s=/<?php echo htmlentities($app); ?>/player/list&username=' + encodeURIComponent(value) + '&lastagent=0"><span class="btn btn-sm btn-primary">' + htmlEncode(value) + '</span></a>';
                    }
                },
                {
                    field: 'createtime',
                    title: '创建时间',
                    align: 'center',
                    formatter: function (value) {
                        return formatTimestamp(value);
                    }
                },
                {
                    field: 'lastlogintime',
                    title: '最后登录',
                    align: 'center',
                    formatter: function (value) {
                        return formatTimestamp(value);
                    }
                }
            ]
        });

        function searchRole() {
            if (window.lyearSearchState && typeof lyearSearchState.sync === 'function') {
                lyearSearchState.sync({
                    roleid: $('input[name="roleid"]').val(),
                    name: $('input[name="name"]').val(),
                    username: $('input[name="username"]').val()
                }, searchDefaults);
            }
            $('#roleTable').bootstrapTable('refresh', { pageNumber: 1 });
        }

        function resetSearch() {
            $('input[name="roleid"]').val('');
            $('input[name="name"]').val('');
            $('input[name="username"]').val('');
            if (window.lyearSearchState && typeof lyearSearchState.sync === 'function') {
                lyearSearchState.sync(searchDefaults, searchDefaults);
            }
            $('#roleTable').bootstrapTable('refresh', { pageNumber: 1 });
        }
    </script>
</body>

</html>
