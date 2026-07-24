
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class SecondaryIndex extends mkdb.XBean implements xbean.SecondaryIndex {
	private int secondaryindex; // 

	@Override
	public void _reset_unsafe_() {
		secondaryindex = 0;
	}

	SecondaryIndex(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public SecondaryIndex() {
		this(0, null, null);
	}

	public SecondaryIndex(SecondaryIndex _o_) {
		this(_o_, null, null);
	}

	SecondaryIndex(xbean.SecondaryIndex _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof SecondaryIndex) assign((SecondaryIndex)_o1_);
		else if (_o1_ instanceof SecondaryIndex.Data) assign((SecondaryIndex.Data)_o1_);
		else if (_o1_ instanceof SecondaryIndex.Const) assign(((SecondaryIndex.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(SecondaryIndex _o_) {
		secondaryindex = _o_.secondaryindex;
	}

	private void assign(SecondaryIndex.Data _o_) {
		secondaryindex = _o_.secondaryindex;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(secondaryindex);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		secondaryindex = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.SecondaryIndex copy() {
		return new SecondaryIndex(this);
	}

	@Override
	public xbean.SecondaryIndex toData() {
		return new Data(this);
	}

	public xbean.SecondaryIndex toBean() {
		return new SecondaryIndex(this); // same as copy()
	}

	@Override
	public xbean.SecondaryIndex toDataIf() {
		return new Data(this);
	}

	public xbean.SecondaryIndex toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getSecondaryindex() { // 
		return secondaryindex;
	}

	@Override
	public void setSecondaryindex(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "secondaryindex") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, secondaryindex) {
					public void rollback() { secondaryindex = _xdb_saved; }
				};}});
		secondaryindex = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		SecondaryIndex _o_ = null;
		if ( _o1_ instanceof SecondaryIndex ) _o_ = (SecondaryIndex)_o1_;
		else if ( _o1_ instanceof SecondaryIndex.Const ) _o_ = ((SecondaryIndex.Const)_o1_).nThis();
		else return false;
		if (secondaryindex != _o_.secondaryindex) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += secondaryindex;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(secondaryindex);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("secondaryindex"));
		return lb;
	}

	private class Const implements xbean.SecondaryIndex {
		SecondaryIndex nThis() {
			return SecondaryIndex.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.SecondaryIndex copy() {
			return SecondaryIndex.this.copy();
		}

		@Override
		public xbean.SecondaryIndex toData() {
			return SecondaryIndex.this.toData();
		}

		public xbean.SecondaryIndex toBean() {
			return SecondaryIndex.this.toBean();
		}

		@Override
		public xbean.SecondaryIndex toDataIf() {
			return SecondaryIndex.this.toDataIf();
		}

		public xbean.SecondaryIndex toBeanIf() {
			return SecondaryIndex.this.toBeanIf();
		}

		@Override
		public int getSecondaryindex() { // 
			return secondaryindex;
		}

		@Override
		public void setSecondaryindex(int _v_) { // 
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
			return SecondaryIndex.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return SecondaryIndex.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return SecondaryIndex.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return SecondaryIndex.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return SecondaryIndex.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return SecondaryIndex.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return SecondaryIndex.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return SecondaryIndex.this.hashCode();
		}

		@Override
		public String toString() {
			return SecondaryIndex.this.toString();
		}

	}

	public static final class Data implements xbean.SecondaryIndex {
		private int secondaryindex; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.SecondaryIndex _o1_) {
			if (_o1_ instanceof SecondaryIndex) assign((SecondaryIndex)_o1_);
			else if (_o1_ instanceof SecondaryIndex.Data) assign((SecondaryIndex.Data)_o1_);
			else if (_o1_ instanceof SecondaryIndex.Const) assign(((SecondaryIndex.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(SecondaryIndex _o_) {
			secondaryindex = _o_.secondaryindex;
		}

		private void assign(SecondaryIndex.Data _o_) {
			secondaryindex = _o_.secondaryindex;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(secondaryindex);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			secondaryindex = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.SecondaryIndex copy() {
			return new Data(this);
		}

		@Override
		public xbean.SecondaryIndex toData() {
			return new Data(this);
		}

		public xbean.SecondaryIndex toBean() {
			return new SecondaryIndex(this, null, null);
		}

		@Override
		public xbean.SecondaryIndex toDataIf() {
			return this;
		}

		public xbean.SecondaryIndex toBeanIf() {
			return new SecondaryIndex(this, null, null);
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
		public int getSecondaryindex() { // 
			return secondaryindex;
		}

		@Override
		public void setSecondaryindex(int _v_) { // 
			secondaryindex = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof SecondaryIndex.Data)) return false;
			SecondaryIndex.Data _o_ = (SecondaryIndex.Data) _o1_;
			if (secondaryindex != _o_.secondaryindex) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += secondaryindex;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(secondaryindex);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
