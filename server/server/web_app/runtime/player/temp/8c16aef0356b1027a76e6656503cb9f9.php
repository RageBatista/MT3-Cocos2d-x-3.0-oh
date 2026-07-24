<?php /*a:2:{s:51:"/www/wwwroot/web_app/app/player/view/cdk/index.html";i:1772303836;s:54:"/www/wwwroot/web_app/app/player/view/layout/login.html";i:1772303836;}*/ ?>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="<?php echo htmlentities((isset($csrf_token) && ($csrf_token !== '')?$csrf_token:'')); ?>">
    <title>CDK授权 - 玩家服务中心</title>
    <link rel="stylesheet" href="/static/player/css/think-style.css">
    <link rel="stylesheet" href="/static/template/css/materialdesignicons.min.css">
    
</head>

<body>
    <div class="lyear-wrapper">
        <div class="lyear-login-box">
            <div class="lyear-panel">
                
<div class="lyear-panel-header" style="background: linear-gradient(135deg, #926dde 0%, #6610f2 100%);">
    <h3><i class="mdi mdi-key"></i> CDK授权</h3>
    <p>请输入您的游戏角色ID和CDK进行授权</p>
</div>


                <div class="lyear-panel-body">
                    <?php if(session('error')): ?>
                    <div class="alert alert-danger">
                        <i class="mdi mdi-alert-circle"></i>
                        <?php echo htmlspecialchars(session('error')); ?>
                    </div>
                    <?php endif; if(session('success')): ?>
                    <div class="alert alert-success">
                        <i class="mdi mdi-check-circle"></i>
                        <?php echo htmlspecialchars(session('success')); ?>
                    </div>
                    <?php endif; ?>

                    
<form id="authForm" method="post" action="/player/cdk/auth">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token ?? ''; ?>">

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-identifier"></i> 游戏角色ID（UID）
        </label>
        <input type="number" name="uid" class="form-control" placeholder="请输入游戏角色ID，例如：4097" required>
        <div class="form-hint">UID是游戏内的角色ID，不是账号ID</div>
    </div>

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-key"></i> CDK授权码
        </label>
        <input type="text" name="cdk" class="form-control" placeholder="请输入CDK授权码" required>
        <div class="form-hint">CDK格式：16位或20位字母数字组合</div>
    </div>

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-server"></i> 选择区组
        </label>
        <select name="serverid" class="form-control">
            <option value="">请选择区组</option>
            <?php if(!empty($server_list)): foreach($server_list as $server): ?>
            <option value="<?php echo $server['serverid']; ?>">
                <?php echo htmlspecialchars($server['name']); if(!empty($server['groupname'])): ?>
                (
                <?php echo htmlspecialchars($server['groupname']); ?>)
                <?php endif; ?>
            </option>
            <?php endforeach; ?>
            <?php endif; ?>
        </select>
    </div>

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-lock"></i> 授权密码（可选）
        </label>
        <input type="password" name="authpass" class="form-control" placeholder="设置授权密码，方便下次登录">
        <div class="form-hint">设置后下次可使用授权密码直接登录</div>
    </div>

    <div class="form-group">
        <button type="submit" class="btn btn-primary btn-block btn-lg">
            <i class="mdi mdi-check-circle"></i> 立即授权
        </button>
    </div>
</form>

<div class="divider">
    <span>已有授权登录</span>
</div>

<form id="existingForm" method="post" action="/player/cdk/existing">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token ?? ''; ?>">

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-identifier"></i> 已授权角色ID（UID）
        </label>
        <input type="number" name="uid" class="form-control" placeholder="请输入已授权的角色ID" required>
    </div>

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-lock"></i> 授权密码
        </label>
        <input type="password" name="authpass" class="form-control" placeholder="请输入授权密码" required>
    </div>

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-server"></i> 选择区组（可选）
        </label>
        <select name="serverid" class="form-control">
            <option value="">默认使用当前授权区组</option>
            <?php if(!empty($server_list)): foreach($server_list as $server): ?>
            <option value="<?php echo $server['serverid']; ?>">
                <?php echo htmlspecialchars($server['name']); if(!empty($server['groupname'])): ?>
                (
                <?php echo htmlspecialchars($server['groupname']); ?>)
                <?php endif; ?>
            </option>
            <?php endforeach; ?>
            <?php endif; ?>
        </select>
    </div>

    <div class="form-group">
        <button type="submit" class="btn btn-outline-primary btn-block btn-lg">
            <i class="mdi mdi-login"></i> 使用已有授权登录
        </button>
    </div>
