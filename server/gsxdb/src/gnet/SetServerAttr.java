
package gnet;

// {{{ RPCGEN_IMPORT_BEGIN
// {{{ DO NOT EDIT THIS

abstract class __SetServerAttr__ extends mkio.Rpc<gnet.SetServerAttrArg, gnet.SetServerAttrRes> { }
// DO NOT EDIT THIS }}}
// RPCGEN_IMPORT_END }}}

public class SetServerAttr extends __SetServerAttr__ {
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
		return 204;
	}

	public SetServerAttr() {
		super.setArgument(new gnet.SetServerAttrArg());
		super.setResult(new gnet.SetServerAttrRes());
	}

	public SetServerAttr(gnet.SetServerAttrArg argument) {
		super.setArgument(argument);
		super.setResult(new gnet.SetServerAttrRes());
	}

	public int getTimeout() {
		return 1000 * 20;
	}

	// DO NOT EDIT THIS }}}
	// RPCGEN_DEFINE_END }}}
}

