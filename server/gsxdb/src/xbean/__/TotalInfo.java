
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class TotalInfo extends mkdb.XBean implements xbean.TotalInfo {
	private long total; // 累计充值
	private java.util.HashMap<Integer, Long> totalrewardmap; // 

	@Override
	public void _reset_unsafe_() {
		total = 0L;
		totalrewardmap.clear();
	}

	TotalInfo(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		totalrewardmap = new java.util.HashMap<Integer, Long>();
	}

	public TotalInfo() {
		this(0, null, null);
	}

	public TotalInfo(TotalInfo _o_) {
		this(_o_, null, null);
	}

	TotalInfo(xbean.TotalInfo _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof TotalInfo) assign((TotalInfo)_o1_);
		else if (_o1_ instanceof TotalInfo.Data) assign((TotalInfo.Data)_o1_);
		else if (_o1_ instanceof TotalInfo.Const) assign(((TotalInfo.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(TotalInfo _o_) {
		_o_._xdb_verify_unsafe_();
		total = _o_.total;
		totalrewardmap = new java.util.HashMap<Integer, Long>();
		for (java.util.Map.Entry<Integer, Long> _e_ : _o_.totalrewardmap.entrySet())
			totalrewardmap.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(TotalInfo.Data _o_) {
		total = _o_.total;
		totalrewardmap = new java.util.HashMap<Integer, Long>();
		for (java.util.Map.Entry<Integer, Long> _e_ : _o_.totalrewardmap.entrySet())
			totalrewardmap.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(total);
		_os_.compact_uint32(totalrewardmap.size());
		for (java.util.Map.Entry<Integer, Long> _e_ : totalrewardmap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		total = _os_.unmarshal_long();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				totalrewardmap = new java.util.HashMap<Integer, Long>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				long _v_ = 0;
				_v_ = _os_.unmarshal_long();
				totalrewardmap.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.TotalInfo copy() {
		_xdb_verify_unsafe_();
		return new TotalInfo(this);
	}

	@Override
	public xbean.TotalInfo toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.TotalInfo toBean() {
		_xdb_verify_unsafe_();
		return new TotalInfo(this); // same as copy()
	}

	@Override
	public xbean.TotalInfo toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.TotalInfo toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public long getTotal() { // 累计充值
		_xdb_verify_unsafe_();
		return total;
	}

	@Override
	public java.util.Map<Integer, Long> getTotalrewardmap() { // 
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "totalrewardmap"), totalrewardmap);
	}

	@Override
	public java.util.Map<Integer, Long> getTotalrewardmapAsData() { // 
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Long> totalrewardmap;
		TotalInfo _o_ = this;
		totalrewardmap = new java.util.HashMap<Integer, Long>();
		for (java.util.Map.Entry<Integer, Long> _e_ : _o_.totalrewardmap.entrySet())
			totalrewardmap.put(_e_.getKey(), _e_.getValue());
		return totalrewardmap;
	}

	@Override
	public void setTotal(long _v_) { // 累计充值
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "total") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, total) {
					public void rollback() { total = _xdb_saved; }
				};}});
		total = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		TotalInfo _o_ = null;
		if ( _o1_ instanceof TotalInfo ) _o_ = (TotalInfo)_o1_;
		else if ( _o1_ instanceof TotalInfo.Const ) _o_ = ((TotalInfo.Const)_o1_).nThis();
		else return false;
		if (total != _o_.total) return false;
		if (!totalrewardmap.equals(_o_.totalrewardmap)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += total;
		_h_ += totalrewardmap.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(total);
		_sb_.append(",");
		_sb_.append(totalrewardmap);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("total"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("totalrewardmap"));
		return lb;
	}

	private class Const implements xbean.TotalInfo {
		TotalInfo nThis() {
			return TotalInfo.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.TotalInfo copy() {
			return TotalInfo.this.copy();
		}

		@Override
		public xbean.TotalInfo toData() {
			return TotalInfo.this.toData();
		}

		public xbean.TotalInfo toBean() {
			return TotalInfo.this.toBean();
		}

		@Override
		public xbean.TotalInfo toDataIf() {
			return TotalInfo.this.toDataIf();
		}

		public xbean.TotalInfo toBeanIf() {
			return TotalInfo.this.toBeanIf();
		}

		@Override
		public long getTotal() { // 累计充值
			_xdb_verify_unsafe_();
			return total;
		}

		@Override
		public java.util.Map<Integer, Long> getTotalrewardmap() { // 
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(totalrewardmap);
		}

		@Override
		public java.util.Map<Integer, Long> getTotalrewardmapAsData() { // 
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Long> totalrewardmap;
			TotalInfo _o_ = TotalInfo.this;
			totalrewardmap = new java.util.HashMap<Integer, Long>();
			for (java.util.Map.Entry<Integer, Long> _e_ : _o_.totalrewardmap.entrySet())
				totalrewardmap.put(_e_.getKey(), _e_.getValue());
			return totalrewardmap;
		}

		@Override
		public void setTotal(long _v_) { // 累计充值
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
			return TotalInfo.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return TotalInfo.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return TotalInfo.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return TotalInfo.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return TotalInfo.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return TotalInfo.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return TotalInfo.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return TotalInfo.this.hashCode();
		}

		@Override
		public String toString() {
			return TotalInfo.this.toString();
		}

	}

	public static final class Data implements xbean.TotalInfo {
		private long total; // 累计充值
		private java.util.HashMap<Integer, Long> totalrewardmap; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			totalrewardmap = new java.util.HashMap<Integer, Long>();
		}

		Data(xbean.TotalInfo _o1_) {
			if (_o1_ instanceof TotalInfo) assign((TotalInfo)_o1_);
			else if (_o1_ instanceof TotalInfo.Data) assign((TotalInfo.Data)_o1_);
			else if (_o1_ instanceof TotalInfo.Const) assign(((TotalInfo.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(TotalInfo _o_) {
			total = _o_.total;
			totalrewardmap = new java.util.HashMap<Integer, Long>();
			for (java.util.Map.Entry<Integer, Long> _e_ : _o_.totalrewardmap.entrySet())
				totalrewardmap.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(TotalInfo.Data _o_) {
			total = _o_.total;
			totalrewardmap = new java.util.HashMap<Integer, Long>();
			for (java.util.Map.Entry<Integer, Long> _e_ : _o_.totalrewardmap.entrySet())
				totalrewardmap.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(total);
			_os_.compact_uint32(totalrewardmap.size());
			for (java.util.Map.Entry<Integer, Long> _e_ : totalrewardmap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			total = _os_.unmarshal_long();
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					totalrewardmap = new java.util.HashMap<Integer, Long>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					long _v_ = 0;
					_v_ = _os_.unmarshal_long();
					totalrewardmap.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.TotalInfo copy() {
			return new Data(this);
		}

		@Override
		public xbean.TotalInfo toData() {
			return new Data(this);
		}

		public xbean.TotalInfo toBean() {
			return new TotalInfo(this, null, null);
		}

		@Override
		public xbean.TotalInfo toDataIf() {
			return this;
		}

		public xbean.TotalInfo toBeanIf() {
			return new TotalInfo(this, null, null);
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
		public long getTotal() { // 累计充值
			return total;
		}

		@Override
		public java.util.Map<Integer, Long> getTotalrewardmap() { // 
			return totalrewardmap;
		}

		@Override
		public java.util.Map<Integer, Long> getTotalrewardmapAsData() { // 
			return totalrewardmap;
		}

		@Override
		public void setTotal(long _v_) { // 累计充值
			total = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof TotalInfo.Data)) return false;
			TotalInfo.Data _o_ = (TotalInfo.Data) _o1_;
			if (total != _o_.total) return false;
			if (!totalrewardmap.equals(_o_.totalrewardmap)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += total;
			_h_ += totalrewardmap.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(total);
			_sb_.append(",");
			_sb_.append(totalrewardmap);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
