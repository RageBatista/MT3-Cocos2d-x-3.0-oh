
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class BitcoinNums extends mkdb.XBean implements xbean.BitcoinNums {
	private java.util.HashMap<Long, xbean.BitcoinNum> rolebitcoin; // 角色id -> 比特币，作者 system

	@Override
	public void _reset_unsafe_() {
		rolebitcoin.clear();
	}

	BitcoinNums(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
	}

	public BitcoinNums() {
		this(0, null, null);
	}

	public BitcoinNums(BitcoinNums _o_) {
		this(_o_, null, null);
	}

	BitcoinNums(xbean.BitcoinNums _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof BitcoinNums) assign((BitcoinNums)_o1_);
		else if (_o1_ instanceof BitcoinNums.Data) assign((BitcoinNums.Data)_o1_);
		else if (_o1_ instanceof BitcoinNums.Const) assign(((BitcoinNums.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(BitcoinNums _o_) {
		_o_._xdb_verify_unsafe_();
		rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
		for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : _o_.rolebitcoin.entrySet())
			rolebitcoin.put(_e_.getKey(), new BitcoinNum(_e_.getValue(), this, "rolebitcoin"));
	}

	private void assign(BitcoinNums.Data _o_) {
		rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
		for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : _o_.rolebitcoin.entrySet())
			rolebitcoin.put(_e_.getKey(), new BitcoinNum(_e_.getValue(), this, "rolebitcoin"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.compact_uint32(rolebitcoin.size());
		for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : rolebitcoin.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>(size * 2);
			}
			for (; size > 0; --size)
			{
				long _k_ = 0;
				_k_ = _os_.unmarshal_long();
				xbean.BitcoinNum _v_ = new BitcoinNum(0, this, "rolebitcoin");
				_v_.unmarshal(_os_);
				rolebitcoin.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.BitcoinNums copy() {
		_xdb_verify_unsafe_();
		return new BitcoinNums(this);
	}

	@Override
	public xbean.BitcoinNums toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.BitcoinNums toBean() {
		_xdb_verify_unsafe_();
		return new BitcoinNums(this); // same as copy()
	}

	@Override
	public xbean.BitcoinNums toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.BitcoinNums toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoin() { // 角色id -> 比特币，作者 system
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "rolebitcoin"), rolebitcoin);
	}

	@Override
	public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoinAsData() { // 角色id -> 比特币，作者 system
		_xdb_verify_unsafe_();
		java.util.Map<Long, xbean.BitcoinNum> rolebitcoin;
		BitcoinNums _o_ = this;
		rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
		for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : _o_.rolebitcoin.entrySet())
			rolebitcoin.put(_e_.getKey(), new BitcoinNum.Data(_e_.getValue()));
		return rolebitcoin;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		BitcoinNums _o_ = null;
		if ( _o1_ instanceof BitcoinNums ) _o_ = (BitcoinNums)_o1_;
		else if ( _o1_ instanceof BitcoinNums.Const ) _o_ = ((BitcoinNums.Const)_o1_).nThis();
		else return false;
		if (!rolebitcoin.equals(_o_.rolebitcoin)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += rolebitcoin.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(rolebitcoin);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableMap().setVarName("rolebitcoin"));
		return lb;
	}

	private class Const implements xbean.BitcoinNums {
		BitcoinNums nThis() {
			return BitcoinNums.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.BitcoinNums copy() {
			return BitcoinNums.this.copy();
		}

		@Override
		public xbean.BitcoinNums toData() {
			return BitcoinNums.this.toData();
		}

		public xbean.BitcoinNums toBean() {
			return BitcoinNums.this.toBean();
		}

		@Override
		public xbean.BitcoinNums toDataIf() {
			return BitcoinNums.this.toDataIf();
		}

		public xbean.BitcoinNums toBeanIf() {
			return BitcoinNums.this.toBeanIf();
		}

		@Override
		public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoin() { // 角色id -> 比特币，作者 system
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(rolebitcoin);
		}

		@Override
		public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoinAsData() { // 角色id -> 比特币，作者 system
			_xdb_verify_unsafe_();
			java.util.Map<Long, xbean.BitcoinNum> rolebitcoin;
			BitcoinNums _o_ = BitcoinNums.this;
			rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
			for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : _o_.rolebitcoin.entrySet())
				rolebitcoin.put(_e_.getKey(), new BitcoinNum.Data(_e_.getValue()));
			return rolebitcoin;
		}

		@Override
		public mkdb.Bean toConst() {
			_xdb_verify_unsafe_();
			return this;
		}

		@Override
		public boolean isConst() {
			_xdb_verify_unsafe_();
			return true;
		}

		@Override
		public boolean isData() {
			return BitcoinNums.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return BitcoinNums.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return BitcoinNums.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return BitcoinNums.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return BitcoinNums.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return BitcoinNums.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return BitcoinNums.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return BitcoinNums.this.hashCode();
		}

		@Override
		public String toString() {
			return BitcoinNums.this.toString();
		}

	}

	public static final class Data implements xbean.BitcoinNums {
		private java.util.HashMap<Long, xbean.BitcoinNum> rolebitcoin; // 角色id -> 比特币，作者 system

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
		}

		Data(xbean.BitcoinNums _o1_) {
			if (_o1_ instanceof BitcoinNums) assign((BitcoinNums)_o1_);
			else if (_o1_ instanceof BitcoinNums.Data) assign((BitcoinNums.Data)_o1_);
			else if (_o1_ instanceof BitcoinNums.Const) assign(((BitcoinNums.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(BitcoinNums _o_) {
			rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
			for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : _o_.rolebitcoin.entrySet())
				rolebitcoin.put(_e_.getKey(), new BitcoinNum.Data(_e_.getValue()));
		}

		private void assign(BitcoinNums.Data _o_) {
			rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>();
			for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : _o_.rolebitcoin.entrySet())
				rolebitcoin.put(_e_.getKey(), new BitcoinNum.Data(_e_.getValue()));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(rolebitcoin.size());
			for (java.util.Map.Entry<Long, xbean.BitcoinNum> _e_ : rolebitcoin.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					rolebitcoin = new java.util.HashMap<Long, xbean.BitcoinNum>(size * 2);
				}
				for (; size > 0; --size)
				{
					long _k_ = 0;
					_k_ = _os_.unmarshal_long();
					xbean.BitcoinNum _v_ = xbean.Pod.newBitcoinNumData();
					_v_.unmarshal(_os_);
					rolebitcoin.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.BitcoinNums copy() {
			return new Data(this);
		}

		@Override
		public xbean.BitcoinNums toData() {
			return new Data(this);
		}

		public xbean.BitcoinNums toBean() {
			return new BitcoinNums(this, null, null);
		}

		@Override
		public xbean.BitcoinNums toDataIf() {
			return this;
		}

		public xbean.BitcoinNums toBeanIf() {
			return new BitcoinNums(this, null, null);
		}

		// mkdb.Bean 接口，Data 不支持此操作
		public boolean xdbManaged() { throw new UnsupportedOperationException(); }
		public mkdb.Bean xdbParent() { throw new UnsupportedOperationException(); }
		public String xdbVarname()  { throw new UnsupportedOperationException(); }
		public Long    xdbObjId()   { throw new UnsupportedOperationException(); }
		public mkdb.Bean toConst()   { throw new UnsupportedOperationException(); }
		public boolean isConst()    { return false; }
		public boolean isData()     { return true; }

		@Override
		public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoin() { // 角色id -> 比特币，作者 system
			return rolebitcoin;
		}

		@Override
		public java.util.Map<Long, xbean.BitcoinNum> getRolebitcoinAsData() { // 角色id -> 比特币，作者 system
			return rolebitcoin;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof BitcoinNums.Data)) return false;
			BitcoinNums.Data _o_ = (BitcoinNums.Data) _o1_;
			if (!rolebitcoin.equals(_o_.rolebitcoin)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += rolebitcoin.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(rolebitcoin);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