</form>

<div class="divider">
    <span>其他选项</span>
</div>

<div class="other-links" style="border-top: none; padding-top: 0;">
    <p>
        <a href="/player/auth/login" style="margin-right: 15px;">
            <i class="mdi mdi-login"></i> 账号密码登录
        </a>
        <a href="/player/auth/register">
            <i class="mdi mdi-account-plus"></i> 注册账号
        </a>
    </p>
</div>

                </div>

                
<div class="lyear-panel-footer">
    <small style="color: #6c757d;">
        <i class="mdi mdi-information"></i> 授权成功后可在控制台管理您的游戏角色
    </small>
</div>

            </div>
        </div>
    </div>

    <!-- Toast 容器 -->
    <div class="toast-container" id="toastContainer"></div>

    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"
        integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
    <script>
        var globalCsrfToken = (document.querySelector('meta[name="csrf-token"]') || {}).content || '';
        if (globalCsrfToken) {
            $.ajaxSetup({
                headers: {
                    'X-CSRF-TOKEN': globalCsrfToken
                }
            });
        }

        // Toast 通知函数
        function showToast(message, type) {
            type = type || 'info';
            var container = document.getElementById('toastContainer');
            var toast = document.createElement('div');
            toast.className = 'toast toast-' + type;
            var iconMap = {
                'success': 'mdi-check-circle',
                'error': 'mdi-alert-circle',
                'warning': 'mdi-alert',
                'info': 'mdi-information'
            };
            toast.innerHTML = '<i class="mdi ' + (iconMap[type] || 'mdi-information') + '"></i> ' + message;
            container.appendChild(toast);

            toast.addEventListener('click', function () {
                toast.classList.add('toast-out');
                setTimeout(function () { toast.remove(); }, 250);
            });

            setTimeout(function () {
                if (toast.parentNode) {
                    toast.classList.add('toast-out');
                    setTimeout(function () { toast.remove(); }, 250);
                }
            }, 3500);
        }

        // 通用 AJAX 表单提交
        function ajaxSubmit(formSelector, options) {
            options = options || {};
            $(formSelector).on('submit', function (e) {
                e.preventDefault();
                var $form = $(this);
                var $csrfInput = $form.find('input[name="csrf_token"]');
                if (!$csrfInput.length && globalCsrfToken) {
                    $csrfInput = $('<input type="hidden" name="csrf_token">').appendTo($form);
                }
                if ($csrfInput.length && !$csrfInput.val() && globalCsrfToken) {
                    $csrfInput.val(globalCsrfToken);
                }
                var $btn = $form.find('button[type="submit"]');
                var originalText = $btn.html();
                $btn.prop('disabled', true).html('<i class="mdi mdi-loading mdi-spin"></i> 处理中...');

                $.post($form.attr('action'), $form.serialize(), function (res) {
                    if (res.code === 1) {
                        showToast(res.msg || '操作成功', 'success');
                        if (options.onSuccess) {
                            options.onSuccess(res);
                        } else if (options.redirect) {
                            setTimeout(function () {
                                window.location.href = options.redirect;
                            }, 600);
                        } else {
                            $btn.html('<i class="mdi mdi-check"></i> 成功');
                            setTimeout(function () {
                                $btn.prop('disabled', false).html(originalText);
                            }, 1500);
                        }
                    } else {
                        showToast(res.msg || '操作失败', 'error');
                        $btn.prop('disabled', false).html(originalText);
                    }
                }, 'json').fail(function () {
                    showToast('网络请求失败，请重试', 'error');
                    $btn.prop('disabled', false).html(originalText);
                });
            });
        }
    </script>
    
<script>
    ajaxSubmit('#authForm', {
        redirect: '/player/cdk/dashboard'
    });

    ajaxSubmit('#existingForm', {
        redirect: '/player/cdk/dashboard'
    });
</script>

</body>

</html>
