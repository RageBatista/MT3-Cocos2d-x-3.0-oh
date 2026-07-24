
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class DailyInfo extends mkdb.XBean implements xbean.DailyInfo {
	private long paynum; // 每日数量
	private long time; // 每日数量
	private java.util.HashMap<Integer, Long> dayrewardmap; // 

	@Override
	public void _reset_unsafe_() {
		paynum = 0L;
		time = 0L;
		dayrewardmap.clear();
	}

	DailyInfo(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		dayrewardmap = new java.util.HashMap<Integer, Long>();
	}

	public DailyInfo() {
		this(0, null, null);
	}

	public DailyInfo(DailyInfo _o_) {
		this(_o_, null, null);
	}

	DailyInfo(xbean.DailyInfo _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof DailyInfo) assign((DailyInfo)_o1_);
		else if (_o1_ instanceof DailyInfo.Data) assign((DailyInfo.Data)_o1_);
		else if (_o1_ instanceof DailyInfo.Const) assign(((DailyInfo.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(DailyInfo _o_) {
		_o_._xdb_verify_unsafe_();
		paynum = _o_.paynum;
		time = _o_.time;
		dayrewardmap = new java.util.HashMap<Integer, Long>();
		for (java.util.Map.Entry<Integer, Long> _e_ : _o_.dayrewardmap.entrySet())
			dayrewardmap.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(DailyInfo.Data _o_) {
		paynum = _o_.paynum;
		time = _o_.time;
		dayrewardmap = new java.util.HashMap<Integer, Long>();
		for (java.util.Map.Entry<Integer, Long> _e_ : _o_.dayrewardmap.entrySet())
			dayrewardmap.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(paynum);
		_os_.marshal(time);
		_os_.compact_uint32(dayrewardmap.size());
		for (java.util.Map.Entry<Integer, Long> _e_ : dayrewardmap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		paynum = _os_.unmarshal_long();
		time = _os_.unmarshal_long();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				dayrewardmap = new java.util.HashMap<Integer, Long>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				long _v_ = 0;
				_v_ = _os_.unmarshal_long();
				dayrewardmap.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.DailyInfo copy() {
		_xdb_verify_unsafe_();
		return new DailyInfo(this);
	}

	@Override
	public xbean.DailyInfo toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.DailyInfo toBean() {
		_xdb_verify_unsafe_();
		return new DailyInfo(this); // same as copy()
	}

	@Override
	public xbean.DailyInfo toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.DailyInfo toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public long getPaynum() { // 每日数量
		_xdb_verify_unsafe_();
		return paynum;
	}

	@Override
	public long getTime() { // 每日数量
		_xdb_verify_unsafe_();
		return time;
	}

	@Override
	public java.util.Map<Integer, Long> getDayrewardmap() { // 
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "dayrewardmap"), dayrewardmap);
	}

	@Override
	public java.util.Map<Integer, Long> getDayrewardmapAsData() { // 
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Long> dayrewardmap;
		DailyInfo _o_ = this;
		dayrewardmap = new java.util.HashMap<Integer, Long>();
		for (java.util.Map.Entry<Integer, Long> _e_ : _o_.dayrewardmap.entrySet())
			dayrewardmap.put(_e_.getKey(), _e_.getValue());
		return dayrewardmap;
	}

	@Override
	public void setPaynum(long _v_) { // 每日数量
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "paynum") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, paynum) {
					public void rollback() { paynum = _xdb_saved; }
				};}});
		paynum = _v_;
	}

	@Override
	public void setTime(long _v_) { // 每日数量
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "time") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, time) {
					public void rollback() { time = _xdb_saved; }
				};}});
		time = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		DailyInfo _o_ = null;
		if ( _o1_ instanceof DailyInfo ) _o_ = (DailyInfo)_o1_;
		else if ( _o1_ instanceof DailyInfo.Const ) _o_ = ((DailyInfo.Const)_o1_).nThis();
		else return false;
		if (paynum != _o_.paynum) return false;
		if (time != _o_.time) return false;
		if (!dayrewardmap.equals(_o_.dayrewardmap)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += paynum;
		_h_ += time;
		_h_ += dayrewardmap.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(paynum);
		_sb_.append(",");
		_sb_.append(time);
		_sb_.append(",");
		_sb_.append(dayrewardmap);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("paynum"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("time"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("dayrewardmap"));
		return lb;
	}

	private class Const implements xbean.DailyInfo {
		DailyInfo nThis() {
			return DailyInfo.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.DailyInfo copy() {
			return DailyInfo.this.copy();
		}

		@Override
		public xbean.DailyInfo toData() {
			return DailyInfo.this.toData();
		}

		public xbean.DailyInfo toBean() {
			return DailyInfo.this.toBean();
		}

		@Override
		public xbean.DailyInfo toDataIf() {
			return DailyInfo.this.toDataIf();
		}

		public xbean.DailyInfo toBeanIf() {
			return DailyInfo.this.toBeanIf();
		}

		@Override
		public long getPaynum() { // 每日数量
			_xdb_verify_unsafe_();
			return paynum;
		}

		@Override
		public long getTime() { // 每日数量
			_xdb_verify_unsafe_();
			return time;
		}

		@Override
		public java.util.Map<Integer, Long> getDayrewardmap() { // 
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(dayrewardmap);
		}

		@Override
		public java.util.Map<Integer, Long> getDayrewardmapAsData() { // 
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Long> dayrewardmap;
			DailyInfo _o_ = DailyInfo.this;
			dayrewardmap = new java.util.HashMap<Integer, Long>();
			for (java.util.Map.Entry<Integer, Long> _e_ : _o_.dayrewardmap.entrySet())
				dayrewardmap.put(_e_.getKey(), _e_.getValue());
			return dayrewardmap;
		}

		@Override
		public void setPaynum(long _v_) { // 每日数量
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setTime(long _v_) { // 每日数量
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
			return DailyInfo.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return DailyInfo.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return DailyInfo.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return DailyInfo.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return DailyInfo.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return DailyInfo.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return DailyInfo.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return DailyInfo.this.hashCode();
		}

		@Override
		public String toString() {
			return DailyInfo.this.toString();
		}

	}

	public static final class Data implements xbean.DailyInfo {
		private long paynum; // 每日数量
		private long time; // 每日数量
		private java.util.HashMap<Integer, Long> dayrewardmap; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			dayrewardmap = new java.util.HashMap<Integer, Long>();
		}

		Data(xbean.DailyInfo _o1_) {
			if (_o1_ instanceof DailyInfo) assign((DailyInfo)_o1_);
			else if (_o1_ instanceof DailyInfo.Data) assign((DailyInfo.Data)_o1_);
			else if (_o1_ instanceof DailyInfo.Const) assign(((DailyInfo.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(DailyInfo _o_) {
			paynum = _o_.paynum;
			time = _o_.time;
			dayrewardmap = new java.util.HashMap<Integer, Long>();
			for (java.util.Map.Entry<Integer, Long> _e_ : _o_.dayrewardmap.entrySet())
				dayrewardmap.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(DailyInfo.Data _o_) {
			paynum = _o_.paynum;
			time = _o_.time;
			dayrewardmap = new java.util.HashMap<Integer, Long>();
			for (java.util.Map.Entry<Integer, Long> _e_ : _o_.dayrewardmap.entrySet())
				dayrewardmap.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(paynum);
			_os_.marshal(time);
			_os_.compact_uint32(dayrewardmap.size());
			for (java.util.Map.Entry<Integer, Long> _e_ : dayrewardmap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			paynum = _os_.unmarshal_long();
			time = _os_.unmarshal_long();
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					dayrewardmap = new java.util.HashMap<Integer, Long>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					long _v_ = 0;
					_v_ = _os_.unmarshal_long();
					dayrewardmap.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.DailyInfo copy() {
			return new Data(this);
		}

		@Override
		public xbean.DailyInfo toData() {
			return new Data(this);
		}

		public xbean.DailyInfo toBean() {
			return new DailyInfo(this, null, null);
		}

		@Override
		public xbean.DailyInfo toDataIf() {
			return this;
		}

		public xbean.DailyInfo toBeanIf() {
			return new DailyInfo(this, null, null);
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
		public long getPaynum() { // 每日数量
			return paynum;
		}

		@Override
		public long getTime() { // 每日数量
			return time;
		}

		@Override
		public java.util.Map<Integer, Long> getDayrewardmap() { // 
			return dayrewardmap;
		}

		@Override
		public java.util.Map<Integer, Long> getDayrewardmapAsData() { // 
			return dayrewardmap;
		}

		@Override
		public void setPaynum(long _v_) { // 每日数量
			paynum = _v_;
		}

		@Override
		public void setTime(long _v_) { // 每日数量
			time = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof DailyInfo.Data)) return false;
			DailyInfo.Data _o_ = (DailyInfo.Data) _o1_;
			if (paynum != _o_.paynum) return false;
			if (time != _o_.time) return false;
			if (!dayrewardmap.equals(_o_.dayrewardmap)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += paynum;
			_h_ += time;
			_h_ += dayrewardmap.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(paynum);
			_sb_.append(",");
			_sb_.append(time);
			_sb_.append(",");
			_sb_.append(dayrewardmap);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
