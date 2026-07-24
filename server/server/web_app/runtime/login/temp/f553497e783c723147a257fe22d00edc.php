<?php /*a:1:{s:52:"/www/wwwroot/web_app/app/login/view/index/index.html";i:1772268863;}*/ ?>
<html lang="zh">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
	<meta name="author" content="yinq">
	<title>登录 - <?php echo htmlentities($config['name']); ?></title>
	<link rel="shortcut icon" type="image/x-icon" href="/static/template/favicon.ico">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="apple-touch-fullscreen" content="yes">
	<meta name="apple-mobile-web-app-status-bar-style" content="default">
	<link rel="stylesheet" type="text/css" href="/static/template/css/materialdesignicons.min.css">
	<link rel="stylesheet" type="text/css" href="/static/template/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="/static/template/css/animate.min.css">
	<link rel="stylesheet" type="text/css" href="/static/template/css/style.min.css">
	<!--通知弹窗-->
	<link rel="stylesheet" type="text/css" href="/static/template/alert/sweetalert2.min.css">
	<script src="/static/template/alert/sweetalert2.all.min.js"></script>
	<style>
		.signin-form .has-feedback {
			position: relative;
		}

		.signin-form .has-feedback .form-control {
			padding-left: 36px;
		}

		.signin-form .has-feedback .mdi {
			position: absolute;
			top: 0;
			left: 0;
			right: auto;
			width: 36px;
			height: 36px;
			line-height: 36px;
			z-index: 4;
			color: #dcdcdc;
			display: block;
			text-align: center;
			pointer-events: none;
		}

		.signin-form .has-feedback.row .mdi {
			left: 15px;
		}
	</style>
</head>

<body class="center-vh" style="background-image: url(<?php echo htmlentities($config['background']); ?>); background-size: cover;">
	<div class="card card-shadowed p-5 mb-0 mr-2 ml-2">
		<div class="text-center mb-3">
			<a href="#"> <img alt="light year admin" src="<?php echo htmlentities($config['logo']); ?>"> </a>
		</div>

		<form action="/index.php?s=/login/index/submit" method="post" class="signin-form needs-validation" novalidate>
			<input type="hidden" name="csrf_token" value="<?php echo htmlentities($csrf_token); ?>" />
			<div class="mb-3 has-feedback">
				<span class="mdi mdi-account" aria-hidden="true"></span>
				<input type="text" class="form-control" value="" id="username" name="username" placeholder="用户名"
					required>
			</div>

			<div class="mb-3 has-feedback">
				<span class="mdi mdi-lock" aria-hidden="true"></span>
				<input type="password" class="form-control" value="" id="password" name="password" placeholder="密码"
					required>
			</div>

			<div class="mb-3 has-feedback row">
				<div class="col-7">
					<span class="mdi mdi-check-all form-control-feedback" aria-hidden="true"></span>
					<input type="text" name="captcha" class="form-control" value="" placeholder="验证码" required>
				</div>
				<div class="col-5 text-right">
					<img src="<?php echo captcha_src(); ?>" class="pull-right" id="captcha" style="cursor: pointer;"
						onclick="this.src=this.src+'?d='+Math.random();" title="点击刷新" alt="captcha">
				</div>
			</div>

			<div class="mb-3 d-grid">
				<button class="btn btn-primary" type="submit">立即登录</button>
			</div>
		</form>

		<p class="text-center text-muted mb-0"><?php echo htmlentities($config['name']); ?></p>
	</div>

	<script type="text/javascript" src="/static/template/js/jquery.min.js"></script>
	<script type="text/javascript" src="/static/template/js/popper.min.js"></script>
	<script type="text/javascript" src="/static/template/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/static/template/js/lyear-loading.js"></script>
	<script type="text/javascript" src="/static/template/js/bootstrap-notify.min.js"></script>
	<script type="text/javascript">
		var loader;
		$(document).ajaxStart(function () {
			$("button:submit").html('登录中...').attr("disabled", true);
			loader = $('button:submit').lyearloading({
				opacity: 0.2,
				spinnerSize: 'nm'
			});
		}).ajaxStop(function () {
			loader.destroy();
			$("button:submit").html('立即登录').attr("disabled", false);
		});
		$('.signin-form').on('submit', function (event) {
			if ($(this)[0].checkValidity() === false) {
				event.preventDefault();
				event.stopPropagation();
				$(this).addClass('was-validated');
				return false;
			}
			var $data = $(this).serialize();

			$.post($(this).attr('action'), $data, function (res) {
				// 超级管理员需要二次验证 (code=99)
				if (res.code == 99) {
					// 弹出二次验证对话框
					Swal.fire({
						title: '超级管理员验证',
						html: '<p class="text-danger mb-3">检测到超级管理员登录，需要进行二次验证</p>' +
							'<input type="password" id="swal-super-key" class="form-control" placeholder="请输入超级管理员验证密钥" autocomplete="off">',
						icon: 'warning',
						showCancelButton: true,
						confirmButtonText: '验证',
						cancelButtonText: '取消',
						allowOutsideClick: false,
						preConfirm: function () {
							var superKey = document.getElementById('swal-super-key').value;
							if (!superKey) {
								Swal.showValidationMessage('请输入验证密钥');
								return false;
							}
							return superKey;
						}
					}).then(function (result) {
						if (result.isConfirmed) {
							// 用户输入了验证密钥，提交二次验证
							var verifyData = $data + '&super_admin_key=' + encodeURIComponent(result.value) + '&verify_step=2';
							$.post('/index.php?s=/login/index/submit', verifyData, function (verifyRes) {
								if (verifyRes.code == 1) {
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
									Toast.fire({
										icon: "success",
										title: verifyRes.msg
									});
									setTimeout(function () {
										location.href = '/index.php?s=/admin';
									}, 1500);
								} else {
									Swal.fire({
										icon: 'error',
										title: '验证失败',
										text: verifyRes.msg,
										confirmButtonText: '重试'
									}).then(function () {
										location.reload(); // 验证失败后刷新页面
									});
								}
							}).fail(function () {
								Swal.fire({
									icon: 'error',
									title: '服务异常',
									text: '二次验证请求失败'
								});
							});
						}
					});
				}
				else if (res.code == 1) {
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
					Toast.fire({
						icon: "success",
						title: res.msg
					});
					setTimeout(function () {
						location.href = '/index.php?s=/admin';
					}, 1500);
				} else if (res.code == 2) {
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
					Toast.fire({
						icon: "success",
						title: res.msg
					});
					setTimeout(function () {
						location.href = '/index.php?s=/agent';
					}, 1500);
				} else {
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
					Toast.fire({
						icon: "error",
						title: res.msg
					});
					//setTimeout("self.location.reload();",1500);
				}
			}).fail(function () {
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
				Toast.fire({
					icon: "question",
					title: '服务异常'
				});
				//setTimeout("self.location.reload();",1500);
			});

			return false;
		});
	</script>
</body>

</html>