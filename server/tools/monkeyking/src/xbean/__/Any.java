
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Any extends mkdb.XBean implements xbean.Any {
	private Object any; // comment
	private mkdb.util.SetX<Object> anyset; // comment
	private boolean bool; // boolean

	@Override
	public void _reset_unsafe_() {
		any = null;
		anyset.clear();
		bool = false;
	}

	Any(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		any = null;
		anyset = new mkdb.util.SetX<Object>();
		bool = false;
	}

	public Any() {
		this(0, null, null);
	}

	public Any(Any _o_) {
		this(_o_, null, null);
	}

	Any(xbean.Any _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		throw new UnsupportedOperationException();
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		throw new UnsupportedOperationException();
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		throw new UnsupportedOperationException();
	}

	@Override
	public xbean.Any copy() {
		return new Any(this);
	}

	@Override
	public xbean.Any toData() {
		return new Data(this);
	}

	public xbean.Any toBean() {
		return new Any(this); // same as copy()
	}

	@Override
	public xbean.Any toDataIf() {
		return new Data(this);
	}

	public xbean.Any toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public Object getAny() { // comment
		return any;
	}

	@Override
	public java.util.Set<Object> getAnyset() { // comment
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "anyset"), anyset);
	}

	@Override
	public boolean getBool() { // boolean
		return bool;
	}

	@Override
	public void setAny(Object _v_) { // comment
		mkdb.Logs.logIf(new mkdb.LogKey(this, "any") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<Object>(this, any) {
					public void rollback() { any = _xdb_saved; }
			}; }});
		any = _v_;
	}

	@Override
	public void setBool(boolean _v_) { // boolean
		mkdb.Logs.logIf(new mkdb.LogKey(this, "bool") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<Boolean>(this, bool) {
					public void rollback() { bool = _xdb_saved; }
				};}});
		bool = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		Any _o_ = null;
		if ( _o1_ instanceof Any ) _o_ = (Any)_o1_;
		else if ( _o1_ instanceof Any.Const ) _o_ = ((Any.Const)_o1_).nThis();
		else return false;
		if ((null == any && null != _o_.any) || (null != any && null == _o_.any) || (null != any && null != _o_.any && !any.equals(_o_.any))) return false;
		if (!anyset.equals(_o_.anyset)) return false;
		if (bool != _o_.bool) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += (any == null ? 0 : any.hashCode());
		_h_ += anyset.hashCode();
		_h_ += bool ? 1231 : 1237;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(any);
		_sb_.append(",");
		_sb_.append(anyset);
		_sb_.append(",");
		_sb_.append(bool);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("any"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("anyset"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("bool"));
		return lb;
	}

	private class Const implements xbean.Any {
		Any nThis() {
			return Any.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Any copy() {
			return Any.this.copy();
		}

		@Override
		public xbean.Any toData() {
			return Any.this.toData();
		}

		public xbean.Any toBean() {
			return Any.this.toBean();
		}

		@Override
		public xbean.Any toDataIf() {
			return Any.this.toDataIf();
		}

		public xbean.Any toBeanIf() {
			return Any.this.toBeanIf();
		}

		@Override
		public Object getAny() { // comment
			return any;
		}

		@Override
		public java.util.Set<Object> getAnyset() { // comment
			return mkdb.Consts.constSet(anyset);
		}

		@Override
		public boolean getBool() { // boolean
			return bool;
		}

		@Override
		public void setAny(Object _v_) { // comment
			throw new UnsupportedOperationException();
		}

		@Override
		public void setBool(boolean _v_) { // boolean
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
			return Any.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Any.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Any.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Any.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Any.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Any.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Any.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Any.this.hashCode();
		}

		@Override
		public String toString() {
			return Any.this.toString();
		}

	}

	public static final class Data implements xbean.Any {
		private Object any; // comment
		private java.util.HashSet<Object> anyset; // comment
		private boolean bool; // boolean

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			any = null;
			anyset = new java.util.HashSet<Object>();
			bool = false;
		}

		Data(xbean.Any _o1_) {
			throw new UnsupportedOperationException();
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			throw new UnsupportedOperationException();
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Any copy() {
			return new Data(this);
		}

		@Override
		public xbean.Any toData() {
			return new Data(this);
		}

		public xbean.Any toBean() {
			return new Any(this, null, null);
		}

		@Override
		public xbean.Any toDataIf() {
			return this;
		}

		public xbean.Any toBeanIf() {
			return new Any(this, null, null);
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
		public Object getAny() { // comment
			return any;
		}

		@Override
		public java.util.Set<Object> getAnyset() { // comment
			return anyset;
		}

		@Override
		public boolean getBool() { // boolean
			return bool;
		}

		@Override
		public void setAny(Object _v_) { // comment
			any = _v_;
		}

		@Override
		public void setBool(boolean _v_) { // boolean
			bool = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Any.Data)) return false;
			Any.Data _o_ = (Any.Data) _o1_;
			if ((null == any && null != _o_.any) || (null != any && null == _o_.any) || (null != any && null != _o_.any && !any.equals(_o_.any))) return false;
			if (!anyset.equals(_o_.anyset)) return false;
			if (bool != _o_.bool) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += (any == null ? 0 : any.hashCode());
			_h_ += anyset.hashCode();
			_h_ += bool ? 1231 : 1237;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(any);
			_sb_.append(",");
			_sb_.append(anyset);
			_sb_.append(",");
			_sb_.append(bool);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
