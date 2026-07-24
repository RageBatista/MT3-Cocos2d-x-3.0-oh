
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class NetBar extends mkdb.XBean implements xbean.NetBar {
	private int id; // barid
	private String barname; // barname
	private int level; // level

	@Override
	public void _reset_unsafe_() {
		id = 0;
		barname = "";
		level = 0;
	}

	NetBar(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		barname = "";
	}

	public NetBar() {
		this(0, null, null);
	}

	public NetBar(NetBar _o_) {
		this(_o_, null, null);
	}

	NetBar(xbean.NetBar _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof NetBar) assign((NetBar)_o1_);
		else if (_o1_ instanceof NetBar.Data) assign((NetBar.Data)_o1_);
		else if (_o1_ instanceof NetBar.Const) assign(((NetBar.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(NetBar _o_) {
		id = _o_.id;
		barname = _o_.barname;
		level = _o_.level;
	}

	private void assign(NetBar.Data _o_) {
		id = _o_.id;
		barname = _o_.barname;
		level = _o_.level;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		_os_.marshal(barname, mkdb.Const.IO_CHARSET);
		_os_.marshal(level);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		barname = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		level = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.NetBar copy() {
		return new NetBar(this);
	}

	@Override
	public xbean.NetBar toData() {
		return new Data(this);
	}

	public xbean.NetBar toBean() {
		return new NetBar(this); // same as copy()
	}

	@Override
	public xbean.NetBar toDataIf() {
		return new Data(this);
	}

	public xbean.NetBar toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // barid
		return id;
	}

	@Override
	public String getBarname() { // barname
		return barname;
	}

	@Override
	public com.locojoy.base.Octets getBarnameOctets() { // barname
		return com.locojoy.base.Octets.wrap(getBarname(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public int getLevel() { // level
		return level;
	}

	@Override
	public void setId(int _v_) { // barid
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setBarname(String _v_) { // barname
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "barname") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, barname) {
					public void rollback() { barname = _xdb_saved; }
				};}});
		barname = _v_;
	}

	@Override
	public void setBarnameOctets(com.locojoy.base.Octets _v_) { // barname
		this.setBarname(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setLevel(int _v_) { // level
		mkdb.Logs.logIf(new mkdb.LogKey(this, "level") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, level) {
					public void rollback() { level = _xdb_saved; }
				};}});
		level = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		NetBar _o_ = null;
		if ( _o1_ instanceof NetBar ) _o_ = (NetBar)_o1_;
		else if ( _o1_ instanceof NetBar.Const ) _o_ = ((NetBar.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (!barname.equals(_o_.barname)) return false;
		if (level != _o_.level) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		_h_ += barname.hashCode();
		_h_ += level;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append("'").append(barname).append("'");
		_sb_.append(",");
		_sb_.append(level);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("barname"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("level"));
		return lb;
	}

	private class Const implements xbean.NetBar {
		NetBar nThis() {
			return NetBar.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.NetBar copy() {
			return NetBar.this.copy();
		}

		@Override
		public xbean.NetBar toData() {
			return NetBar.this.toData();
		}

		public xbean.NetBar toBean() {
			return NetBar.this.toBean();
		}

		@Override
		public xbean.NetBar toDataIf() {
			return NetBar.this.toDataIf();
		}

		public xbean.NetBar toBeanIf() {
			return NetBar.this.toBeanIf();
		}

		@Override
		public int getId() { // barid
			return id;
		}

		@Override
		public String getBarname() { // barname
			return barname;
		}

		@Override
		public com.locojoy.base.Octets getBarnameOctets() { // barname
			return NetBar.this.getBarnameOctets();
		}

		@Override
		public int getLevel() { // level
			return level;
		}

		@Override
		public void setId(int _v_) { // barid
			throw new UnsupportedOperationException();
		}

		@Override
		public void setBarname(String _v_) { // barname
			throw new UnsupportedOperationException();
		}

		@Override
		public void setBarnameOctets(com.locojoy.base.Octets _v_) { // barname
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLevel(int _v_) { // level
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
			return NetBar.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return NetBar.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return NetBar.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return NetBar.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return NetBar.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return NetBar.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return NetBar.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return NetBar.this.hashCode();
		}

		@Override
		public String toString() {
			return NetBar.this.toString();
		}

	}

	public static final class Data implements xbean.NetBar {
		private int id; // barid
		private String barname; // barname
		private int level; // level

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			barname = "";
		}

		Data(xbean.NetBar _o1_) {
			if (_o1_ instanceof NetBar) assign((NetBar)_o1_);
			else if (_o1_ instanceof NetBar.Data) assign((NetBar.Data)_o1_);
			else if (_o1_ instanceof NetBar.Const) assign(((NetBar.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(NetBar _o_) {
			id = _o_.id;
			barname = _o_.barname;
			level = _o_.level;
		}

		private void assign(NetBar.Data _o_) {
			id = _o_.id;
			barname = _o_.barname;
			level = _o_.level;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(barname, mkdb.Const.IO_CHARSET);
			_os_.marshal(level);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			barname = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			level = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.NetBar copy() {
			return new Data(this);
		}

		@Override
		public xbean.NetBar toData() {
			return new Data(this);
		}

		public xbean.NetBar toBean() {
			return new NetBar(this, null, null);
		}

		@Override
		public xbean.NetBar toDataIf() {
			return this;
		}

		public xbean.NetBar toBeanIf() {
			return new NetBar(this, null, null);
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
		public int getId() { // barid
			return id;
		}

		@Override
		public String getBarname() { // barname
			return barname;
		}

		@Override
		public com.locojoy.base.Octets getBarnameOctets() { // barname
			return com.locojoy.base.Octets.wrap(getBarname(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public int getLevel() { // level
			return level;
		}

		@Override
		public void setId(int _v_) { // barid
			id = _v_;
		}

		@Override
		public void setBarname(String _v_) { // barname
			if (null == _v_)
				throw new NullPointerException();
			barname = _v_;
		}

		@Override
		public void setBarnameOctets(com.locojoy.base.Octets _v_) { // barname
			this.setBarname(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setLevel(int _v_) { // level
			level = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof NetBar.Data)) return false;
			NetBar.Data _o_ = (NetBar.Data) _o1_;
			if (id != _o_.id) return false;
			if (!barname.equals(_o_.barname)) return false;
			if (level != _o_.level) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += barname.hashCode();
			_h_ += level;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append("'").append(barname).append("'");
			_sb_.append(",");
			_sb_.append(level);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
