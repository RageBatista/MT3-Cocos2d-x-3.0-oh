
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class xbeanwithcbean extends mkdb.XBean implements xbean.xbeanwithcbean {
	private xbean.xcompare xc1; // xcompare test
	private java.util.LinkedList<xbean.xcompare2> xc2; // xcompare2 test
	private float f; // float test

	@Override
	public void _reset_unsafe_() {
		xc1 = new xbean.xcompare();
		xc2.clear();
		f = 1;
	}

	xbeanwithcbean(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		xc1 = new xbean.xcompare();
		xc2 = new java.util.LinkedList<xbean.xcompare2>();
		f = 1;
	}

	public xbeanwithcbean() {
		this(0, null, null);
	}

	public xbeanwithcbean(xbeanwithcbean _o_) {
		this(_o_, null, null);
	}

	xbeanwithcbean(xbean.xbeanwithcbean _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof xbeanwithcbean) assign((xbeanwithcbean)_o1_);
		else if (_o1_ instanceof xbeanwithcbean.Data) assign((xbeanwithcbean.Data)_o1_);
		else if (_o1_ instanceof xbeanwithcbean.Const) assign(((xbeanwithcbean.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(xbeanwithcbean _o_) {
		xc1 = _o_.xc1;
		xc2 = new java.util.LinkedList<xbean.xcompare2>();
		xc2.addAll(_o_.xc2);
		f = _o_.f;
	}

	private void assign(xbeanwithcbean.Data _o_) {
		xc1 = _o_.xc1;
		xc2 = new java.util.LinkedList<xbean.xcompare2>();
		xc2.addAll(_o_.xc2);
		f = _o_.f;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		xc1.marshal(_os_);
		_os_.compact_uint32(xc2.size());
		for (xbean.xcompare2 _v_ : xc2) {
			_v_.marshal(_os_);
		}
		_os_.marshal(f);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		xc1.unmarshal(_os_);
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.xcompare2 _v_ = new xbean.xcompare2();
			_v_.unmarshal(_os_);
			xc2.add(_v_);
		}
		f = _os_.unmarshal_float();
		return _os_;
	}

	@Override
	public xbean.xbeanwithcbean copy() {
		return new xbeanwithcbean(this);
	}

	@Override
	public xbean.xbeanwithcbean toData() {
		return new Data(this);
	}

	public xbean.xbeanwithcbean toBean() {
		return new xbeanwithcbean(this); // same as copy()
	}

	@Override
	public xbean.xbeanwithcbean toDataIf() {
		return new Data(this);
	}

	public xbean.xbeanwithcbean toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public xbean.xcompare getXc1() { // xcompare test
		return xc1;
	}

	@Override
	public java.util.List<xbean.xcompare2> getXc2() { // xcompare2 test
		return mkdb.Logs.logList(new mkdb.LogKey(this, "xc2"), xc2);
	}

	public java.util.List<xbean.xcompare2> getXc2AsData() { // xcompare2 test
		java.util.List<xbean.xcompare2> xc2;
		xbeanwithcbean _o_ = this;
		xc2 = new java.util.LinkedList<xbean.xcompare2>();
		xc2.addAll(_o_.xc2);
		return xc2;
	}

	@Override
	public float getF() { // float test
		return f;
	}

	@Override
	public void setXc1(xbean.xcompare _v_) { // xcompare test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "xc1") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<xbean.xcompare>(this, xc1) {
					public void rollback() { xc1 = _xdb_saved; }
			}; }});
		xc1 = _v_;
	}

	@Override
	public void setF(float _v_) { // float test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "f") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogFloat(this, f) {
					public void rollback() { f = _xdb_saved; }
				};}});
		f = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		xbeanwithcbean _o_ = null;
		if ( _o1_ instanceof xbeanwithcbean ) _o_ = (xbeanwithcbean)_o1_;
		else if ( _o1_ instanceof xbeanwithcbean.Const ) _o_ = ((xbeanwithcbean.Const)_o1_).nThis();
		else return false;
		if (!xc1.equals(_o_.xc1)) return false;
		if (!xc2.equals(_o_.xc2)) return false;
		if (f != _o_.f) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += xc1.hashCode();
		_h_ += xc2.hashCode();
		_h_ += f;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(xc1);
		_sb_.append(",");
		_sb_.append(xc2);
		_sb_.append(",");
		_sb_.append(f);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("xc1"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("xc2"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("f"));
		return lb;
	}

	private class Const implements xbean.xbeanwithcbean {
		xbeanwithcbean nThis() {
			return xbeanwithcbean.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.xbeanwithcbean copy() {
			return xbeanwithcbean.this.copy();
		}

		@Override
		public xbean.xbeanwithcbean toData() {
			return xbeanwithcbean.this.toData();
		}

		public xbean.xbeanwithcbean toBean() {
			return xbeanwithcbean.this.toBean();
		}

		@Override
		public xbean.xbeanwithcbean toDataIf() {
			return xbeanwithcbean.this.toDataIf();
		}

		public xbean.xbeanwithcbean toBeanIf() {
			return xbeanwithcbean.this.toBeanIf();
		}

		@Override
		public xbean.xcompare getXc1() { // xcompare test
			return xc1;
		}

		@Override
		public java.util.List<xbean.xcompare2> getXc2() { // xcompare2 test
			return mkdb.Consts.constList(xc2);
		}

		public java.util.List<xbean.xcompare2> getXc2AsData() { // xcompare2 test
			java.util.List<xbean.xcompare2> xc2;
			xbeanwithcbean _o_ = xbeanwithcbean.this;
		xc2 = new java.util.LinkedList<xbean.xcompare2>();
		xc2.addAll(_o_.xc2);
			return xc2;
		}

		@Override
		public float getF() { // float test
			return f;
		}

		@Override
		public void setXc1(xbean.xcompare _v_) { // xcompare test
			throw new UnsupportedOperationException();
		}

		@Override
		public void setF(float _v_) { // float test
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
			return xbeanwithcbean.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return xbeanwithcbean.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return xbeanwithcbean.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return xbeanwithcbean.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return xbeanwithcbean.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return xbeanwithcbean.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return xbeanwithcbean.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return xbeanwithcbean.this.hashCode();
		}

		@Override
		public String toString() {
			return xbeanwithcbean.this.toString();
		}

	}

	public static final class Data implements xbean.xbeanwithcbean {
		private xbean.xcompare xc1; // xcompare test
		private java.util.LinkedList<xbean.xcompare2> xc2; // xcompare2 test
		private float f; // float test

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			xc1 = new xbean.xcompare();
			xc2 = new java.util.LinkedList<xbean.xcompare2>();
			f = 1;
		}

		Data(xbean.xbeanwithcbean _o1_) {
			if (_o1_ instanceof xbeanwithcbean) assign((xbeanwithcbean)_o1_);
			else if (_o1_ instanceof xbeanwithcbean.Data) assign((xbeanwithcbean.Data)_o1_);
			else if (_o1_ instanceof xbeanwithcbean.Const) assign(((xbeanwithcbean.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(xbeanwithcbean _o_) {
			xc1 = _o_.xc1;
			xc2 = new java.util.LinkedList<xbean.xcompare2>();
			xc2.addAll(_o_.xc2);
			f = _o_.f;
		}

		private void assign(xbeanwithcbean.Data _o_) {
			xc1 = _o_.xc1;
			xc2 = new java.util.LinkedList<xbean.xcompare2>();
			xc2.addAll(_o_.xc2);
			f = _o_.f;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			xc1.marshal(_os_);
			_os_.compact_uint32(xc2.size());
			for (xbean.xcompare2 _v_ : xc2) {
				_v_.marshal(_os_);
			}
			_os_.marshal(f);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			xc1.unmarshal(_os_);
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.xcompare2 _v_ = new xbean.xcompare2();
				_v_.unmarshal(_os_);
				xc2.add(_v_);
			}
			f = _os_.unmarshal_float();
			return _os_;
		}

		@Override
		public xbean.xbeanwithcbean copy() {
			return new Data(this);
		}

		@Override
		public xbean.xbeanwithcbean toData() {
			return new Data(this);
		}

		public xbean.xbeanwithcbean toBean() {
			return new xbeanwithcbean(this, null, null);
		}

		@Override
		public xbean.xbeanwithcbean toDataIf() {
			return this;
		}

		public xbean.xbeanwithcbean toBeanIf() {
			return new xbeanwithcbean(this, null, null);
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
		public xbean.xcompare getXc1() { // xcompare test
			return xc1;
		}

		@Override
		public java.util.List<xbean.xcompare2> getXc2() { // xcompare2 test
			return xc2;
		}

		@Override
		public java.util.List<xbean.xcompare2> getXc2AsData() { // xcompare2 test
			return xc2;
		}

		@Override
		public float getF() { // float test
			return f;
		}

		@Override
		public void setXc1(xbean.xcompare _v_) { // xcompare test
			xc1 = _v_;
		}

		@Override
		public void setF(float _v_) { // float test
			f = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof xbeanwithcbean.Data)) return false;
			xbeanwithcbean.Data _o_ = (xbeanwithcbean.Data) _o1_;
			if (!xc1.equals(_o_.xc1)) return false;
			if (!xc2.equals(_o_.xc2)) return false;
			if (f != _o_.f) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += xc1.hashCode();
			_h_ += xc2.hashCode();
			_h_ += f;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(xc1);
			_sb_.append(",");
			_sb_.append(xc2);
			_sb_.append(",");
			_sb_.append(f);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
