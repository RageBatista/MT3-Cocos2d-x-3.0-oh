
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class DayCounter extends mkdb.XBean implements xbean.DayCounter {
	private java.util.HashMap<Integer, xbean.DayCount> countermap; // 使用表

	@Override
	public void _reset_unsafe_() {
		countermap.clear();
	}

	DayCounter(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		countermap = new java.util.HashMap<Integer, xbean.DayCount>();
	}

	public DayCounter() {
		this(0, null, null);
	}

	public DayCounter(DayCounter _o_) {
		this(_o_, null, null);
	}

	DayCounter(xbean.DayCounter _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof DayCounter) assign((DayCounter)_o1_);
		else if (_o1_ instanceof DayCounter.Data) assign((DayCounter.Data)_o1_);
		else if (_o1_ instanceof DayCounter.Const) assign(((DayCounter.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(DayCounter _o_) {
		_o_._xdb_verify_unsafe_();
		countermap = new java.util.HashMap<Integer, xbean.DayCount>();
		for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : _o_.countermap.entrySet())
			countermap.put(_e_.getKey(), new DayCount(_e_.getValue(), this, "countermap"));
	}

	private void assign(DayCounter.Data _o_) {
		countermap = new java.util.HashMap<Integer, xbean.DayCount>();
		for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : _o_.countermap.entrySet())
			countermap.put(_e_.getKey(), new DayCount(_e_.getValue(), this, "countermap"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.compact_uint32(countermap.size());
		for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : countermap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				countermap = new java.util.HashMap<Integer, xbean.DayCount>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.DayCount _v_ = new DayCount(0, this, "countermap");
				_v_.unmarshal(_os_);
				countermap.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.DayCounter copy() {
		_xdb_verify_unsafe_();
		return new DayCounter(this);
	}

	@Override
	public xbean.DayCounter toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.DayCounter toBean() {
		_xdb_verify_unsafe_();
		return new DayCounter(this); // same as copy()
	}

	@Override
	public xbean.DayCounter toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.DayCounter toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public java.util.Map<Integer, xbean.DayCount> getCountermap() { // 使用表
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "countermap"), countermap);
	}

	@Override
	public java.util.Map<Integer, xbean.DayCount> getCountermapAsData() { // 使用表
		_xdb_verify_unsafe_();
		java.util.Map<Integer, xbean.DayCount> countermap;
		DayCounter _o_ = this;
		countermap = new java.util.HashMap<Integer, xbean.DayCount>();
		for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : _o_.countermap.entrySet())
			countermap.put(_e_.getKey(), new DayCount.Data(_e_.getValue()));
		return countermap;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		DayCounter _o_ = null;
		if ( _o1_ instanceof DayCounter ) _o_ = (DayCounter)_o1_;
		else if ( _o1_ instanceof DayCounter.Const ) _o_ = ((DayCounter.Const)_o1_).nThis();
		else return false;
		if (!countermap.equals(_o_.countermap)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += countermap.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(countermap);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableMap().setVarName("countermap"));
		return lb;
	}

	private class Const implements xbean.DayCounter {
		DayCounter nThis() {
			return DayCounter.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.DayCounter copy() {
			return DayCounter.this.copy();
		}

		@Override
		public xbean.DayCounter toData() {
			return DayCounter.this.toData();
		}

		public xbean.DayCounter toBean() {
			return DayCounter.this.toBean();
		}

		@Override
		public xbean.DayCounter toDataIf() {
			return DayCounter.this.toDataIf();
		}

		public xbean.DayCounter toBeanIf() {
			return DayCounter.this.toBeanIf();
		}

		@Override
		public java.util.Map<Integer, xbean.DayCount> getCountermap() { // 使用表
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(countermap);
		}

		@Override
		public java.util.Map<Integer, xbean.DayCount> getCountermapAsData() { // 使用表
			_xdb_verify_unsafe_();
			java.util.Map<Integer, xbean.DayCount> countermap;
			DayCounter _o_ = DayCounter.this;
			countermap = new java.util.HashMap<Integer, xbean.DayCount>();
			for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : _o_.countermap.entrySet())
				countermap.put(_e_.getKey(), new DayCount.Data(_e_.getValue()));
			return countermap;
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
			return DayCounter.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return DayCounter.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return DayCounter.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return DayCounter.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return DayCounter.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return DayCounter.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return DayCounter.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return DayCounter.this.hashCode();
		}

		@Override
		public String toString() {
			return DayCounter.this.toString();
		}

	}

	public static final class Data implements xbean.DayCounter {
		private java.util.HashMap<Integer, xbean.DayCount> countermap; // 使用表

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			countermap = new java.util.HashMap<Integer, xbean.DayCount>();
		}

		Data(xbean.DayCounter _o1_) {
			if (_o1_ instanceof DayCounter) assign((DayCounter)_o1_);
			else if (_o1_ instanceof DayCounter.Data) assign((DayCounter.Data)_o1_);
			else if (_o1_ instanceof DayCounter.Const) assign(((DayCounter.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(DayCounter _o_) {
			countermap = new java.util.HashMap<Integer, xbean.DayCount>();
			for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : _o_.countermap.entrySet())
				countermap.put(_e_.getKey(), new DayCount.Data(_e_.getValue()));
		}

		private void assign(DayCounter.Data _o_) {
			countermap = new java.util.HashMap<Integer, xbean.DayCount>();
			for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : _o_.countermap.entrySet())
				countermap.put(_e_.getKey(), new DayCount.Data(_e_.getValue()));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(countermap.size());
			for (java.util.Map.Entry<Integer, xbean.DayCount> _e_ : countermap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					countermap = new java.util.HashMap<Integer, xbean.DayCount>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.DayCount _v_ = xbean.Pod.newDayCountData();
					_v_.unmarshal(_os_);
					countermap.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.DayCounter copy() {
			return new Data(this);
		}

		@Override
		public xbean.DayCounter toData() {
			return new Data(this);
		}

		public xbean.DayCounter toBean() {
			return new DayCounter(this, null, null);
		}

		@Override
		public xbean.DayCounter toDataIf() {
			return this;
		}

		public xbean.DayCounter toBeanIf() {
			return new DayCounter(this, null, null);
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
		public java.util.Map<Integer, xbean.DayCount> getCountermap() { // 使用表
			return countermap;
		}

		@Override
		public java.util.Map<Integer, xbean.DayCount> getCountermapAsData() { // 使用表
			return countermap;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof DayCounter.Data)) return false;
			DayCounter.Data _o_ = (DayCounter.Data) _o1_;
			if (!countermap.equals(_o_.countermap)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += countermap.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(countermap);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
