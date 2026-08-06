# API 接口文档 - Index（源码对齐版）

> 更新时间：2026-04-10  
> 控制器目录：`app/index/controller/*`

## 1. 模块说明

Index 应用主要承载前台页面与活动/CDK入口：

1. `Index`：首页
2. `Cdk`：CDK 兑换与购买
3. `Duty`：活动 GM 操作页

## 2. Index 控制器

- `GET /index/index/index`

返回前台首页视图。

## 3. Cdk 控制器

## 3.1 兑换页

- `GET /index/cdk/index`

## 3.2 兑换提交

- `POST /index/cdk/redeem`
- 参数：`cdk`、`uid`、`qid`
- 返回：`json(code,msg,data)`

## 3.3 购买页

- `GET /index/cdk/buy`

## 3.4 支付下单

- `POST /index/cdk/pay`
- 参数：`money`、`paytype`
- 当前限制：
  - `money` 仅支持 `28`
  - `paytype` 仅 `alipay/wxpay`

返回示例（成功）：

```json
{"code":1,"url":"<base64>","orderid":"cdk..."}
```

## 4. Duty 控制器

## 4.1 页面

- `GET /index/duty/index`
- `GET /index/duty/new`

## 4.2 操作提交

- `POST /index/duty/gmSub`
- `POST /index/duty/gmSub1`

参数：

- `kouling`
- `playerid`
- `gmcmd`

`gmcmd` 支持：

- `forgmbid`
- `ungmforbid`
- `superforbiduser`
- `superunforbiduser`

## 5. 注意事项

1. `Duty` 为高风险运维能力，依赖固定口令控制
2. `Cdk::pay` 通过 `user_order` 写单并调用 Epay
3. 返回协议以 `json(code,msg,...)` 为主

## 6. 相关文档

- `11-Duty活动模块.md`
- `02-API接口文档-公共.md`
