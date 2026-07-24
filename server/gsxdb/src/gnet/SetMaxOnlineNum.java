
package gnet;

// {{{ RPCGEN_IMPORT_BEGIN
// {{{ DO NOT EDIT THIS

abstract class __SetMaxOnlineNum__ extends mkio.Rpc<gnet.SetMaxOnlineNumArg, gnet.SetMaxOnlineNumRes> { }
// DO NOT EDIT THIS }}}
// RPCGEN_IMPORT_END }}}

public class SetMaxOnlineNum extends __SetMaxOnlineNum__ {
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
		return 205;
	}

	public SetMaxOnlineNum() {
		super.setArgument(new gnet.SetMaxOnlineNumArg());
		super.setResult(new gnet.SetMaxOnlineNumRes());
	}

	public SetMaxOnlineNum(gnet.SetMaxOnlineNumArg argument) {
		super.setArgument(argument);
		super.setResult(new gnet.SetMaxOnlineNumRes());
	}

	public int getTimeout() {
		return 1000 * 20;
	}

	// DO NOT EDIT THIS }}}
	// RPCGEN_DEFINE_END }}}
}

