
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Any2 extends mkdb.XBean implements xbean.Any2 {
	private xbean.Any any; // comment
	private mkdb.util.SetX<xbean.Any> anyset; // comment

	@Override
	public void _reset_unsafe_() {
		any._reset_unsafe_();
		anyset.clear();
	}

	Any2(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		any = new Any(0, this, "any");
		anyset = new mkdb.util.SetX<xbean.Any>();
	}

	public Any2() {
		this(0, null, null);
	}

	public Any2(Any2 _o_) {
		this(_o_, null, null);
	}

	Any2(xbean.Any2 _o1_, mkdb.XBean _xp_, String _vn_) {
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
	public xbean.Any2 copy() {
		return new Any2(this);
	}

	@Override
	public xbean.Any2 toData() {
		return new Data(this);
	}

	public xbean.Any2 toBean() {
		return new Any2(this); // same as copy()
	}

	@Override
	public xbean.Any2 toDataIf() {
		return new Data(this);
	}

	public xbean.Any2 toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public xbean.Any getAny() { // comment
		return any;
	}

	@Override
	public java.util.Set<xbean.Any> getAnyset() { // comment
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "anyset"), anyset);
	}

	@Override
	public final boolean equals(Object _o1_) {
		Any2 _o_ = null;
		if ( _o1_ instanceof Any2 ) _o_ = (Any2)_o1_;
		else if ( _o1_ instanceof Any2.Const ) _o_ = ((Any2.Const)_o1_).nThis();
		else return false;
		if (!any.equals(_o_.any)) return false;
		if (!anyset.equals(_o_.anyset)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += any.hashCode();
		_h_ += anyset.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(any);
		_sb_.append(",");
		_sb_.append(anyset);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("any"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("anyset"));
		return lb;
	}

	private class Const implements xbean.Any2 {
		Any2 nThis() {
			return Any2.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Any2 copy() {
			return Any2.this.copy();
		}

		@Override
		public xbean.Any2 toData() {
			return Any2.this.toData();
		}

		public xbean.Any2 toBean() {
			return Any2.this.toBean();
		}

		@Override
		public xbean.Any2 toDataIf() {
			return Any2.this.toDataIf();
		}

		public xbean.Any2 toBeanIf() {
			return Any2.this.toBeanIf();
		}

		@Override
		public xbean.Any getAny() { // comment
			return mkdb.Consts.toConst(any);
		}

		@Override
		public java.util.Set<xbean.Any> getAnyset() { // comment
			return mkdb.Consts.constSet(anyset);
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
			return Any2.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Any2.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Any2.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Any2.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Any2.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Any2.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Any2.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Any2.this.hashCode();
		}

		@Override
		public String toString() {
			return Any2.this.toString();
		}

	}

	public static final class Data implements xbean.Any2 {
		private xbean.Any any; // comment
		private java.util.HashSet<xbean.Any> anyset; // comment

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			any = new Any.Data();
			anyset = new java.util.HashSet<xbean.Any>();
		}

		Data(xbean.Any2 _o1_) {
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
		public xbean.Any2 copy() {
			return new Data(this);
		}

		@Override
		public xbean.Any2 toData() {
			return new Data(this);
		}

		public xbean.Any2 toBean() {
			return new Any2(this, null, null);
		}

		@Override
		public xbean.Any2 toDataIf() {
			return this;
		}

		public xbean.Any2 toBeanIf() {
			return new Any2(this, null, null);
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
		public xbean.Any getAny() { // comment
			return any;
		}

		@Override
		public java.util.Set<xbean.Any> getAnyset() { // comment
			return anyset;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Any2.Data)) return false;
			Any2.Data _o_ = (Any2.Data) _o1_;
			if (!any.equals(_o_.any)) return false;
			if (!anyset.equals(_o_.anyset)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += any.hashCode();
			_h_ += anyset.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(any);
			_sb_.append(",");
			_sb_.append(anyset);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
