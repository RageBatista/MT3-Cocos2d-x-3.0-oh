
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class AnyFake extends mkdb.XBean implements xbean.AnyFake {
	private int fake; // comment

	@Override
	public void _reset_unsafe_() {
		fake = 0;
	}

	AnyFake(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public AnyFake() {
		this(0, null, null);
	}

	public AnyFake(AnyFake _o_) {
		this(_o_, null, null);
	}

	AnyFake(xbean.AnyFake _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof AnyFake) assign((AnyFake)_o1_);
		else if (_o1_ instanceof AnyFake.Data) assign((AnyFake.Data)_o1_);
		else if (_o1_ instanceof AnyFake.Const) assign(((AnyFake.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(AnyFake _o_) {
		fake = _o_.fake;
	}

	private void assign(AnyFake.Data _o_) {
		fake = _o_.fake;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(fake);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		fake = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.AnyFake copy() {
		return new AnyFake(this);
	}

	@Override
	public xbean.AnyFake toData() {
		return new Data(this);
	}

	public xbean.AnyFake toBean() {
		return new AnyFake(this); // same as copy()
	}

	@Override
	public xbean.AnyFake toDataIf() {
		return new Data(this);
	}

	public xbean.AnyFake toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getFake() { // comment
		return fake;
	}

	@Override
	public void setFake(int _v_) { // comment
		mkdb.Logs.logIf(new mkdb.LogKey(this, "fake") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, fake) {
					public void rollback() { fake = _xdb_saved; }
				};}});
		fake = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		AnyFake _o_ = null;
		if ( _o1_ instanceof AnyFake ) _o_ = (AnyFake)_o1_;
		else if ( _o1_ instanceof AnyFake.Const ) _o_ = ((AnyFake.Const)_o1_).nThis();
		else return false;
		if (fake != _o_.fake) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += fake;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(fake);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("fake"));
		return lb;
	}

	private class Const implements xbean.AnyFake {
		AnyFake nThis() {
			return AnyFake.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.AnyFake copy() {
			return AnyFake.this.copy();
		}

		@Override
		public xbean.AnyFake toData() {
			return AnyFake.this.toData();
		}

		public xbean.AnyFake toBean() {
			return AnyFake.this.toBean();
		}

		@Override
		public xbean.AnyFake toDataIf() {
			return AnyFake.this.toDataIf();
		}

		public xbean.AnyFake toBeanIf() {
			return AnyFake.this.toBeanIf();
		}

		@Override
		public int getFake() { // comment
			return fake;
		}

		@Override
		public void setFake(int _v_) { // comment
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
			return AnyFake.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return AnyFake.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return AnyFake.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return AnyFake.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return AnyFake.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return AnyFake.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return AnyFake.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return AnyFake.this.hashCode();
		}

		@Override
		public String toString() {
			return AnyFake.this.toString();
		}

	}

	public static final class Data implements xbean.AnyFake {
		private int fake; // comment

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.AnyFake _o1_) {
			if (_o1_ instanceof AnyFake) assign((AnyFake)_o1_);
			else if (_o1_ instanceof AnyFake.Data) assign((AnyFake.Data)_o1_);
			else if (_o1_ instanceof AnyFake.Const) assign(((AnyFake.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(AnyFake _o_) {
			fake = _o_.fake;
		}

		private void assign(AnyFake.Data _o_) {
			fake = _o_.fake;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(fake);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			fake = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.AnyFake copy() {
			return new Data(this);
		}

		@Override
		public xbean.AnyFake toData() {
			return new Data(this);
		}

		public xbean.AnyFake toBean() {
			return new AnyFake(this, null, null);
		}

		@Override
		public xbean.AnyFake toDataIf() {
			return this;
		}

		public xbean.AnyFake toBeanIf() {
			return new AnyFake(this, null, null);
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
		public int getFake() { // comment
			return fake;
		}

		@Override
		public void setFake(int _v_) { // comment
			fake = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof AnyFake.Data)) return false;
			AnyFake.Data _o_ = (AnyFake.Data) _o1_;
			if (fake != _o_.fake) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += fake;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(fake);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
