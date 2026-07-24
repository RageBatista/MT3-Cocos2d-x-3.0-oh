
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class fxbean0 extends mkdb.XBean implements xbean.fxbean0 {
	private mkdb.util.SetX<Boolean> a; // 
	private java.util.LinkedList<xbean.fcbean> b; // 

	@Override
	public void _reset_unsafe_() {
		a.clear();
		b.clear();
	}

	fxbean0(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		a = new mkdb.util.SetX<Boolean>();
		b = new java.util.LinkedList<xbean.fcbean>();
	}

	public fxbean0() {
		this(0, null, null);
	}

	public fxbean0(fxbean0 _o_) {
		this(_o_, null, null);
	}

	fxbean0(xbean.fxbean0 _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof fxbean0) assign((fxbean0)_o1_);
		else if (_o1_ instanceof fxbean0.Data) assign((fxbean0.Data)_o1_);
		else if (_o1_ instanceof fxbean0.Const) assign(((fxbean0.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(fxbean0 _o_) {
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
	}

	private void assign(fxbean0.Data _o_) {
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(a.size());
		for (Boolean _v_ : a) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(b.size());
		for (xbean.fcbean _v_ : b) {
			_v_.marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			boolean _v_ = false;
			_v_ = _os_.unmarshal_boolean();
			a.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.fcbean _v_ = new xbean.fcbean();
			_v_.unmarshal(_os_);
			b.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.fxbean0 copy() {
		return new fxbean0(this);
	}

	@Override
	public xbean.fxbean0 toData() {
		return new Data(this);
	}

	public xbean.fxbean0 toBean() {
		return new fxbean0(this); // same as copy()
	}

	@Override
	public xbean.fxbean0 toDataIf() {
		return new Data(this);
	}

	public xbean.fxbean0 toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Set<Boolean> getA() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "a"), a);
	}

	public java.util.Set<Boolean> getAAsData() { // 
		java.util.Set<Boolean> a;
		fxbean0 _o_ = this;
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
		return a;
	}

	@Override
	public java.util.List<xbean.fcbean> getB() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "b"), b);
	}

	public java.util.List<xbean.fcbean> getBAsData() { // 
		java.util.List<xbean.fcbean> b;
		fxbean0 _o_ = this;
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
		return b;
	}

	@Override
	public final boolean equals(Object _o1_) {
		fxbean0 _o_ = null;
		if ( _o1_ instanceof fxbean0 ) _o_ = (fxbean0)_o1_;
		else if ( _o1_ instanceof fxbean0.Const ) _o_ = ((fxbean0.Const)_o1_).nThis();
		else return false;
		if (!a.equals(_o_.a)) return false;
		if (!b.equals(_o_.b)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += a.hashCode();
		_h_ += b.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(a);
		_sb_.append(",");
		_sb_.append(b);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableSet().setVarName("a"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("b"));
		return lb;
	}

	private class Const implements xbean.fxbean0 {
		fxbean0 nThis() {
			return fxbean0.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.fxbean0 copy() {
			return fxbean0.this.copy();
		}

		@Override
		public xbean.fxbean0 toData() {
			return fxbean0.this.toData();
		}

		public xbean.fxbean0 toBean() {
			return fxbean0.this.toBean();
		}

		@Override
		public xbean.fxbean0 toDataIf() {
			return fxbean0.this.toDataIf();
		}

		public xbean.fxbean0 toBeanIf() {
			return fxbean0.this.toBeanIf();
		}

		@Override
		public java.util.Set<Boolean> getA() { // 
			return mkdb.Consts.constSet(a);
		}

		public java.util.Set<Boolean> getAAsData() { // 
			java.util.Set<Boolean> a;
			fxbean0 _o_ = fxbean0.this;
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
			return a;
		}

		@Override
		public java.util.List<xbean.fcbean> getB() { // 
			return mkdb.Consts.constList(b);
		}

		public java.util.List<xbean.fcbean> getBAsData() { // 
			java.util.List<xbean.fcbean> b;
			fxbean0 _o_ = fxbean0.this;
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
			return b;
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
			return fxbean0.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return fxbean0.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return fxbean0.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return fxbean0.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return fxbean0.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return fxbean0.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return fxbean0.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return fxbean0.this.hashCode();
		}

		@Override
		public String toString() {
			return fxbean0.this.toString();
		}

	}

	public static final class Data implements xbean.fxbean0 {
		private java.util.HashSet<Boolean> a; // 
		private java.util.LinkedList<xbean.fcbean> b; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			a = new java.util.HashSet<Boolean>();
			b = new java.util.LinkedList<xbean.fcbean>();
		}

		Data(xbean.fxbean0 _o1_) {
			if (_o1_ instanceof fxbean0) assign((fxbean0)_o1_);
			else if (_o1_ instanceof fxbean0.Data) assign((fxbean0.Data)_o1_);
			else if (_o1_ instanceof fxbean0.Const) assign(((fxbean0.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(fxbean0 _o_) {
			a = new java.util.HashSet<Boolean>();
			a.addAll(_o_.a);
			b = new java.util.LinkedList<xbean.fcbean>();
			b.addAll(_o_.b);
		}

		private void assign(fxbean0.Data _o_) {
			a = new java.util.HashSet<Boolean>();
			a.addAll(_o_.a);
			b = new java.util.LinkedList<xbean.fcbean>();
			b.addAll(_o_.b);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(a.size());
			for (Boolean _v_ : a) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(b.size());
			for (xbean.fcbean _v_ : b) {
				_v_.marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				boolean _v_ = false;
				_v_ = _os_.unmarshal_boolean();
				a.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.fcbean _v_ = new xbean.fcbean();
				_v_.unmarshal(_os_);
				b.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.fxbean0 copy() {
			return new Data(this);
		}

		@Override
		public xbean.fxbean0 toData() {
			return new Data(this);
		}

		public xbean.fxbean0 toBean() {
			return new fxbean0(this, null, null);
		}

		@Override
		public xbean.fxbean0 toDataIf() {
			return this;
		}

		public xbean.fxbean0 toBeanIf() {
			return new fxbean0(this, null, null);
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
		public java.util.Set<Boolean> getA() { // 
			return a;
		}

		@Override
		public java.util.Set<Boolean> getAAsData() { // 
			return a;
		}

		@Override
		public java.util.List<xbean.fcbean> getB() { // 
			return b;
		}

		@Override
		public java.util.List<xbean.fcbean> getBAsData() { // 
			return b;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof fxbean0.Data)) return false;
			fxbean0.Data _o_ = (fxbean0.Data) _o1_;
			if (!a.equals(_o_.a)) return false;
			if (!b.equals(_o_.b)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += a.hashCode();
			_h_ += b.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(a);
			_sb_.append(",");
			_sb_.append(b);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
