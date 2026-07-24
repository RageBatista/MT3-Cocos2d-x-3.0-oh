
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class TradingLock extends mkdb.XBean implements xbean.TradingLock {
	private long tradingid; // 交易ID
	private long roleid; // 角色ID
	private int itemid; // 锁定的道具ID
	private int itemkey; // 锁定的道具在背包中的key
	private long petid; // 锁定的宠物ID（如果是宠物交易）
	private long locktime; // 锁定时间
	private int locktype; // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易

	@Override
	public void _reset_unsafe_() {
		tradingid = 0L;
		roleid = 0L;
		itemid = 0;
		itemkey = 0;
		petid = 0;
		locktime = 0L;
		locktype = 0;
	}

	TradingLock(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		petid = 0;
	}

	public TradingLock() {
		this(0, null, null);
	}

	public TradingLock(TradingLock _o_) {
		this(_o_, null, null);
	}

	TradingLock(xbean.TradingLock _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof TradingLock) assign((TradingLock)_o1_);
		else if (_o1_ instanceof TradingLock.Data) assign((TradingLock.Data)_o1_);
		else if (_o1_ instanceof TradingLock.Const) assign(((TradingLock.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(TradingLock _o_) {
		_o_._xdb_verify_unsafe_();
		tradingid = _o_.tradingid;
		roleid = _o_.roleid;
		itemid = _o_.itemid;
		itemkey = _o_.itemkey;
		petid = _o_.petid;
		locktime = _o_.locktime;
		locktype = _o_.locktype;
	}

	private void assign(TradingLock.Data _o_) {
		tradingid = _o_.tradingid;
		roleid = _o_.roleid;
		itemid = _o_.itemid;
		itemkey = _o_.itemkey;
		petid = _o_.petid;
		locktime = _o_.locktime;
		locktype = _o_.locktype;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(tradingid);
		_os_.marshal(roleid);
		_os_.marshal(itemid);
		_os_.marshal(itemkey);
		_os_.marshal(petid);
		_os_.marshal(locktime);
		_os_.marshal(locktype);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		tradingid = _os_.unmarshal_long();
		roleid = _os_.unmarshal_long();
		itemid = _os_.unmarshal_int();
		itemkey = _os_.unmarshal_int();
		petid = _os_.unmarshal_long();
		locktime = _os_.unmarshal_long();
		locktype = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.TradingLock copy() {
		_xdb_verify_unsafe_();
		return new TradingLock(this);
	}

	@Override
	public xbean.TradingLock toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.TradingLock toBean() {
		_xdb_verify_unsafe_();
		return new TradingLock(this); // same as copy()
	}

	@Override
	public xbean.TradingLock toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.TradingLock toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public long getTradingid() { // 交易ID
		_xdb_verify_unsafe_();
		return tradingid;
	}

	@Override
	public long getRoleid() { // 角色ID
		_xdb_verify_unsafe_();
		return roleid;
	}

	@Override
	public int getItemid() { // 锁定的道具ID
		_xdb_verify_unsafe_();
		return itemid;
	}

	@Override
	public int getItemkey() { // 锁定的道具在背包中的key
		_xdb_verify_unsafe_();
		return itemkey;
	}

	@Override
	public long getPetid() { // 锁定的宠物ID（如果是宠物交易）
		_xdb_verify_unsafe_();
		return petid;
	}

	@Override
	public long getLocktime() { // 锁定时间
		_xdb_verify_unsafe_();
		return locktime;
	}

	@Override
	public int getLocktype() { // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
		_xdb_verify_unsafe_();
		return locktype;
	}

	@Override
	public void setTradingid(long _v_) { // 交易ID
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "tradingid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, tradingid) {
					public void rollback() { tradingid = _xdb_saved; }
				};}});
		tradingid = _v_;
	}

	@Override
	public void setRoleid(long _v_) { // 角色ID
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "roleid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, roleid) {
					public void rollback() { roleid = _xdb_saved; }
				};}});
		roleid = _v_;
	}

	@Override
	public void setItemid(int _v_) { // 锁定的道具ID
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "itemid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, itemid) {
					public void rollback() { itemid = _xdb_saved; }
				};}});
		itemid = _v_;
	}

	@Override
	public void setItemkey(int _v_) { // 锁定的道具在背包中的key
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "itemkey") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, itemkey) {
					public void rollback() { itemkey = _xdb_saved; }
				};}});
		itemkey = _v_;
	}

	@Override
	public void setPetid(long _v_) { // 锁定的宠物ID（如果是宠物交易）
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "petid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, petid) {
					public void rollback() { petid = _xdb_saved; }
				};}});
		petid = _v_;
	}

	@Override
	public void setLocktime(long _v_) { // 锁定时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "locktime") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, locktime) {
					public void rollback() { locktime = _xdb_saved; }
				};}});
		locktime = _v_;
	}

	@Override
	public void setLocktype(int _v_) { // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "locktype") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, locktype) {
					public void rollback() { locktype = _xdb_saved; }
				};}});
		locktype = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		TradingLock _o_ = null;
		if ( _o1_ instanceof TradingLock ) _o_ = (TradingLock)_o1_;
		else if ( _o1_ instanceof TradingLock.Const ) _o_ = ((TradingLock.Const)_o1_).nThis();
		else return false;
		if (tradingid != _o_.tradingid) return false;
		if (roleid != _o_.roleid) return false;
		if (itemid != _o_.itemid) return false;
		if (itemkey != _o_.itemkey) return false;
		if (petid != _o_.petid) return false;
		if (locktime != _o_.locktime) return false;
		if (locktype != _o_.locktype) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += tradingid;
		_h_ += roleid;
		_h_ += itemid;
		_h_ += itemkey;
		_h_ += petid;
		_h_ += locktime;
		_h_ += locktype;
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(tradingid);
		_sb_.append(",");
		_sb_.append(roleid);
		_sb_.append(",");
		_sb_.append(itemid);
		_sb_.append(",");
		_sb_.append(itemkey);
		_sb_.append(",");
		_sb_.append(petid);
		_sb_.append(",");
		_sb_.append(locktime);
		_sb_.append(",");
		_sb_.append(locktype);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("tradingid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("roleid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("itemid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("itemkey"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("petid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("locktime"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("locktype"));
		return lb;
	}

	private class Const implements xbean.TradingLock {
		TradingLock nThis() {
			return TradingLock.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.TradingLock copy() {
			return TradingLock.this.copy();
		}

		@Override
		public xbean.TradingLock toData() {
			return TradingLock.this.toData();
		}

		public xbean.TradingLock toBean() {
			return TradingLock.this.toBean();
		}

		@Override
		public xbean.TradingLock toDataIf() {
			return TradingLock.this.toDataIf();
		}

		public xbean.TradingLock toBeanIf() {
			return TradingLock.this.toBeanIf();
		}

		@Override
		public long getTradingid() { // 交易ID
			_xdb_verify_unsafe_();
			return tradingid;
		}

		@Override
		public long getRoleid() { // 角色ID
			_xdb_verify_unsafe_();
			return roleid;
		}

		@Override
		public int getItemid() { // 锁定的道具ID
			_xdb_verify_unsafe_();
			return itemid;
		}

		@Override
		public int getItemkey() { // 锁定的道具在背包中的key
			_xdb_verify_unsafe_();
			return itemkey;
		}

		@Override
		public long getPetid() { // 锁定的宠物ID（如果是宠物交易）
			_xdb_verify_unsafe_();
			return petid;
		}

		@Override
		public long getLocktime() { // 锁定时间
			_xdb_verify_unsafe_();
			return locktime;
		}

		@Override
		public int getLocktype() { // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
			_xdb_verify_unsafe_();
			return locktype;
		}

		@Override
		public void setTradingid(long _v_) { // 交易ID
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setRoleid(long _v_) { // 角色ID
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setItemid(int _v_) { // 锁定的道具ID
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setItemkey(int _v_) { // 锁定的道具在背包中的key
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPetid(long _v_) { // 锁定的宠物ID（如果是宠物交易）
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLocktime(long _v_) { // 锁定时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLocktype(int _v_) { // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
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
			return TradingLock.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return TradingLock.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return TradingLock.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return TradingLock.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return TradingLock.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return TradingLock.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return TradingLock.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return TradingLock.this.hashCode();
		}

		@Override
		public String toString() {
			return TradingLock.this.toString();
		}

	}

	public static final class Data implements xbean.TradingLock {
		private long tradingid; // 交易ID
		private long roleid; // 角色ID
		private int itemid; // 锁定的道具ID
		private int itemkey; // 锁定的道具在背包中的key
		private long petid; // 锁定的宠物ID（如果是宠物交易）
		private long locktime; // 锁定时间
		private int locktype; // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			petid = 0;
		}

		Data(xbean.TradingLock _o1_) {
			if (_o1_ instanceof TradingLock) assign((TradingLock)_o1_);
			else if (_o1_ instanceof TradingLock.Data) assign((TradingLock.Data)_o1_);
			else if (_o1_ instanceof TradingLock.Const) assign(((TradingLock.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(TradingLock _o_) {
			tradingid = _o_.tradingid;
			roleid = _o_.roleid;
			itemid = _o_.itemid;
			itemkey = _o_.itemkey;
			petid = _o_.petid;
			locktime = _o_.locktime;
			locktype = _o_.locktype;
		}

		private void assign(TradingLock.Data _o_) {
			tradingid = _o_.tradingid;
			roleid = _o_.roleid;
			itemid = _o_.itemid;
			itemkey = _o_.itemkey;
			petid = _o_.petid;
			locktime = _o_.locktime;
			locktype = _o_.locktype;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(tradingid);
			_os_.marshal(roleid);
			_os_.marshal(itemid);
			_os_.marshal(itemkey);
			_os_.marshal(petid);
			_os_.marshal(locktime);
			_os_.marshal(locktype);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			tradingid = _os_.unmarshal_long();
			roleid = _os_.unmarshal_long();
			itemid = _os_.unmarshal_int();
			itemkey = _os_.unmarshal_int();
			petid = _os_.unmarshal_long();
			locktime = _os_.unmarshal_long();
			locktype = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.TradingLock copy() {
			return new Data(this);
		}

		@Override
		public xbean.TradingLock toData() {
			return new Data(this);
		}

		public xbean.TradingLock toBean() {
			return new TradingLock(this, null, null);
		}

		@Override
		public xbean.TradingLock toDataIf() {
			return this;
		}

		public xbean.TradingLock toBeanIf() {
			return new TradingLock(this, null, null);
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
		public long getTradingid() { // 交易ID
			return tradingid;
		}

		@Override
		public long getRoleid() { // 角色ID
			return roleid;
		}

		@Override
		public int getItemid() { // 锁定的道具ID
			return itemid;
		}

		@Override
		public int getItemkey() { // 锁定的道具在背包中的key
			return itemkey;
		}

		@Override
		public long getPetid() { // 锁定的宠物ID（如果是宠物交易）
			return petid;
		}

		@Override
		public long getLocktime() { // 锁定时间
			return locktime;
		}

		@Override
		public int getLocktype() { // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
			return locktype;
		}

		@Override
		public void setTradingid(long _v_) { // 交易ID
			tradingid = _v_;
		}

		@Override
		public void setRoleid(long _v_) { // 角色ID
			roleid = _v_;
		}

		@Override
		public void setItemid(int _v_) { // 锁定的道具ID
			itemid = _v_;
		}

		@Override
		public void setItemkey(int _v_) { // 锁定的道具在背包中的key
			itemkey = _v_;
		}

		@Override
		public void setPetid(long _v_) { // 锁定的宠物ID（如果是宠物交易）
			petid = _v_;
		}

		@Override
		public void setLocktime(long _v_) { // 锁定时间
			locktime = _v_;
		}

		@Override
		public void setLocktype(int _v_) { // 锁定类型：1=普通交易 2=市场交易 3=黑市交易 4=藏宝阁交易
			locktype = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof TradingLock.Data)) return false;
			TradingLock.Data _o_ = (TradingLock.Data) _o1_;
			if (tradingid != _o_.tradingid) return false;
			if (roleid != _o_.roleid) return false;
			if (itemid != _o_.itemid) return false;
			if (itemkey != _o_.itemkey) return false;
			if (petid != _o_.petid) return false;
			if (locktime != _o_.locktime) return false;
			if (locktype != _o_.locktype) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += tradingid;
			_h_ += roleid;
			_h_ += itemid;
			_h_ += itemkey;
			_h_ += petid;
			_h_ += locktime;
			_h_ += locktype;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(tradingid);
			_sb_.append(",");
			_sb_.append(roleid);
			_sb_.append(",");
			_sb_.append(itemid);
			_sb_.append(",");
			_sb_.append(itemkey);
			_sb_.append(",");
			_sb_.append(petid);
			_sb_.append(",");
			_sb_.append(locktime);
			_sb_.append(",");
			_sb_.append(locktype);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
