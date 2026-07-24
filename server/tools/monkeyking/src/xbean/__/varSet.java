
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class varSet extends mkdb.XBean implements xbean.varSet {
	private mkdb.util.SetX<Integer> v; // 

	@Override
	public void _reset_unsafe_() {
		v.clear();
	}

	varSet(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		v = new mkdb.util.SetX<Integer>();
	}

	public varSet() {
		this(0, null, null);
	}

	public varSet(varSet _o_) {
		this(_o_, null, null);
	}

	varSet(xbean.varSet _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof varSet) assign((varSet)_o1_);
		else if (_o1_ instanceof varSet.Data) assign((varSet.Data)_o1_);
		else if (_o1_ instanceof varSet.Const) assign(((varSet.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(varSet _o_) {
		v = new mkdb.util.SetX<Integer>();
		v.addAll(_o_.v);
	}

	private void assign(varSet.Data _o_) {
		v = new mkdb.util.SetX<Integer>();
		v.addAll(_o_.v);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(v.size());
		for (Integer _v_ : v) {
			_os_.marshal(_v_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			v.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.varSet copy() {
		return new varSet(this);
	}

	@Override
	public xbean.varSet toData() {
		return new Data(this);
	}

	public xbean.varSet toBean() {
		return new varSet(this); // same as copy()
	}

	@Override
	public xbean.varSet toDataIf() {
		return new Data(this);
	}

	public xbean.varSet toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Set<Integer> getV() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "v"), v);
	}

	public java.util.Set<Integer> getVAsData() { // 
		java.util.Set<Integer> v;
		varSet _o_ = this;
		v = new mkdb.util.SetX<Integer>();
		v.addAll(_o_.v);
		return v;
	}

	@Override
	public final boolean equals(Object _o1_) {
		varSet _o_ = null;
		if ( _o1_ instanceof varSet ) _o_ = (varSet)_o1_;
		else if ( _o1_ instanceof varSet.Const ) _o_ = ((varSet.Const)_o1_).nThis();
		else return false;
		if (!v.equals(_o_.v)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += v.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(v);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableSet().setVarName("v"));
		return lb;
	}

	private class Const implements xbean.varSet {
		varSet nThis() {
			return varSet.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.varSet copy() {
			return varSet.this.copy();
		}

		@Override
		public xbean.varSet toData() {
			return varSet.this.toData();
		}

		public xbean.varSet toBean() {
			return varSet.this.toBean();
		}

		@Override
		public xbean.varSet toDataIf() {
			return varSet.this.toDataIf();
		}

		public xbean.varSet toBeanIf() {
			return varSet.this.toBeanIf();
		}

		@Override
		public java.util.Set<Integer> getV() { // 
			return mkdb.Consts.constSet(v);
		}

		public java.util.Set<Integer> getVAsData() { // 
			java.util.Set<Integer> v;
			varSet _o_ = varSet.this;
		v = new mkdb.util.SetX<Integer>();
		v.addAll(_o_.v);
			return v;
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
			return varSet.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return varSet.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return varSet.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return varSet.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return varSet.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return varSet.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return varSet.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return varSet.this.hashCode();
		}

		@Override
		public String toString() {
			return varSet.this.toString();
		}

	}

	public static final class Data implements xbean.varSet {
		private java.util.HashSet<Integer> v; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			v = new java.util.HashSet<Integer>();
		}

		Data(xbean.varSet _o1_) {
			if (_o1_ instanceof varSet) assign((varSet)_o1_);
			else if (_o1_ instanceof varSet.Data) assign((varSet.Data)_o1_);
			else if (_o1_ instanceof varSet.Const) assign(((varSet.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(varSet _o_) {
			v = new java.util.HashSet<Integer>();
			v.addAll(_o_.v);
		}

		private void assign(varSet.Data _o_) {
			v = new java.util.HashSet<Integer>();
			v.addAll(_o_.v);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(v.size());
			for (Integer _v_ : v) {
				_os_.marshal(_v_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				v.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.varSet copy() {
			return new Data(this);
		}

		@Override
		public xbean.varSet toData() {
			return new Data(this);
		}

		public xbean.varSet toBean() {
			return new varSet(this, null, null);
		}

		@Override
		public xbean.varSet toDataIf() {
			return this;
		}

		public xbean.varSet toBeanIf() {
			return new varSet(this, null, null);
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
		public java.util.Set<Integer> getV() { // 
			return v;
		}

		@Override
		public java.util.Set<Integer> getVAsData() { // 
			return v;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof varSet.Data)) return false;
			varSet.Data _o_ = (varSet.Data) _o1_;
			if (!v.equals(_o_.v)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += v.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(v);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
