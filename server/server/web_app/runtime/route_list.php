Route List
+-------------------------------------------+----------------------------------------+----------+----------------------------------------+
| Rule                                      | Route                                  | Method   | Name                                   |
+-------------------------------------------+----------------------------------------+----------+----------------------------------------+
| think                                     | <Closure>                              | get      |                                        |
| hello/<name>                              | index/hello                            | get      | index/hello                            |
|                                           | index.Index/index                      | get|head | index.Index/index                      |
| <MISS>                                    | <Closure>                              | *        |                                        |
|                                           | Index/index                            | get|head | Index/index                            |
| login                                     | login.Index/index                      | get|head | login.Index/index                      |
| login/                                    | login.Index/index                      | get|head | login.Index/index                      |
| login/index                               | login.Index/index                      | get|head | login.Index/index                      |
| login/index                               | <Closure>                              | get      |                                        |
| login/index                               | <Closure>                              | get      |                                        |
| login/submit                              | login.Index/submit                     | post     | login.Index/submit                     |
| login/index/submit                        | login.Index/submit                     | post     | login.Index/submit                     |
| login/index/submit                        | <Closure>                              | post     |                                        |
| login/index/submit                        | <Closure>                              | post     |                                        |
| admin                                     | admin.Index/index                      | get|head | admin.Index/index                      |
| admin/index                               | admin.Index/index                      | get|head | admin.Index/index                      |
| admin/index/worker                        | admin.Index/worker                     | get|head | admin.Index/worker                     |
| admin/index/my                            | admin.Index/my                         | get|head | admin.Index/my                         |
| admin/index/logout                        | admin.Index/logout                     | get|head | admin.Index/logout                     |
| admin/agent/list                          | admin.Agent/list                       | get|head | admin.Agent/list                       |
| admin/agent/jiesuanlist                   | admin.Agent/jiesuanlist                | get|head | admin.Agent/jiesuanlist                |
| admin/agent/add                           | admin.Agent/add                        | get|head | admin.Agent/add                        |
| admin/agent/edit                          | admin.Agent/edit                       | get|head | admin.Agent/edit                       |
| admin/settlement/index                    | admin.Settlement/index                 | get|head | admin.Settlement/index                 |
| admin/settlement/records                  | admin.Settlement/records               | get|head | admin.Settlement/records               |
| admin/settlement/statistics               | admin.Settlement/statistics            | get|head | admin.Settlement/statistics            |
| admin/player/list                         | admin.Player/list                      | get|head | admin.Player/list                      |
| admin/player/edit                         | admin.Player/edit                      | get|head | admin.Player/edit                      |
| admin/player/bindList                     | admin.Player/bindList                  | get|head | admin.Player/bindList                  |
| admin/player/bindlist                     | admin.Player/bindList                  | get|head | admin.Player/bindList                  |
| admin/player/bindList/selected/<selected> | admin.Player/bindList                  | get|head | admin.Player/bindList                  |
| admin/player/bindlist/selected/<selected> | admin.Player/bindList                  | get|head | admin.Player/bindList                  |
| admin/player/voiceList                    | admin.Player/voiceList                 | get|head | admin.Player/voiceList                 |
| admin/player/roleList                     | admin.Player/roleList                  | get|head | admin.Player/roleList                  |
| admin/transfer/list                       | admin.Transfer/list                    | get|head | admin.Transfer/list                    |
| admin/transfer/detail                     | admin.Transfer/detail                  | get|head | admin.Transfer/detail                  |
| admin/order/list                          | admin.Order/list                       | get|head | admin.Order/list                       |
| admin/order/list/status/<status>          | admin.Order/list                       | get|head | admin.Order/list                       |
| admin/item/test                           | admin.Item/test                        | get|head | admin.Item/test                        |
| admin/item/itemList                       | admin.Item/itemList                    | get|head | admin.Item/itemList                    |
| admin/configure/serverConfig              | admin.Configure/serverConfig           | get|head | admin.Configure/serverConfig           |
| admin/configure/serverAdd                 | admin.Configure/serverAdd              | get|head | admin.Configure/serverAdd              |
| admin/configure/serverEdit                | admin.Configure/serverEdit             | get|head | admin.Configure/serverEdit             |
| admin/configure/sysConfig                 | admin.Configure/sysConfig              | get|head | admin.Configure/sysConfig              |
| admin/configure/noticeConfig              | admin.Configure/noticeConfig           | get|head | admin.Configure/noticeConfig           |
| admin/configure/payConfig                 | admin.Configure/payConfig              | get|head | admin.Configure/payConfig              |
| admin/configure/addPayChannel             | admin.Configure/addPayChannel          | get|head | admin.Configure/addPayChannel          |
| admin/configure/editPayChannel            | admin.Configure/editPayChannel         | get|head | admin.Configure/editPayChannel         |
| admin/log/userLog/type/<type>             | admin.Log/userLog                      | get|head | admin.Log/userLog                      |
| admin/log/playerLogin                     | admin.Log/playerLogin                  | get|head | admin.Log/playerLogin                  |
| admin/fankui/fankuiList                   | admin.Fankui/fankuiList                | get|head | admin.Fankui/fankuiList                |
| admin/fankui/mail                         | admin.Fankui/mail                      | get|head | admin.Fankui/mail                      |
| admin/gm/player                           | admin.GmPlayer/player                  | get|head | admin.GmPlayer/player                  |
| admin/gm/player/mod/<mod>                 | admin.GmPlayer/player                  | get|head | admin.GmPlayer/player                  |
| admin/gm/server_cmd                       | admin.GmServer/server_cmd              | get|head | admin.GmServer/server_cmd              |
| admin/gm/server_mail                      | admin.GmMail/server_mail               | get|head | admin.GmMail/server_mail               |
| admin/gm/cdk                              | admin.GmCdk/cdk                        | get|head | admin.GmCdk/cdk                        |
| admin/gm/cdkListUnused                    | admin.GmCdk/cdkListUnused              | get|head | admin.GmCdk/cdkListUnused              |
| admin/gm/cdkListUsed                      | admin.GmCdk/cdkListUsed                | get|head | admin.GmCdk/cdkListUsed                |
| admin/gm/cdkStats                         | admin.GmCdk/cdkStats                   | get|head | admin.GmCdk/cdkStats                   |
| admin/gm/cleanData                        | admin.GmCleanData/clean_data           | get|head | admin.GmCleanData/clean_data           |
| admin/agent/list_table                    | admin.Agent/list_table                 | get|post | admin.Agent/list_table                 |
| admin/agent/list_jiesuan                  | admin.Agent/list_jiesuan               | get|post | admin.Agent/list_jiesuan               |
| admin/settlement/list_table               | admin.Settlement/list_table            | get|post | admin.Settlement/list_table            |
| admin/settlement/records_table            | admin.Settlement/records_table         | get|post | admin.Settlement/records_table         |
| admin/player/list_table                   | admin.Player/list_table                | get|post | admin.Player/list_table                |
| admin/player/bind_list_table              | admin.Player/bind_list_table           | get|post | admin.Player/bind_list_table           |
| admin/player/voice_list_table             | admin.Player/voice_list_table          | get|post | admin.Player/voice_list_table          |
| admin/player/role_table                   | admin.Player/role_table                | get|post | admin.Player/role_table                |
| admin/transfer/table                      | admin.Transfer/table                   | get|post | admin.Transfer/table                   |
| admin/order/list_table                    | admin.Order/list_table                 | get|post | admin.Order/list_table                 |
| admin/order/list_table/status/<status>    | admin.Order/list_table                 | get|post | admin.Order/list_table                 |
| admin/item/list_table                     | admin.Item/list_table                  | get|post | admin.Item/list_table                  |
| admin/configure/serverList                | admin.Configure/serverList             | get|post | admin.Configure/serverList             |
| admin/configure/payChannel                | admin.Configure/payChannel             | get|post | admin.Configure/payChannel             |
| admin/log/list_table/type/<type>          | admin.Log/list_table                   | get|post | admin.Log/list_table                   |
| admin/log/playerLoginList                 | admin.Log/playerLoginList              | get|post | admin.Log/playerLoginList              |
| admin/fankui/fankui_list_table            | admin.Fankui/fankui_list_table         | get|post | admin.Fankui/fankui_list_table         |
| admin/agentrelation/viewTree              | admin.AgentRelation/viewTree           | get|post | admin.AgentRelation/viewTree           |
| admin/agentrelation/updateAmount          | admin.AgentRelation/updateAmount       | get|post | admin.AgentRelation/updateAmount       |
| admin/agentrelation/commissionStats       | admin.AgentRelation/commissionStats    | get|post | admin.AgentRelation/commissionStats    |
| admin/index/editMy                        | admin.Index/editMy                     | post     | admin.Index/editMy                     |
| admin/agent/jiesuan                       | admin.Agent/jiesuan                    | post     | admin.Agent/jiesuan                    |
| admin/agent/addSubmit                     | admin.Agent/addSubmit                  | post     | admin.Agent/addSubmit                  |
| admin/agent/editSubmit                    | admin.Agent/editSubmit                 | post     | admin.Agent/editSubmit                 |
| admin/agent/status                        | admin.Agent/status                     | post     | admin.Agent/status                     |
| admin/agent/tixian                        | admin.Agent/tixian                     | post     | admin.Agent/tixian                     |
| admin/agent/quanxian                      | admin.Agent/quanxian                   | post     | admin.Agent/quanxian                   |
| admin/settlement/settle                   | admin.Settlement/settle                | post     | admin.Settlement/settle                |
| admin/player/modify                       | admin.Player/modify                    | post     | admin.Player/modify                    |
| admin/player/editSubmit                   | admin.Player/editSubmit                | post     | admin.Player/editSubmit                |
| admin/player/del                          | admin.Player/del                       | post     | admin.Player/del                       |
| admin/player/status                       | admin.Player/status                    | post     | admin.Player/status                    |
| admin/player/zhiboqu                      | admin.Player/zhiboqu                   | post     | admin.Player/zhiboqu                   |
| admin/transfer/approve                    | admin.Transfer/approve                 | post     | admin.Transfer/approve                 |
| admin/transfer/reject                     | admin.Transfer/reject                  | post     | admin.Transfer/reject                  |
| admin/transfer/process                    | admin.Transfer/process                 | post     | admin.Transfer/process                 |
| admin/transfer/complete                   | admin.Transfer/complete                | post     | admin.Transfer/complete                |
| admin/transfer/autoExecute                | admin.Transfer/autoExecute             | post     | admin.Transfer/autoExecute             |
| admin/order/tuikuan                       | admin.Order/tuikuan                    | post     | admin.Order/tuikuan                    |
| admin/item/itemSync                       | admin.Item/itemSync                    | post     | admin.Item/itemSync                    |
| admin/item/clearAll                       | admin.Item/clearAll                    | post     | admin.Item/clearAll                    |
| admin/configure/serverAddSubmit           | admin.Configure/serverAddSubmit        | post     | admin.Configure/serverAddSubmit        |
| admin/configure/serverEditSubmit          | admin.Configure/serverEditSubmit       | post     | admin.Configure/serverEditSubmit       |
| admin/configure/serverDel                 | admin.Configure/serverDel              | post     | admin.Configure/serverDel              |
| admin/configure/serverTitle               | admin.Configure/serverTitle            | post     | admin.Configure/serverTitle            |
| admin/configure/makeServerList            | admin.Configure/makeServerList         | post     | admin.Configure/makeServerList         |
| admin/configure/upSys                     | admin.Configure/upSys                  | post     | admin.Configure/upSys                  |
| admin/configure/upNotice                  | admin.Configure/upNotice               | post     | admin.Configure/upNotice               |
| admin/configure/addChannelSub             | admin.Configure/addChannelSub          | post     | admin.Configure/addChannelSub          |
| admin/configure/delPayChannel             | admin.Configure/delPayChannel          | post     | admin.Configure/delPayChannel          |
| admin/configure/upChannelSub              | admin.Configure/upChannelSub           | post     | admin.Configure/upChannelSub           |
| admin/fankui/mailSub                      | admin.Fankui/mailSub                   | post     | admin.Fankui/mailSub                   |
| admin/agentrelation/initRelation          | admin.AgentRelation/initRelation       | post     | admin.AgentRelation/initRelation       |
| admin/agentrelation/recalculateAll        | admin.AgentRelation/recalculateAll     | post     | admin.AgentRelation/recalculateAll     |
| admin/gm/playerSub                        | admin.GmPlayer/playerSub               | post     | admin.GmPlayer/playerSub               |
| admin/gm/serverSub                        | admin.GmServer/serverSub               | post     | admin.GmServer/serverSub               |
| admin/gm/serverMailSub                    | admin.GmMail/serverMailSub             | post     | admin.GmMail/serverMailSub             |
| admin/gm/cdkQuery                         | admin.GmCdk/cdkQuery                   | post     | admin.GmCdk/cdkQuery                   |
| admin/gm/cdkGenerate                      | admin.GmCdk/cdkGenerate                | post     | admin.GmCdk/cdkGenerate                |
| admin/gm/cdkUpdateUid                     | admin.GmCdk/cdkUpdateUid               | post     | admin.GmCdk/cdkUpdateUid               |
| admin/gm/cdkDelete                        | admin.GmCdk/cdkDelete                  | post     | admin.GmCdk/cdkDelete                  |
| admin/gm/cdkUpdatePass                    | admin.GmCdk/cdkUpdatePass              | post     | admin.GmCdk/cdkUpdatePass              |
| admin/gm/cleanDataSub                     | admin.GmCleanData/cleanDataSub         | post     | admin.GmCleanData/cleanDataSub         |
| admin/gm/getDataStatistics                | admin.GmCleanData/getDataStatistics    | post     | admin.GmCleanData/getDataStatistics    |
| admin/gm/queryCleanData                   | admin.GmCleanData/queryCleanData       | post     | admin.GmCleanData/queryCleanData       |
| admin/gm/doCleanData                      | admin.GmCleanData/doCleanData          | post     | admin.GmCleanData/doCleanData          |
| admin/gm/doCleanAll                       | admin.GmCleanData/doCleanAll           | post     | admin.GmCleanData/doCleanAll           |
| agent                                     | agent.Index/index                      | get|head | agent.Index/index                      |
| agent/index                               | agent.Index/index                      | get|head | agent.Index/index                      |
| agent/index/worker                        | agent.Index/worker                     | get|head | agent.Index/worker                     |
| agent/index/my                            | agent.Index/my                         | get|head | agent.Index/my                         |
| agent/index/logout                        | agent.Index/logout                     | get|head | agent.Index/logout                     |
| agent/agent/list                          | agent.Agent/list                       | get|head | agent.Agent/list                       |
| agent/agent/add                           | agent.Agent/add                        | get|head | agent.Agent/add                        |
| agent/agent/edit                          | agent.Agent/edit                       | get|head | agent.Agent/edit                       |
| agent/agent/kefu                          | agent.Agent/kefu                       | get|head | agent.Agent/kefu                       |
| agent/player/list                         | agent.Player/list                      | get|head | agent.Player/list                      |
| agent/player/edit                         | agent.Player/edit                      | get|head | agent.Player/edit                      |
| agent/player/bindList                     | agent.Player/bindList                  | get|head | agent.Player/bindList                  |
| agent/player/bindlist                     | agent.Player/bindList                  | get|head | agent.Player/bindList                  |
| agent/player/bindList/selected/<selected> | agent.Player/bindList                  | get|head | agent.Player/bindList                  |
| agent/player/bindlist/selected/<selected> | agent.Player/bindList                  | get|head | agent.Player/bindList                  |
| agent/order/list                          | agent.Order/list                       | get|head | agent.Order/list                       |
| agent/order/list/status/<status>          | agent.Order/list                       | get|head | agent.Order/list                       |
| agent/agent/list_table                    | agent.Agent/list_table                 | get|post | agent.Agent/list_table                 |
| agent/player/list_table                   | agent.Player/list_table                | get|post | agent.Player/list_table                |
| agent/player/bind_list_table              | agent.Player/bind_list_table           | get|post | agent.Player/bind_list_table           |
| agent/order/list_table                    | agent.Order/list_table                 | get|post | agent.Order/list_table                 |
| agent/order/list_table/status/<status>    | agent.Order/list_table                 | get|post | agent.Order/list_table                 |
| agent/index/editMy                        | agent.Index/editMy                     | post     | agent.Index/editMy                     |
| agent/index/applyWithdrawal               | agent.Index/applyWithdrawal            | post     | agent.Index/applyWithdrawal            |
| agent/index/jiesuan                       | agent.Index/jiesuan                    | post     | agent.Index/jiesuan                    |
| agent/agent/addSubmit                     | agent.Agent/addSubmit                  | post     | agent.Agent/addSubmit                  |
| agent/agent/editSubmit                    | agent.Agent/editSubmit                 | post     | agent.Agent/editSubmit                 |
| agent/agent/kefuSubmit                    | agent.Agent/kefuSubmit                 | post     | agent.Agent/kefuSubmit                 |
| agent/player/editSubmit                   | agent.Player/editSubmit                | post     | agent.Player/editSubmit                |
| agent/player/status                       | agent.Player/status                    | post     | agent.Player/status                    |
| player/auth/login                         | player.Auth/login                      | get      | player.Auth/login                      |
| player/auth/doLogin                       | player.Auth/doLogin                    | post     | player.Auth/doLogin                    |
| player/auth/register                      | player.Auth/register                   | get      | player.Auth/register                   |
| player/auth/doRegister                    | player.Auth/doRegister                 | post     | player.Auth/doRegister                 |
| player/auth/forgot                        | player.Auth/forgot                     | get      | player.Auth/forgot                     |
| player/auth/doForgot                      | player.Auth/doForgot                   | post     | player.Auth/doForgot                   |
| player/auth/logout                        | player.Auth/logout                     | get      | player.Auth/logout                     |
| player/auth/resetPassword                 | player.Auth/resetPassword              | get      | player.Auth/resetPassword              |
| player/auth/doResetPassword               | player.Auth/doResetPassword            | post     | player.Auth/doResetPassword            |
| player/cdk                                | player.Cdk/index                       | get      | player.Cdk/index                       |
| player/cdk/index                          | player.Cdk/index                       | get      | player.Cdk/index                       |
| player/cdk/auth                           | player.Cdk/auth                        | post     | player.Cdk/auth                        |
| player/cdk/existing                       | player.Cdk/existing                    | post     | player.Cdk/existing                    |
| player/cdk/servers                        | player.Cdk/servers                     | get      | player.Cdk/servers                     |
| player/cdk/logout                         | player.Cdk/logout                      | get      | player.Cdk/logout                      |
| player/cdk/dashboard                      | player.Cdk/dashboard                   | get      | player.Cdk/dashboard                   |
| player/cdk/senditem                       | player.SendItem/index                  | get      | player.SendItem/index                  |
| player/cdk/sendItem                       | player.SendItem/index                  | get      | player.SendItem/index                  |
| player/cdk/senditem/index                 | player.SendItem/index                  | get      | player.SendItem/index                  |
| player/cdk/senditem/prepareOp             | player.SendItem/prepareOp              | post     | player.SendItem/prepareOp              |
| player/cdk/senditem/sendItem              | player.SendItem/sendItem               | post     | player.SendItem/sendItem               |
| player/cdk/senditem/rechargeXianyu        | player.SendItem/rechargeXianyu         | post     | player.SendItem/rechargeXianyu         |
| player/cdk/senditem/getItemList           | player.SendItem/getItemList            | post     | player.SendItem/getItemList            |
| player/cdk/senditem/switchServer          | player.SendItem/switchServer           | post     | player.SendItem/switchServer           |
| player/admin/login                        | player.Admin/login                     | get      | player.Admin/login                     |
| player/admin/doLogin                      | player.Admin/doLogin                   | post     | player.Admin/doLogin                   |
| player/admin/logout                       | player.Admin/logout                    | get      | player.Admin/logout                    |
| player/admin/captcha                      | player.Admin/captcha                   | get      | player.Admin/captcha                   |
| player                                    | player.Index/index                     | get      | player.Index/index                     |
| player/index                              | player.Index/index                     | get      | player.Index/index                     |
| player/profile                            | player.Profile/index                   | get      | player.Profile/index                   |
| player/profile/update                     | player.Profile/update                  | post     | player.Profile/update                  |
| player/profile/password                   | player.Profile/password                | get      | player.Profile/password                |
| player/profile/updatePassword             | player.Profile/updatePassword          | post     | player.Profile/updatePassword          |
| player/profile/avatar                     | player.Profile/avatar                  | get      | player.Profile/avatar                  |
| player/profile/uploadAvatar               | player.Profile/uploadAvatar            | post     | player.Profile/uploadAvatar            |
| player/server                             | player.Server/index                    | get      | player.Server/index                    |
| player/server/detail                      | player.Server/detail                   | get      | player.Server/detail                   |
| player/role                               | player.Role/index                      | get      | player.Role/index                      |
| player/role/detail                        | player.Role/detail                     | get      | player.Role/detail                     |
| player/role/getByServer                   | player.Role/getByServer                | get      | player.Role/getByServer                |
| player/order                              | player.Order/index                     | get      | player.Order/index                     |
| player/order/detail                       | player.Order/detail                    | get      | player.Order/detail                    |
| player/recharge                           | player.Recharge/index                  | get      | player.Recharge/index                  |
| player/recharge/createOrder               | player.Recharge/createOrder            | post     | player.Recharge/createOrder            |
| player/feedback                           | player.Feedback/index                  | get      | player.Feedback/index                  |
| player/feedback/submit                    | player.Feedback/submit                 | post     | player.Feedback/submit                 |
| player/service                            | player.Service/index                   | get      | player.Service/index                   |
| player/transfer                           | player.Transfer/index                  | get      | player.Transfer/index                  |
| player/transfer/submit                    | player.Transfer/submit                 | post     | player.Transfer/submit                 |
| player/transfer/detail                    | player.Transfer/detail                 | get      | player.Transfer/detail                 |
| player/transfer/getRoles                  | player.Transfer/getRoles               | get      | player.Transfer/getRoles               |
| login/auth                                | <Closure>                              | get      |                                        |
| login/auth                                | <Closure>                              | get      |                                        |
| login/auth/auth                           | <Closure>                              | get      |                                        |
| login/auth/auth                           | <Closure>                              | get      |                                        |
| login/auth/dashboard                      | <Closure>                              | get      |                                        |
| login/auth/dashboard                      | <Closure>                              | get      |                                        |
| login/auth/senditem                       | <Closure>                              | get      |                                        |
| login/auth/senditem                       | <Closure>                              | get      |                                        |
| login/auth/sendItem                       | <Closure>                              | get      |                                        |
| login/auth/sendItem                       | <Closure>                              | get      |                                        |
| login/auth/senditem/index                 | <Closure>                              | get      |                                        |
| login/auth/senditem/index                 | <Closure>                              | get      |                                        |
| login/auth/logout                         | <Closure>                              | get      |                                        |
| login/auth/logout                         | <Closure>                              | get      |                                        |
| login/auth/success                        | <Closure>                              | get      |                                        |
| login/auth/success                        | <Closure>                              | get      |                                        |
| login/user                                | <Closure>                              | get      |                                        |
| login/user                                | <Closure>                              | get      |                                        |
| enlist/submit_code                        | api.Enlist/submitCode                  | get|post | api.Enlist/submitCode                  |
| api/enlist/submit_code                    | api.Enlist/submitCode                  | get|post | api.Enlist/submitCode                  |
| user/api/index.php/role/set               | api.LegacyRole/set                     | get|post | api.LegacyRole/set                     |
| user/api/index.php/role/get               | api.LegacyRole/get                     | get|post | api.LegacyRole/get                     |
| user/api/index/role/set                   | api.LegacyRole/set                     | get|post | api.LegacyRole/set                     |
| user/api/index/role/get                   | api.LegacyRole/get                     | get|post | api.LegacyRole/get                     |
| api/sdk/user_login                        | api.Sdk/user_login                     | get|post | api.Sdk/user_login                     |
| api/sdk/user_register                     | api.Sdk/user_register                  | get|post | api.Sdk/user_register                  |
| api/sdk/user_regapp                       | api.Sdk/user_regapp                    | get|post | api.Sdk/user_regapp                    |
| api/sdk/user_app                          | api.Sdk/user_app                       | get|post | api.Sdk/user_app                       |
| api/sdk/login                             | api.Sdk/user_login                     | get|post | api.Sdk/user_login                     |
| api/sdk/register                          | api.Sdk/user_register                  | get|post | api.Sdk/user_register                  |
| api/pay/getpayitem                        | api.Pay/getpayitem                     | get      | api.Pay/getpayitem                     |
| api/pay/getpay                            | api.Pay/getpay                         | get|post | api.Pay/getpay                         |
| api/call/epay                             | api.Call/epay                          | get|post | api.Call/epay                          |
| api/call/test                             | api.Call/test                          | get|post | api.Call/test                          |
| api/call/checkurl                         | api.Call/checkurl                      | get|post | api.Call/checkurl                      |
| api/call/epay1                            | api.Call/epay1                         | get|post | api.Call/epay1                         |
| api/notify/epay                           | api.Notify/epay                        | get|post | api.Notify/epay                        |
| api/voice/receive                         | api.Voice/receive                      | post     | api.Voice/receive                      |
| api/voice/iat                             | api.Voice/iat                          | get      | api.Voice/iat                          |
| api/chargeaward/getchargeitem             | api.ChargeAward/getchargeitem          | get|post | api.ChargeAward/getchargeitem          |
| api/chargeaward/receiveday                | api.ChargeAward/receiveday             | get|post | api.ChargeAward/receiveday             |
| api/chargeaward/receiverole               | api.ChargeAward/receiverole            | get|post | api.ChargeAward/receiverole            |
| api/chargeaward/modifypass                | api.ChargeAward/modifypass             | get|post | api.ChargeAward/modifypass             |
| api/faq/index                             | api.Faq/index                          | get      | api.Faq/index                          |
| api/faq/search                            | api.Faq/search                         | get      | api.Faq/search                         |
| api/v1/sdk/login                          | api.Sdk/user_login                     | get|post | api.Sdk/user_login                     |
| api/v1/sdk/register                       | api.Sdk/user_register                  | get|post | api.Sdk/user_register                  |
| api/v1/sdk/register-ios                   | api.Sdk/user_regapp                    | get|post | api.Sdk/user_regapp                    |
| api/v1/sdk/login-ios                      | api.Sdk/user_app                       | get|post | api.Sdk/user_app                       |
| api/v1/pay/items                          | api.Pay/getpayitem                     | get      | api.Pay/getpayitem                     |
| api/v1/pay/order                          | api.Pay/getpay                         | get|post | api.Pay/getpay                         |
| api/v1/pay/callback/epay                  | api.Call/epay                          | get|post | api.Call/epay                          |
| api/v1/pay/return/epay                    | api.Notify/epay                        | get|post | api.Notify/epay                        |
| api/v1/role/get                           | api.LegacyRole/get                     | get|post | api.LegacyRole/get                     |
| api/v1/role/set                           | api.LegacyRole/set                     | get|post | api.LegacyRole/set                     |
| api/game/sdk                              | api.Game/sdk                           | get|post | api.Game/sdk                           |
| api/game/bind                             | api.Game/bind                          | get|post | api.Game/bind                          |
| api/game/kefu                             | api.Game/kefu                          | get|post | api.Game/kefu                          |
| api/game/zhuanqu                          | api.Game/zhuanqu                       | get|post | api.Game/zhuanqu                       |
| api/game/zhuanquSub                       | api.Game/zhuanquSub                    | get|post | api.Game/zhuanquSub                    |
| api/game/rebate                           | api.Game/rebate                        | get|post | api.Game/rebate                        |
| api/game/fankui                           | api.Game/fankui                        | get|post | api.Game/fankui                        |
| api/game/fankuiSub                        | api.Game/fankuiSub                     | get|post | api.Game/fankuiSub                     |
| index                                     | Index/index                            | get|head | Index/index                            |
| submit                                    | Index/submit                           | post     | Index/submit                           |
| captcha/<config?>                         | \think\captcha\CaptchaController@index | get      | \think\captcha\CaptchaController@index |
+-------------------------------------------+----------------------------------------+----------+----------------------------------------+
