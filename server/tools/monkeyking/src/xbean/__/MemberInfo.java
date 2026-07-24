
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class MemberInfo extends mkdb.XBean implements xbean.MemberInfo {
	private int id; // 
	private String name; // 
	private long offline; // 
	private int level; // 
	private int menpai; // 

	@Override
	public void _reset_unsafe_() {
		id = 0;
		name = "";
		offline = 0L;
		level = 0;
		menpai = 0;
	}

	MemberInfo(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		name = "";
	}

	public MemberInfo() {
		this(0, null, null);
	}

	public MemberInfo(MemberInfo _o_) {
		this(_o_, null, null);
	}

	MemberInfo(xbean.MemberInfo _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof MemberInfo) assign((MemberInfo)_o1_);
		else if (_o1_ instanceof MemberInfo.Data) assign((MemberInfo.Data)_o1_);
		else if (_o1_ instanceof MemberInfo.Const) assign(((MemberInfo.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(MemberInfo _o_) {
		id = _o_.id;
		name = _o_.name;
		offline = _o_.offline;
		level = _o_.level;
		menpai = _o_.menpai;
	}

	private void assign(MemberInfo.Data _o_) {
		id = _o_.id;
		name = _o_.name;
		offline = _o_.offline;
		level = _o_.level;
		menpai = _o_.menpai;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		_os_.marshal(name, mkdb.Const.IO_CHARSET);
		_os_.marshal(offline);
		_os_.marshal(level);
		_os_.marshal(menpai);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		name = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		offline = _os_.unmarshal_long();
		level = _os_.unmarshal_int();
		menpai = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.MemberInfo copy() {
		return new MemberInfo(this);
	}

	@Override
	public xbean.MemberInfo toData() {
		return new Data(this);
	}

	public xbean.MemberInfo toBean() {
		return new MemberInfo(this); // same as copy()
	}

	@Override
	public xbean.MemberInfo toDataIf() {
		return new Data(this);
	}

	public xbean.MemberInfo toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // 
		return id;
	}

	@Override
	public String getName() { // 
		return name;
	}

	@Override
	public com.locojoy.base.Octets getNameOctets() { // 
		return com.locojoy.base.Octets.wrap(getName(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public long getOffline() { // 
		return offline;
	}

	@Override
	public int getLevel() { // 
		return level;
	}

	@Override
	public int getMenpai() { // 
		return menpai;
	}

	@Override
	public void setId(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setName(String _v_) { // 
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "name") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, name) {
					public void rollback() { name = _xdb_saved; }
				};}});
		name = _v_;
	}

	@Override
	public void setNameOctets(com.locojoy.base.Octets _v_) { // 
		this.setName(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setOffline(long _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "offline") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, offline) {
					public void rollback() { offline = _xdb_saved; }
				};}});
		offline = _v_;
	}

	@Override
	public void setLevel(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "level") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, level) {
					public void rollback() { level = _xdb_saved; }
				};}});
		level = _v_;
	}

	@Override
	public void setMenpai(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "menpai") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, menpai) {
					public void rollback() { menpai = _xdb_saved; }
				};}});
		menpai = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		MemberInfo _o_ = null;
		if ( _o1_ instanceof MemberInfo ) _o_ = (MemberInfo)_o1_;
		else if ( _o1_ instanceof MemberInfo.Const ) _o_ = ((MemberInfo.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (!name.equals(_o_.name)) return false;
		if (offline != _o_.offline) return false;
		if (level != _o_.level) return false;
		if (menpai != _o_.menpai) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		_h_ += name.hashCode();
		_h_ += offline;
		_h_ += level;
		_h_ += menpai;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append("'").append(name).append("'");
		_sb_.append(",");
		_sb_.append(offline);
		_sb_.append(",");
		_sb_.append(level);
		_sb_.append(",");
		_sb_.append(menpai);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("name"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("offline"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("level"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("menpai"));
		return lb;
	}

	private class Const implements xbean.MemberInfo {
		MemberInfo nThis() {
			return MemberInfo.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.MemberInfo copy() {
			return MemberInfo.this.copy();
		}

		@Override
		public xbean.MemberInfo toData() {
			return MemberInfo.this.toData();
		}

		public xbean.MemberInfo toBean() {
			return MemberInfo.this.toBean();
		}

		@Override
		public xbean.MemberInfo toDataIf() {
			return MemberInfo.this.toDataIf();
		}

		public xbean.MemberInfo toBeanIf() {
			return MemberInfo.this.toBeanIf();
		}

		@Override
		public int getId() { // 
			return id;
		}

		@Override
		public String getName() { // 
			return name;
		}

		@Override
		public com.locojoy.base.Octets getNameOctets() { // 
			return MemberInfo.this.getNameOctets();
		}

		@Override
		public long getOffline() { // 
			return offline;
		}

		@Override
		public int getLevel() { // 
			return level;
		}

		@Override
		public int getMenpai() { // 
			return menpai;
		}

		@Override
		public void setId(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setName(String _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setNameOctets(com.locojoy.base.Octets _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setOffline(long _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLevel(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMenpai(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean toConst() {
			return this;
		}

		@Override
		public boolean isConst() {
			return true;
		}

		@Override
		public boolean isData() {
			return MemberInfo.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return MemberInfo.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return MemberInfo.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return MemberInfo.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return MemberInfo.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return MemberInfo.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return MemberInfo.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return MemberInfo.this.hashCode();
		}

		@Override
		public String toString() {
			return MemberInfo.this.toString();
		}

	}

	public static final class Data implements xbean.MemberInfo {
		private int id; // 
		private String name; // 
		private long offline; // 
		private int level; // 
		private int menpai; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			name = "";
		}

		Data(xbean.MemberInfo _o1_) {
			if (_o1_ instanceof MemberInfo) assign((MemberInfo)_o1_);
			else if (_o1_ instanceof MemberInfo.Data) assign((MemberInfo.Data)_o1_);
			else if (_o1_ instanceof MemberInfo.Const) assign(((MemberInfo.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(MemberInfo _o_) {
			id = _o_.id;
			name = _o_.name;
			offline = _o_.offline;
			level = _o_.level;
			menpai = _o_.menpai;
		}

		private void assign(MemberInfo.Data _o_) {
			id = _o_.id;
			name = _o_.name;
			offline = _o_.offline;
			level = _o_.level;
			menpai = _o_.menpai;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(name, mkdb.Const.IO_CHARSET);
			_os_.marshal(offline);
			_os_.marshal(level);
			_os_.marshal(menpai);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			name = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			offline = _os_.unmarshal_long();
			level = _os_.unmarshal_int();
			menpai = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.MemberInfo copy() {
			return new Data(this);
		}

		@Override
		public xbean.MemberInfo toData() {
			return new Data(this);
		}

		public xbean.MemberInfo toBean() {
			return new MemberInfo(this, null, null);
		}

		@Override
		public xbean.MemberInfo toDataIf() {
			return this;
		}

		public xbean.MemberInfo toBeanIf() {
			return new MemberInfo(this, null, null);
		}

		// mkdb.Bean interface. Data Unsupported
		public boolean xdbManaged() { throw new UnsupportedOperationException(); }
		public mkdb.Bean xdbParent() { throw new UnsupportedOperationException(); }
		public String xdbVarname()  { throw new UnsupportedOperationException(); }
		public Long    xdbObjId()   { throw new UnsupportedOperationException(); }
		public mkdb.Bean toConst()   { throw new UnsupportedOperationException(); }
		public boolean isConst()    { return false; }
		public boolean isData()     { return true; }

		@Override
		public int getId() { // 
			return id;
		}

		@Override
		public String getName() { // 
			return name;
		}

		@Override
		public com.locojoy.base.Octets getNameOctets() { // 
			return com.locojoy.base.Octets.wrap(getName(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public long getOffline() { // 
			return offline;
		}

		@Override
		public int getLevel() { // 
			return level;
		}

		@Override
		public int getMenpai() { // 
			return menpai;
		}

		@Override
		public void setId(int _v_) { // 
			id = _v_;
		}

		@Override
		public void setName(String _v_) { // 
			if (null == _v_)
				throw new NullPointerException();
			name = _v_;
		}

		@Override
		public void setNameOctets(com.locojoy.base.Octets _v_) { // 
			this.setName(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setOffline(long _v_) { // 
			offline = _v_;
		}

		@Override
		public void setLevel(int _v_) { // 
			level = _v_;
		}

		@Override
		public void setMenpai(int _v_) { // 
			menpai = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof MemberInfo.Data)) return false;
			MemberInfo.Data _o_ = (MemberInfo.Data) _o1_;
			if (id != _o_.id) return false;
			if (!name.equals(_o_.name)) return false;
			if (offline != _o_.offline) return false;
			if (level != _o_.level) return false;
			if (menpai != _o_.menpai) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += name.hashCode();
			_h_ += offline;
			_h_ += level;
			_h_ += menpai;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append("'").append(name).append("'");
			_sb_.append(",");
			_sb_.append(offline);
			_sb_.append(",");
			_sb_.append(level);
			_sb_.append(",");
			_sb_.append(menpai);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
