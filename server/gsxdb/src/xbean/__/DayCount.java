
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class DayCount extends mkdb.XBean implements xbean.DayCount {
	private long time; // 使用时间
	private int count; // 使用次数

	@Override
	public void _reset_unsafe_() {
		time = 0L;
		count = 0;
	}

	DayCount(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public DayCount() {
		this(0, null, null);
	}

	public DayCount(DayCount _o_) {
		this(_o_, null, null);
	}

	DayCount(xbean.DayCount _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof DayCount) assign((DayCount)_o1_);
		else if (_o1_ instanceof DayCount.Data) assign((DayCount.Data)_o1_);
		else if (_o1_ instanceof DayCount.Const) assign(((DayCount.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(DayCount _o_) {
		_o_._xdb_verify_unsafe_();
		time = _o_.time;
		count = _o_.count;
	}

	private void assign(DayCount.Data _o_) {
		time = _o_.time;
		count = _o_.count;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(time);
		_os_.marshal(count);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		time = _os_.unmarshal_long();
		count = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.DayCount copy() {
		_xdb_verify_unsafe_();
		return new DayCount(this);
	}

	@Override
	public xbean.DayCount toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.DayCount toBean() {
		_xdb_verify_unsafe_();
		return new DayCount(this); // same as copy()
	}

	@Override
	public xbean.DayCount toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.DayCount toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public long getTime() { // 使用时间
		_xdb_verify_unsafe_();
		return time;
	}

	@Override
	public int getCount() { // 使用次数
		_xdb_verify_unsafe_();
		return count;
	}

	@Override
	public void setTime(long _v_) { // 使用时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "time") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, time) {
					public void rollback() { time = _xdb_saved; }
				};}});
		time = _v_;
	}

	@Override
	public void setCount(int _v_) { // 使用次数
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "count") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, count) {
					public void rollback() { count = _xdb_saved; }
				};}});
		count = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		DayCount _o_ = null;
		if ( _o1_ instanceof DayCount ) _o_ = (DayCount)_o1_;
		else if ( _o1_ instanceof DayCount.Const ) _o_ = ((DayCount.Const)_o1_).nThis();
		else return false;
		if (time != _o_.time) return false;
		if (count != _o_.count) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += time;
		_h_ += count;
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(time);
		_sb_.append(",");
		_sb_.append(count);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("time"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("count"));
		return lb;
	}

	private class Const implements xbean.DayCount {
		DayCount nThis() {
			return DayCount.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.DayCount copy() {
			return DayCount.this.copy();
		}

		@Override
		public xbean.DayCount toData() {
			return DayCount.this.toData();
		}

		public xbean.DayCount toBean() {
			return DayCount.this.toBean();
		}

		@Override
		public xbean.DayCount toDataIf() {
			return DayCount.this.toDataIf();
		}

		public xbean.DayCount toBeanIf() {
			return DayCount.this.toBeanIf();
		}

		@Override
		public long getTime() { // 使用时间
			_xdb_verify_unsafe_();
			return time;
		}

		@Override
		public int getCount() { // 使用次数
			_xdb_verify_unsafe_();
			return count;
		}

		@Override
		public void setTime(long _v_) { // 使用时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setCount(int _v_) { // 使用次数
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean toConst() {
			_xdb_verify_unsafe_();
			return this;
		}

		@Override
		public boolean isConst() {
			_xdb_verify_unsafe_();
			return true;
		}

		@Override
		public boolean isData() {
			return DayCount.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return DayCount.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return DayCount.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return DayCount.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return DayCount.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return DayCount.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return DayCount.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return DayCount.this.hashCode();
		}

		@Override
		public String toString() {
			return DayCount.this.toString();
		}

	}

	public static final class Data implements xbean.DayCount {
		private long time; // 使用时间
		private int count; // 使用次数

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.DayCount _o1_) {
			if (_o1_ instanceof DayCount) assign((DayCount)_o1_);
			else if (_o1_ instanceof DayCount.Data) assign((DayCount.Data)_o1_);
			else if (_o1_ instanceof DayCount.Const) assign(((DayCount.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(DayCount _o_) {
			time = _o_.time;
			count = _o_.count;
		}

		private void assign(DayCount.Data _o_) {
			time = _o_.time;
			count = _o_.count;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(time);
			_os_.marshal(count);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			time = _os_.unmarshal_long();
			count = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.DayCount copy() {
			return new Data(this);
		}

		@Override
		public xbean.DayCount toData() {
			return new Data(this);
		}

		public xbean.DayCount toBean() {
			return new DayCount(this, null, null);
		}

		@Override
		public xbean.DayCount toDataIf() {
			return this;
		}

		public xbean.DayCount toBeanIf() {
			return new DayCount(this, null, null);
		}

		// mkdb.Bean 接口，Data 不支持此操作
		public boolean xdbManaged() { throw new UnsupportedOperationException(); }
		public mkdb.Bean xdbParent() { throw new UnsupportedOperationException(); }
		public String xdbVarname()  { throw new UnsupportedOperationException(); }
		public Long    xdbObjId()   { throw new UnsupportedOperationException(); }
		public mkdb.Bean toConst()   { throw new UnsupportedOperationException(); }
		public boolean isConst()    { return false; }
		public boolean isData()     { return true; }

		@Override
		public long getTime() { // 使用时间
			return time;
		}

		@Override
		public int getCount() { // 使用次数
			return count;
		}

		@Override
		public void setTime(long _v_) { // 使用时间
			time = _v_;
		}

		@Override
		public void setCount(int _v_) { // 使用次数
			count = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof DayCount.Data)) return false;
			DayCount.Data _o_ = (DayCount.Data) _o1_;
			if (time != _o_.time) return false;
			if (count != _o_.count) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += time;
			_h_ += count;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(time);
			_sb_.append(",");
			_sb_.append(count);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
