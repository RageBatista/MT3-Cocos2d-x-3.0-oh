
package gnet;

// {{{ RPCGEN_IMPORT_BEGIN
// {{{ DO NOT EDIT THIS

abstract class __GetMaxOnlineNum__ extends mkio.Rpc<gnet.GetMaxOnlineNumArg, gnet.GetMaxOnlineNumRes> { }
// DO NOT EDIT THIS }}}
// RPCGEN_IMPORT_END }}}

public class GetMaxOnlineNum extends __GetMaxOnlineNum__ {
	@Override
	protected void onServer() {
		// 请求处理
	}

	@Override
	protected void onClient() {
		// 响应处理
	}

	@Override
	protected void onTimeout(int code) {
		// 仅客户端使用。当使用 submit 方式调用 RPC 时，由框架设置回调
	}

	// {{{ RPCGEN_DEFINE_BEGIN
	// {{{ DO NOT EDIT THIS
	public int getType() {
		return 206;
	}

	public GetMaxOnlineNum() {
		super.setArgument(new gnet.GetMaxOnlineNumArg());
		super.setResult(new gnet.GetMaxOnlineNumRes());
	}

	public GetMaxOnlineNum(gnet.GetMaxOnlineNumArg argument) {
		super.setArgument(argument);
		super.setResult(new gnet.GetMaxOnlineNumRes());
	}

	public int getTimeout() {
		return 1000 * 20;
	}

	// DO NOT EDIT THIS }}}
	// RPCGEN_DEFINE_END }}}
}

