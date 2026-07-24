
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class yyy extends mkdb.XBean implements xbean.yyy {
	private mkdb.util.SetX<Integer> a; // 
	private int b; // 
	private String c; // 

	@Override
	public void _reset_unsafe_() {
		a.clear();
		b = 0;
		c = "";
	}

	yyy(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		a = new mkdb.util.SetX<Integer>();
		c = "";
	}

	public yyy() {
		this(0, null, null);
	}

	public yyy(yyy _o_) {
		this(_o_, null, null);
	}

	yyy(xbean.yyy _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof yyy) assign((yyy)_o1_);
		else if (_o1_ instanceof yyy.Data) assign((yyy.Data)_o1_);
		else if (_o1_ instanceof yyy.Const) assign(((yyy.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(yyy _o_) {
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
		b = _o_.b;
		c = _o_.c;
	}

	private void assign(yyy.Data _o_) {
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
		b = _o_.b;
		c = _o_.c;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(a.size());
		for (Integer _v_ : a) {
			_os_.marshal(_v_);
		}
		_os_.marshal(b);
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
		b = _os_.unmarshal_int();
		c = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		return _os_;
	}

	@Override
	public xbean.yyy copy() {
		return new yyy(this);
	}

	@Override
	public xbean.yyy toData() {
		return new Data(this);
	}

	public xbean.yyy toBean() {
		return new yyy(this); // same as copy()
	}

	@Override
	public xbean.yyy toDataIf() {
		return new Data(this);
	}

	public xbean.yyy toBeanIf() {
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
		yyy _o_ = this;
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
		return a;
	}

	@Override
	public int getB() { // 
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
	public void setB(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "b") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, b) {
					public void rollback() { b = _xdb_saved; }
				};}});
		b = _v_;
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
		yyy _o_ = null;
		if ( _o1_ instanceof yyy ) _o_ = (yyy)_o1_;
		else if ( _o1_ instanceof yyy.Const ) _o_ = ((yyy.Const)_o1_).nThis();
		else return false;
		if (!a.equals(_o_.a)) return false;
		if (b != _o_.b) return false;
		if (!c.equals(_o_.c)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += a.hashCode();
		_h_ += b;
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

	private class Const implements xbean.yyy {
		yyy nThis() {
			return yyy.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.yyy copy() {
			return yyy.this.copy();
		}

		@Override
		public xbean.yyy toData() {
			return yyy.this.toData();
		}

		public xbean.yyy toBean() {
			return yyy.this.toBean();
		}

		@Override
		public xbean.yyy toDataIf() {
			return yyy.this.toDataIf();
		}

		public xbean.yyy toBeanIf() {
			return yyy.this.toBeanIf();
		}

		@Override
		public java.util.Set<Integer> getA() { // 
			return mkdb.Consts.constSet(a);
		}

		public java.util.Set<Integer> getAAsData() { // 
			java.util.Set<Integer> a;
			yyy _o_ = yyy.this;
		a = new mkdb.util.SetX<Integer>();
		a.addAll(_o_.a);
			return a;
		}

		@Override
		public int getB() { // 
			return b;
		}

		@Override
		public String getC() { // 
			return c;
		}

		@Override
		public com.locojoy.base.Octets getCOctets() { // 
			return yyy.this.getCOctets();
		}

		@Override
		public void setB(int _v_) { // 
			throw new UnsupportedOperationException();
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
			return yyy.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return yyy.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return yyy.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return yyy.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return yyy.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return yyy.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return yyy.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return yyy.this.hashCode();
		}

		@Override
		public String toString() {
			return yyy.this.toString();
		}

	}

	public static final class Data implements xbean.yyy {
		private java.util.HashSet<Integer> a; // 
		private int b; // 
		private String c; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			a = new java.util.HashSet<Integer>();
			c = "";
		}

		Data(xbean.yyy _o1_) {
			if (_o1_ instanceof yyy) assign((yyy)_o1_);
			else if (_o1_ instanceof yyy.Data) assign((yyy.Data)_o1_);
			else if (_o1_ instanceof yyy.Const) assign(((yyy.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(yyy _o_) {
			a = new java.util.HashSet<Integer>();
			a.addAll(_o_.a);
			b = _o_.b;
			c = _o_.c;
		}

		private void assign(yyy.Data _o_) {
			a = new java.util.HashSet<Integer>();
			a.addAll(_o_.a);
			b = _o_.b;
			c = _o_.c;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(a.size());
			for (Integer _v_ : a) {
				_os_.marshal(_v_);
			}
			_os_.marshal(b);
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
			b = _os_.unmarshal_int();
			c = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public xbean.yyy copy() {
			return new Data(this);
		}

		@Override
		public xbean.yyy toData() {
			return new Data(this);
		}

		public xbean.yyy toBean() {
			return new yyy(this, null, null);
		}

		@Override
		public xbean.yyy toDataIf() {
			return this;
		}

		public xbean.yyy toBeanIf() {
			return new yyy(this, null, null);
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
		public int getB() { // 
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
		public void setB(int _v_) { // 
			b = _v_;
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
			if (!(_o1_ instanceof yyy.Data)) return false;
			yyy.Data _o_ = (yyy.Data) _o1_;
			if (!a.equals(_o_.a)) return false;
			if (b != _o_.b) return false;
			if (!c.equals(_o_.c)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += a.hashCode();
			_h_ += b;
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
