
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class SubBean extends mkdb.XBean implements xbean.SubBean {
	private int id; // int value

	@Override
	public void _reset_unsafe_() {
		id = 0;
	}

	SubBean(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public SubBean() {
		this(0, null, null);
	}

	public SubBean(SubBean _o_) {
		this(_o_, null, null);
	}

	SubBean(xbean.SubBean _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof SubBean) assign((SubBean)_o1_);
		else if (_o1_ instanceof SubBean.Data) assign((SubBean.Data)_o1_);
		else if (_o1_ instanceof SubBean.Const) assign(((SubBean.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(SubBean _o_) {
		id = _o_.id;
	}

	private void assign(SubBean.Data _o_) {
		id = _o_.id;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.SubBean copy() {
		return new SubBean(this);
	}

	@Override
	public xbean.SubBean toData() {
		return new Data(this);
	}

	public xbean.SubBean toBean() {
		return new SubBean(this); // same as copy()
	}

	@Override
	public xbean.SubBean toDataIf() {
		return new Data(this);
	}

	public xbean.SubBean toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // int value
		return id;
	}

	@Override
	public void setId(int _v_) { // int value
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		SubBean _o_ = null;
		if ( _o1_ instanceof SubBean ) _o_ = (SubBean)_o1_;
		else if ( _o1_ instanceof SubBean.Const ) _o_ = ((SubBean.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		return lb;
	}

	private class Const implements xbean.SubBean {
		SubBean nThis() {
			return SubBean.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.SubBean copy() {
			return SubBean.this.copy();
		}

		@Override
		public xbean.SubBean toData() {
			return SubBean.this.toData();
		}

		public xbean.SubBean toBean() {
			return SubBean.this.toBean();
		}

		@Override
		public xbean.SubBean toDataIf() {
			return SubBean.this.toDataIf();
		}

		public xbean.SubBean toBeanIf() {
			return SubBean.this.toBeanIf();
		}

		@Override
		public int getId() { // int value
			return id;
		}

		@Override
		public void setId(int _v_) { // int value
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
			return SubBean.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return SubBean.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return SubBean.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return SubBean.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return SubBean.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return SubBean.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return SubBean.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return SubBean.this.hashCode();
		}

		@Override
		public String toString() {
			return SubBean.this.toString();
		}

	}

	public static final class Data implements xbean.SubBean {
		private int id; // int value

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.SubBean _o1_) {
			if (_o1_ instanceof SubBean) assign((SubBean)_o1_);
			else if (_o1_ instanceof SubBean.Data) assign((SubBean.Data)_o1_);
			else if (_o1_ instanceof SubBean.Const) assign(((SubBean.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(SubBean _o_) {
			id = _o_.id;
		}

		private void assign(SubBean.Data _o_) {
			id = _o_.id;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.SubBean copy() {
			return new Data(this);
		}

		@Override
		public xbean.SubBean toData() {
			return new Data(this);
		}

		public xbean.SubBean toBean() {
			return new SubBean(this, null, null);
		}

		@Override
		public xbean.SubBean toDataIf() {
			return this;
		}

		public xbean.SubBean toBeanIf() {
			return new SubBean(this, null, null);
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
		public int getId() { // int value
			return id;
		}

		@Override
		public void setId(int _v_) { // int value
			id = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof SubBean.Data)) return false;
			SubBean.Data _o_ = (SubBean.Data) _o1_;
			if (id != _o_.id) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
