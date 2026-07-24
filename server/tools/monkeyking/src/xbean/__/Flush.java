
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Flush extends mkdb.XBean implements xbean.Flush {
	private long countlong; // 
	private float busy; // 
	private xbean.Family dummy; // 

	@Override
	public void _reset_unsafe_() {
		countlong = 0L;
		busy = 0.0f;
		dummy._reset_unsafe_();
	}

	Flush(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		dummy = new Family(0, this, "dummy");
	}

	public Flush() {
		this(0, null, null);
	}

	public Flush(Flush _o_) {
		this(_o_, null, null);
	}

	Flush(xbean.Flush _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Flush) assign((Flush)_o1_);
		else if (_o1_ instanceof Flush.Data) assign((Flush.Data)_o1_);
		else if (_o1_ instanceof Flush.Const) assign(((Flush.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Flush _o_) {
		countlong = _o_.countlong;
		busy = _o_.busy;
		dummy = new Family(_o_.dummy, this, "dummy");
	}

	private void assign(Flush.Data _o_) {
		countlong = _o_.countlong;
		busy = _o_.busy;
		dummy = new Family(_o_.dummy, this, "dummy");
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(countlong);
		_os_.marshal(busy);
		dummy.marshal(_os_);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		countlong = _os_.unmarshal_long();
		busy = _os_.unmarshal_float();
		dummy.unmarshal(_os_);
		return _os_;
	}

	@Override
	public xbean.Flush copy() {
		return new Flush(this);
	}

	@Override
	public xbean.Flush toData() {
		return new Data(this);
	}

	public xbean.Flush toBean() {
		return new Flush(this); // same as copy()
	}

	@Override
	public xbean.Flush toDataIf() {
		return new Data(this);
	}

	public xbean.Flush toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public long getCountlong() { // 
		return countlong;
	}

	@Override
	public float getBusy() { // 
		return busy;
	}

	@Override
	public xbean.Family getDummy() { // 
		return dummy;
	}

	@Override
	public void setCountlong(long _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "countlong") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, countlong) {
					public void rollback() { countlong = _xdb_saved; }
				};}});
		countlong = _v_;
	}

	@Override
	public void setBusy(float _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "busy") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogFloat(this, busy) {
					public void rollback() { busy = _xdb_saved; }
				};}});
		busy = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		Flush _o_ = null;
		if ( _o1_ instanceof Flush ) _o_ = (Flush)_o1_;
		else if ( _o1_ instanceof Flush.Const ) _o_ = ((Flush.Const)_o1_).nThis();
		else return false;
		if (countlong != _o_.countlong) return false;
		if (busy != _o_.busy) return false;
		if (!dummy.equals(_o_.dummy)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += countlong;
		_h_ += busy;
		_h_ += dummy.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(countlong);
		_sb_.append(",");
		_sb_.append(busy);
		_sb_.append(",");
		_sb_.append(dummy);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("countlong"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("busy"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("dummy"));
		return lb;
	}

	private class Const implements xbean.Flush {
		Flush nThis() {
			return Flush.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Flush copy() {
			return Flush.this.copy();
		}

		@Override
		public xbean.Flush toData() {
			return Flush.this.toData();
		}

		public xbean.Flush toBean() {
			return Flush.this.toBean();
		}

		@Override
		public xbean.Flush toDataIf() {
			return Flush.this.toDataIf();
		}

		public xbean.Flush toBeanIf() {
			return Flush.this.toBeanIf();
		}

		@Override
		public long getCountlong() { // 
			return countlong;
		}

		@Override
		public float getBusy() { // 
			return busy;
		}

		@Override
		public xbean.Family getDummy() { // 
			return mkdb.Consts.toConst(dummy);
		}

		@Override
		public void setCountlong(long _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setBusy(float _v_) { // 
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
			return Flush.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Flush.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Flush.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Flush.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Flush.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Flush.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Flush.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Flush.this.hashCode();
		}

		@Override
		public String toString() {
			return Flush.this.toString();
		}

	}

	public static final class Data implements xbean.Flush {
		private long countlong; // 
		private float busy; // 
		private xbean.Family dummy; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			dummy = new Family.Data();
		}

		Data(xbean.Flush _o1_) {
			if (_o1_ instanceof Flush) assign((Flush)_o1_);
			else if (_o1_ instanceof Flush.Data) assign((Flush.Data)_o1_);
			else if (_o1_ instanceof Flush.Const) assign(((Flush.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Flush _o_) {
			countlong = _o_.countlong;
			busy = _o_.busy;
			dummy = new Family.Data(_o_.dummy);
		}

		private void assign(Flush.Data _o_) {
			countlong = _o_.countlong;
			busy = _o_.busy;
			dummy = new Family.Data(_o_.dummy);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(countlong);
			_os_.marshal(busy);
			dummy.marshal(_os_);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			countlong = _os_.unmarshal_long();
			busy = _os_.unmarshal_float();
			dummy.unmarshal(_os_);
			return _os_;
		}

		@Override
		public xbean.Flush copy() {
			return new Data(this);
		}

		@Override
		public xbean.Flush toData() {
			return new Data(this);
		}

		public xbean.Flush toBean() {
			return new Flush(this, null, null);
		}

		@Override
		public xbean.Flush toDataIf() {
			return this;
		}

		public xbean.Flush toBeanIf() {
			return new Flush(this, null, null);
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
		public long getCountlong() { // 
			return countlong;
		}

		@Override
		public float getBusy() { // 
			return busy;
		}

		@Override
		public xbean.Family getDummy() { // 
			return dummy;
		}

		@Override
		public void setCountlong(long _v_) { // 
			countlong = _v_;
		}

		@Override
		public void setBusy(float _v_) { // 
			busy = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Flush.Data)) return false;
			Flush.Data _o_ = (Flush.Data) _o1_;
			if (countlong != _o_.countlong) return false;
			if (busy != _o_.busy) return false;
			if (!dummy.equals(_o_.dummy)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += countlong;
			_h_ += busy;
			_h_ += dummy.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(countlong);
			_sb_.append(",");
			_sb_.append(busy);
			_sb_.append(",");
			_sb_.append(dummy);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
