
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class depends1 extends mkdb.XBean implements xbean.depends1 {
	private int dummyavoidwarning; // 

	@Override
	public void _reset_unsafe_() {
		dummyavoidwarning = 0;
	}

	depends1(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public depends1() {
		this(0, null, null);
	}

	public depends1(depends1 _o_) {
		this(_o_, null, null);
	}

	depends1(xbean.depends1 _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof depends1) assign((depends1)_o1_);
		else if (_o1_ instanceof depends1.Data) assign((depends1.Data)_o1_);
		else if (_o1_ instanceof depends1.Const) assign(((depends1.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(depends1 _o_) {
		dummyavoidwarning = _o_.dummyavoidwarning;
	}

	private void assign(depends1.Data _o_) {
		dummyavoidwarning = _o_.dummyavoidwarning;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(dummyavoidwarning);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		dummyavoidwarning = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.depends1 copy() {
		return new depends1(this);
	}

	@Override
	public xbean.depends1 toData() {
		return new Data(this);
	}

	public xbean.depends1 toBean() {
		return new depends1(this); // same as copy()
	}

	@Override
	public xbean.depends1 toDataIf() {
		return new Data(this);
	}

	public xbean.depends1 toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getDummyavoidwarning() { // 
		return dummyavoidwarning;
	}

	@Override
	public void setDummyavoidwarning(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "dummyavoidwarning") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, dummyavoidwarning) {
					public void rollback() { dummyavoidwarning = _xdb_saved; }
				};}});
		dummyavoidwarning = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		depends1 _o_ = null;
		if ( _o1_ instanceof depends1 ) _o_ = (depends1)_o1_;
		else if ( _o1_ instanceof depends1.Const ) _o_ = ((depends1.Const)_o1_).nThis();
		else return false;
		if (dummyavoidwarning != _o_.dummyavoidwarning) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += dummyavoidwarning;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(dummyavoidwarning);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("dummyavoidwarning"));
		return lb;
	}

	private class Const implements xbean.depends1 {
		depends1 nThis() {
			return depends1.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.depends1 copy() {
			return depends1.this.copy();
		}

		@Override
		public xbean.depends1 toData() {
			return depends1.this.toData();
		}

		public xbean.depends1 toBean() {
			return depends1.this.toBean();
		}

		@Override
		public xbean.depends1 toDataIf() {
			return depends1.this.toDataIf();
		}

		public xbean.depends1 toBeanIf() {
			return depends1.this.toBeanIf();
		}

		@Override
		public int getDummyavoidwarning() { // 
			return dummyavoidwarning;
		}

		@Override
		public void setDummyavoidwarning(int _v_) { // 
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
			return depends1.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return depends1.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return depends1.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return depends1.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return depends1.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return depends1.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return depends1.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return depends1.this.hashCode();
		}

		@Override
		public String toString() {
			return depends1.this.toString();
		}

	}

	public static final class Data implements xbean.depends1 {
		private int dummyavoidwarning; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.depends1 _o1_) {
			if (_o1_ instanceof depends1) assign((depends1)_o1_);
			else if (_o1_ instanceof depends1.Data) assign((depends1.Data)_o1_);
			else if (_o1_ instanceof depends1.Const) assign(((depends1.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(depends1 _o_) {
			dummyavoidwarning = _o_.dummyavoidwarning;
		}

		private void assign(depends1.Data _o_) {
			dummyavoidwarning = _o_.dummyavoidwarning;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(dummyavoidwarning);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			dummyavoidwarning = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.depends1 copy() {
			return new Data(this);
		}

		@Override
		public xbean.depends1 toData() {
			return new Data(this);
		}

		public xbean.depends1 toBean() {
			return new depends1(this, null, null);
		}

		@Override
		public xbean.depends1 toDataIf() {
			return this;
		}

		public xbean.depends1 toBeanIf() {
			return new depends1(this, null, null);
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
		public int getDummyavoidwarning() { // 
			return dummyavoidwarning;
		}

		@Override
		public void setDummyavoidwarning(int _v_) { // 
			dummyavoidwarning = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof depends1.Data)) return false;
			depends1.Data _o_ = (depends1.Data) _o1_;
			if (dummyavoidwarning != _o_.dummyavoidwarning) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += dummyavoidwarning;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(dummyavoidwarning);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
