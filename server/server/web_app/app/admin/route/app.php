<?php
declare(strict_types=1);

use think\facade\Route;

require_once dirname(__DIR__, 3) . '/route/web_admin_route_helper.php';

web_admin_register_module_routes('admin');
