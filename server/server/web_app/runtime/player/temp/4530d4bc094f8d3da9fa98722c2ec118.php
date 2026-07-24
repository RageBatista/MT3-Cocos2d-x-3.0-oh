<?php /*a:2:{s:52:"/www/wwwroot/web_app/app/player/view/auth/login.html";i:1772303836;s:54:"/www/wwwroot/web_app/app/player/view/layout/login.html";i:1772303836;}*/ ?>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="<?php echo htmlentities((isset($csrf_token) && ($csrf_token !== '')?$csrf_token:'')); ?>">
    <title>玩家服务中心</title>
    <link rel="stylesheet" href="/static/player/css/think-style.css">
    <link rel="stylesheet" href="/static/template/css/materialdesignicons.min.css">
    
</head>

<body>
    <div class="lyear-wrapper">
        <div class="lyear-login-box">
            <div class="lyear-panel">
                
<div class="lyear-panel-header" style="background: #fff; padding: 24px; border-bottom: 1px solid #f0f0f0;">
    <img src="<?php echo htmlspecialchars($config['logo'] ?? '/static/updata/logo.png'); ?>" alt="站点Logo"
        style="max-width: 180px; width: auto; height: auto;">
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

                    
<form id="loginForm" method="post" action="/player/auth/doLogin">
    <input type="hidden" name="csrf_token" value="<?php echo htmlentities((isset($csrf_token) && ($csrf_token !== '')?$csrf_token:'')); ?>">

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-account"></i> 账号
        </label>
        <input type="text" class="form-control" name="username" placeholder="请输入账号（6-18位字母+数字）" required>
    </div>

    <div class="form-group">
        <label class="form-label">
            <i class="mdi mdi-lock"></i> 密码
        </label>
        <input type="password" class="form-control" name="password" placeholder="请输入密码（6-18位字母+数字）" required>
    </div>

    <div class="form-group">
        <button type="submit" class="btn btn-primary btn-block btn-lg">
            <i class="mdi mdi-login"></i> 登录
        </button>
    </div>
</form>

<div class="divider">
    <span>其他登录方式</span>
</div>

<div class="other-links" style="border-top: none; padding-top: 0;">
    <p>
        <a href="/player/cdk/index" class="btn btn-success btn-block">
            <i class="mdi mdi-key"></i> CDK授权登录
        </a>
    </p>
</div>

                </div>

                
<div class="lyear-panel-footer">
    <a href="/player/auth/register"><i class="mdi mdi-account-plus"></i> 注册账号</a>
    <span style="margin: 0 15px; color: #dee2e6;">|</span>
    <a href="/player/auth/forgot"><i class="mdi mdi-help-circle"></i> 忘记密码</a>
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
    ajaxSubmit('#loginForm', {
        redirect: '/player/index'
    });
</script>

</body>

</html>
