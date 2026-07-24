
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Set2 extends mkdb.XBean implements xbean.Set2 {
	private mkdb.util.SetX<xbean.First> sf; // comment

	@Override
	public void _reset_unsafe_() {
		sf.clear();
	}

	Set2(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		sf = new mkdb.util.SetX<xbean.First>();
	}

	public Set2() {
		this(0, null, null);
	}

	public Set2(Set2 _o_) {
		this(_o_, null, null);
	}

	Set2(xbean.Set2 _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Set2) assign((Set2)_o1_);
		else if (_o1_ instanceof Set2.Data) assign((Set2.Data)_o1_);
		else if (_o1_ instanceof Set2.Const) assign(((Set2.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Set2 _o_) {
		sf = new mkdb.util.SetX<xbean.First>();
		for (xbean.First _v_ : _o_.sf)
			sf.add(new First(_v_, this, "sf"));
	}

	private void assign(Set2.Data _o_) {
		sf = new mkdb.util.SetX<xbean.First>();
		for (xbean.First _v_ : _o_.sf)
			sf.add(new First(_v_, this, "sf"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(sf.size());
		for (xbean.First _v_ : sf) {
			_v_.marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.First _v_ = new First(0, this, "sf");
			_v_.unmarshal(_os_);
			sf.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.Set2 copy() {
		return new Set2(this);
	}

	@Override
	public xbean.Set2 toData() {
		return new Data(this);
	}

	public xbean.Set2 toBean() {
		return new Set2(this); // same as copy()
	}

	@Override
	public xbean.Set2 toDataIf() {
		return new Data(this);
	}

	public xbean.Set2 toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Set<xbean.First> getSf() { // comment
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "sf"), sf);
	}

	public java.util.Set<xbean.First> getSfAsData() { // comment
		java.util.Set<xbean.First> sf;
		Set2 _o_ = this;
		sf = new mkdb.util.SetX<xbean.First>();
		for (xbean.First _v_ : _o_.sf)
			sf.add(new First.Data(_v_));
		return sf;
	}

	@Override
	public final boolean equals(Object _o1_) {
		Set2 _o_ = null;
		if ( _o1_ instanceof Set2 ) _o_ = (Set2)_o1_;
		else if ( _o1_ instanceof Set2.Const ) _o_ = ((Set2.Const)_o1_).nThis();
		else return false;
		if (!sf.equals(_o_.sf)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += sf.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(sf);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableSet().setVarName("sf"));
		return lb;
	}

	private class Const implements xbean.Set2 {
		Set2 nThis() {
			return Set2.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Set2 copy() {
			return Set2.this.copy();
		}

		@Override
		public xbean.Set2 toData() {
			return Set2.this.toData();
		}

		public xbean.Set2 toBean() {
			return Set2.this.toBean();
		}

		@Override
		public xbean.Set2 toDataIf() {
			return Set2.this.toDataIf();
		}

		public xbean.Set2 toBeanIf() {
			return Set2.this.toBeanIf();
		}

		@Override
		public java.util.Set<xbean.First> getSf() { // comment
			return mkdb.Consts.constSet(sf);
		}

		public java.util.Set<xbean.First> getSfAsData() { // comment
			java.util.Set<xbean.First> sf;
			Set2 _o_ = Set2.this;
		sf = new mkdb.util.SetX<xbean.First>();
		for (xbean.First _v_ : _o_.sf)
			sf.add(new First.Data(_v_));
			return sf;
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
			return Set2.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Set2.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Set2.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Set2.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Set2.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Set2.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Set2.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Set2.this.hashCode();
		}

		@Override
		public String toString() {
			return Set2.this.toString();
		}

	}

	public static final class Data implements xbean.Set2 {
		private java.util.HashSet<xbean.First> sf; // comment

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			sf = new java.util.HashSet<xbean.First>();
		}

		Data(xbean.Set2 _o1_) {
			if (_o1_ instanceof Set2) assign((Set2)_o1_);
			else if (_o1_ instanceof Set2.Data) assign((Set2.Data)_o1_);
			else if (_o1_ instanceof Set2.Const) assign(((Set2.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Set2 _o_) {
			sf = new java.util.HashSet<xbean.First>();
			for (xbean.First _v_ : _o_.sf)
				sf.add(new First.Data(_v_));
		}

		private void assign(Set2.Data _o_) {
			sf = new java.util.HashSet<xbean.First>();
			for (xbean.First _v_ : _o_.sf)
				sf.add(new First.Data(_v_));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(sf.size());
			for (xbean.First _v_ : sf) {
				_v_.marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.First _v_ = xbean.Pod.newFirstData();
				_v_.unmarshal(_os_);
				sf.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.Set2 copy() {
			return new Data(this);
		}

		@Override
		public xbean.Set2 toData() {
			return new Data(this);
		}

		public xbean.Set2 toBean() {
			return new Set2(this, null, null);
		}

		@Override
		public xbean.Set2 toDataIf() {
			return this;
		}

		public xbean.Set2 toBeanIf() {
			return new Set2(this, null, null);
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
		public java.util.Set<xbean.First> getSf() { // comment
			return sf;
		}

		@Override
		public java.util.Set<xbean.First> getSfAsData() { // comment
			return sf;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Set2.Data)) return false;
			Set2.Data _o_ = (Set2.Data) _o1_;
			if (!sf.equals(_o_.sf)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += sf.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(sf);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
