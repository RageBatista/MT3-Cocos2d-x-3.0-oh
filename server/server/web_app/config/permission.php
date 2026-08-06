<?php

return [
    // 权限点映射：应用.控制器.方法 => 允许的管理员类型
    // type: 1=admin, 2=agent
    'rules' => [
        'admin.gmcdk.cdkgenerate' => [1],
        'admin.gmcdk.cdkdelete' => [1],
        'admin.gmcdk.cdkupdateuid' => [1],
        'admin.gmcdk.cdkupdatepass' => [1],
        'admin.gmcleandata.docleandata' => [1],
        'admin.gmcleandata.docleanall' => [1],
        'admin.gmplayer.player' => [1],
        'admin.gmplayer.playersub' => [1],
        'admin.gmserver.server_cmd' => [1],
        'admin.gmserver.serversub' => [1],
        'admin.gmmail.server_mail' => [1],
        'admin.gmmail.servermailsub' => [1],
        'admin.gmcleandata.clean_data' => [1],
        'admin.gmcleandata.cleandatasub' => [1],
        'admin.gmcleandata.querycleandata' => [1],
        'admin.gmcleandata.getdatastatistics' => [1],
        'admin.gmcdk.cdk' => [1],
        'admin.gmcdk.cdkquery' => [1],
        'admin.gmcdk.cdklistunused' => [1],
        'admin.gmcdk.cdklistused' => [1],
        'admin.gmcdk.cdkstats' => [1],
        'admin.configure.notice' => [1],
        'admin.configure.server' => [1],
        'admin.player.save' => [1],
        'agent.player.status' => [1, 2],
    ],
];
