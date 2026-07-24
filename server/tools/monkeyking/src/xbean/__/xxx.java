
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class xxx extends mkdb.XBean implements xbean.xxx {
	private mkdb.util.SetX<Integer> a; // 
	private xbean.yyy b; // 
	private String c; // 

	@Override
	public void _reset_unsafe_() {
		a.clear();
		b._reset_unsafe_();
		c = "";
	}

	xxx(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		a = new mkdb.util.SetX<Integer>();
		b = new yyy(0, this, "b");
		c = "";
	}

	public xxx() {
		this(0, null, null);
	}

	public xxx(xxx _o_) {
		this(_o_, null, null);
	}

	xxx(xbean.xxx _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof xxx) assign((xxx)_o1_);
		else if (_o1_ instanceof xxx.Data) assign((xxx.Data)_o1_);
		else if (_o1_ instanceof xxx.Const) assign(((xxx.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(xxx _o_) {
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
		b = new yyy(_o_.b, this, "b");
		c = _o_.c;
	}

	private void assign(xxx.Data _o_) {
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
		b = new yyy(_o_.b, this, "b");
		c = _o_.c;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(a.size());
		for (Integer _v_ : a) {
			_os_.marshal(_v_);
		}
		b.marshal(_os_);
		_os_.marshal(c, mkdb.Const.IO_CHARSET);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			a.add(_v_);
		}
		b.unmarshal(_os_);
		c = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		return _os_;
	}

	@Override
	public xbean.xxx copy() {
		return new xxx(this);
	}

	@Override
	public xbean.xxx toData() {
		return new Data(this);
	}

	public xbean.xxx toBean() {
		return new xxx(this); // same as copy()
	}

	@Override
	public xbean.xxx toDataIf() {
		return new Data(this);
	}

	public xbean.xxx toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Set<Integer> getA() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "a"), a);
	}

	public java.util.Set<Integer> getAAsData() { // 
		java.util.Set<Integer> a;
		xxx _o_ = this;
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
		return a;
	}

	@Override
	public xbean.yyy getB() { // 
		return b;
	}

	@Override
	public String getC() { // 
		return c;
	}

	@Override
	public com.locojoy.base.Octets getCOctets() { // 
		return com.locojoy.base.Octets.wrap(getC(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public void setC(String _v_) { // 
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "c") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, c) {
					public void rollback() { c = _xdb_saved; }
				};}});
		c = _v_;
	}

	@Override
	public void setCOctets(com.locojoy.base.Octets _v_) { // 
		this.setC(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public final boolean equals(Object _o1_) {
		xxx _o_ = null;
		if ( _o1_ instanceof xxx ) _o_ = (xxx)_o1_;
		else if ( _o1_ instanceof xxx.Const ) _o_ = ((xxx.Const)_o1_).nThis();
		else return false;
		if (!a.equals(_o_.a)) return false;
		if (!b.equals(_o_.b)) return false;
		if (!c.equals(_o_.c)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += a.hashCode();
		_h_ += b.hashCode();
		_h_ += c.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(a);
		_sb_.append(",");
		_sb_.append(b);
		_sb_.append(",");
		_sb_.append("'").append(c).append("'");
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableSet().setVarName("a"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("b"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("c"));
		return lb;
	}

	private class Const implements xbean.xxx {
		xxx nThis() {
			return xxx.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.xxx copy() {
			return xxx.this.copy();
		}

		@Override
		public xbean.xxx toData() {
			return xxx.this.toData();
		}

		public xbean.xxx toBean() {
			return xxx.this.toBean();
		}

		@Override
		public xbean.xxx toDataIf() {
			return xxx.this.toDataIf();
		}

		public xbean.xxx toBeanIf() {
			return xxx.this.toBeanIf();
		}

		@Override
		public java.util.Set<Integer> getA() { // 
			return mkdb.Consts.constSet(a);
		}

		public java.util.Set<Integer> getAAsData() { // 
			java.util.Set<Integer> a;
			xxx _o_ = xxx.this;
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
			return a;
		}

		@Override
		public xbean.yyy getB() { // 
			return mkdb.Consts.toConst(b);
		}

		@Override
		public String getC() { // 
			return c;
		}

		@Override
		public com.locojoy.base.Octets getCOctets() { // 
			return xxx.this.getCOctets();
		}

		@Override
		public void setC(String _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setCOctets(com.locojoy.base.Octets _v_) { // 
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
			return xxx.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return xxx.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return xxx.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return xxx.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return xxx.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return xxx.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return xxx.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return xxx.this.hashCode();
		}

		@Override
		public String toString() {
			return xxx.this.toString();
		}

	}

	public static final class Data implements xbean.xxx {
		private java.util.HashSet<Integer> a; // 
		private xbean.yyy b; // 
		private String c; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			a = new java.util.HashSet<Integer>();
			b = new yyy.Data();
			c = "";
		}

		Data(xbean.xxx _o1_) {
			if (_o1_ instanceof xxx) assign((xxx)_o1_);
			else if (_o1_ instanceof xxx.Data) assign((xxx.Data)_o1_);
			else if (_o1_ instanceof xxx.Const) assign(((xxx.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(xxx _o_) {
			a = new java.util.HashSet<Integer>();
			a.addAll(_o_.a);
			b = new yyy.Data(_o_.b);
			c = _o_.c;
		}

		private void assign(xxx.Data _o_) {
			a = new java.util.HashSet<Integer>();
			a.addAll(_o_.a);
			b = new yyy.Data(_o_.b);
			c = _o_.c;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(a.size());
			for (Integer _v_ : a) {
				_os_.marshal(_v_);
			}
			b.marshal(_os_);
			_os_.marshal(c, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				a.add(_v_);
			}
			b.unmarshal(_os_);
			c = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public xbean.xxx copy() {
			return new Data(this);
		}

		@Override
		public xbean.xxx toData() {
			return new Data(this);
		}

		public xbean.xxx toBean() {
			return new xxx(this, null, null);
		}

		@Override
		public xbean.xxx toDataIf() {
			return this;
		}

		public xbean.xxx toBeanIf() {
			return new xxx(this, null, null);
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
		public java.util.Set<Integer> getA() { // 
			return a;
		}

		@Override
		public java.util.Set<Integer> getAAsData() { // 
			return a;
		}

		@Override
		public xbean.yyy getB() { // 
			return b;
		}

		@Override
		public String getC() { // 
			return c;
		}

		@Override
		public com.locojoy.base.Octets getCOctets() { // 
			return com.locojoy.base.Octets.wrap(getC(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public void setC(String _v_) { // 
			if (null == _v_)
				throw new NullPointerException();
			c = _v_;
		}

		@Override
		public void setCOctets(com.locojoy.base.Octets _v_) { // 
			this.setC(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof xxx.Data)) return false;
			xxx.Data _o_ = (xxx.Data) _o1_;
			if (!a.equals(_o_.a)) return false;
			if (!b.equals(_o_.b)) return false;
			if (!c.equals(_o_.c)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += a.hashCode();
			_h_ += b.hashCode();
			_h_ += c.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(a);
			_sb_.append(",");
			_sb_.append(b);
			_sb_.append(",");
			_sb_.append("'").append(c).append("'");
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
