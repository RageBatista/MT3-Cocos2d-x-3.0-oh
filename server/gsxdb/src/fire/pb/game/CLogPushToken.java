package fire.pb.game;

import fire.log.Logger;

// {{{ RPCGEN_IMPORT_BEGIN
// {{{ DO NOT EDIT THIS
import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

abstract class __CLogPushToken__ extends mkio.Protocol { }

/** 推送Token日志
*/
// DO NOT EDIT THIS }}}
// RPCGEN_IMPORT_END }}}

public class CLogPushToken extends __CLogPushToken__ {
	public static final Logger logger = Logger.getLogger("PUSH");
	@Override
	protected void process() {
		final long roleId = gnet.link.Onlines.getInstance().findRoleid(this);
		if (roleId < 0)
			return;
		// 协议处理
		new mkdb.Procedure() {
			@Override
			protected boolean process() {
				// 安全加固：对Token进行掩码处理，避免敏感信息泄露
				// 只显示前4位和后4位，中间用****代替
				String maskedToken = maskToken(token);
				logger.error("收到客户端推送消息, RoleId=" + roleId + ", Token=" + maskedToken);
				return true;
			}

			/**
			 * 对Token进行掩码处理
			 * 格式：前4位...后4位
			 * 示例：1234567890 -> 1234...7890
			 *
			 * @param token 原始令牌
			 * @return 掩码后的Token
			 */
			private String maskToken(int token) {
				String tokenStr = String.valueOf(token);
				if (tokenStr.length() <= 8) {
					// Token太短，全部隐藏
					return "****";
				}
				// 显示前4位和后4位
				return tokenStr.substring(0, 4) + "****" + tokenStr.substring(tokenStr.length() - 4);
			}
		}.submit();
	}

	// {{{ RPCGEN_DEFINE_BEGIN
	// {{{ DO NOT EDIT THIS
	public static final int PROTOCOL_TYPE = 810374;

	public int getType() {
		return 810374;
	}

	public int token; // 客户端发来的token

	public CLogPushToken() {
	}

	public CLogPushToken(int _token_) {
		this.token = _token_;
	}

	public final boolean _validator_() {
		return true;
	}

	public OctetsStream marshal(OctetsStream _os_) {
		if (!_validator_()) {
			throw new VerifyError("validator failed");
		}
		_os_.marshal(token);
		return _os_;
	}

	public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		token = _os_.unmarshal_int();
		if (!_validator_()) {
			throw new VerifyError("validator failed");
		}
		return _os_;
	}

	public boolean equals(Object _o1_) {
		if (_o1_ == this) return true;
		if (_o1_ instanceof CLogPushToken) {
			CLogPushToken _o_ = (CLogPushToken)_o1_;
			if (token != _o_.token) return false;
			return true;
		}
		return false;
	}

	public int hashCode() {
		int _h_ = 0;
		_h_ += token;
		return _h_;
	}

	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(token).append(",");
		_sb_.append(")");
		return _sb_.toString();
	}

	public int compareTo(CLogPushToken _o_) {
		if (_o_ == this) return 0;
		int _c_ = 0;
		_c_ = token - _o_.token;
		if (0 != _c_) return _c_;
		return _c_;
	}

	// DO NOT EDIT THIS }}}
	// RPCGEN_DEFINE_END }}}

}
