
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class RB extends mkdb.XBean implements xbean.RB {
	private int i; // int test

	@Override
	public void _reset_unsafe_() {
		i = 1;
	}

	RB(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		i = 1;
	}

	public RB() {
		this(0, null, null);
	}

	public RB(RB _o_) {
		this(_o_, null, null);
	}

	RB(xbean.RB _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof RB) assign((RB)_o1_);
		else if (_o1_ instanceof RB.Data) assign((RB.Data)_o1_);
		else if (_o1_ instanceof RB.Const) assign(((RB.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(RB _o_) {
		i = _o_.i;
	}

	private void assign(RB.Data _o_) {
		i = _o_.i;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(i);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		i = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.RB copy() {
		return new RB(this);
	}

	@Override
	public xbean.RB toData() {
		return new Data(this);
	}

	public xbean.RB toBean() {
		return new RB(this); // same as copy()
	}

	@Override
	public xbean.RB toDataIf() {
		return new Data(this);
	}

	public xbean.RB toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getI() { // int test
		return i;
	}

	@Override
	public void setI(int _v_) { // int test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "i") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, i) {
					public void rollback() { i = _xdb_saved; }
				};}});
		i = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		RB _o_ = null;
		if ( _o1_ instanceof RB ) _o_ = (RB)_o1_;
		else if ( _o1_ instanceof RB.Const ) _o_ = ((RB.Const)_o1_).nThis();
		else return false;
		if (i != _o_.i) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += i;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(i);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("i"));
		return lb;
	}

	private class Const implements xbean.RB {
		RB nThis() {
			return RB.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.RB copy() {
			return RB.this.copy();
		}

		@Override
		public xbean.RB toData() {
			return RB.this.toData();
		}

		public xbean.RB toBean() {
			return RB.this.toBean();
		}

		@Override
		public xbean.RB toDataIf() {
			return RB.this.toDataIf();
		}

		public xbean.RB toBeanIf() {
			return RB.this.toBeanIf();
		}

		@Override
		public int getI() { // int test
			return i;
		}

		@Override
		public void setI(int _v_) { // int test
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
			return RB.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return RB.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return RB.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return RB.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return RB.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return RB.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return RB.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return RB.this.hashCode();
		}

		@Override
		public String toString() {
			return RB.this.toString();
		}

	}

	public static final class Data implements xbean.RB {
		private int i; // int test

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			i = 1;
		}

		Data(xbean.RB _o1_) {
			if (_o1_ instanceof RB) assign((RB)_o1_);
			else if (_o1_ instanceof RB.Data) assign((RB.Data)_o1_);
			else if (_o1_ instanceof RB.Const) assign(((RB.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(RB _o_) {
			i = _o_.i;
		}

		private void assign(RB.Data _o_) {
			i = _o_.i;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(i);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			i = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.RB copy() {
			return new Data(this);
		}

		@Override
		public xbean.RB toData() {
			return new Data(this);
		}

		public xbean.RB toBean() {
			return new RB(this, null, null);
		}

		@Override
		public xbean.RB toDataIf() {
			return this;
		}

		public xbean.RB toBeanIf() {
			return new RB(this, null, null);
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
		public int getI() { // int test
			return i;
		}

		@Override
		public void setI(int _v_) { // int test
			i = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof RB.Data)) return false;
			RB.Data _o_ = (RB.Data) _o1_;
			if (i != _o_.i) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += i;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(i);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
