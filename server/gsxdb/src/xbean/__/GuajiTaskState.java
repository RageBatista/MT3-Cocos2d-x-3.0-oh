
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class GuajiTaskState extends mkdb.XBean implements xbean.GuajiTaskState {
	private java.util.LinkedList<Integer> guajitypeids; // 挂机类型ID列表
	private int initialmapid; // 初始地图ID
	private int guajitypeindex; // 当前挂机类型索引
	private int mapidindex; // 当前地图ID索引
	private long lastruntimestamp; // 最后运行时间戳
	private long starttime; // 挂机开始时间
	private String source; // 挂机来源(client/gm)
	private int status; // 挂机状态: 0=已停止, 1=运行中, 2=暂停

	@Override
	public void _reset_unsafe_() {
		guajitypeids.clear();
		initialmapid = 0;
		guajitypeindex = 0;
		mapidindex = 0;
		lastruntimestamp = 0;
		starttime = 0L;
		source = "";
		status = 1;
	}

	GuajiTaskState(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		guajitypeids = new java.util.LinkedList<Integer>();
		guajitypeindex = 0;
		mapidindex = 0;
		lastruntimestamp = 0;
		source = "";
		status = 1;
	}

	public GuajiTaskState() {
		this(0, null, null);
	}

	public GuajiTaskState(GuajiTaskState _o_) {
		this(_o_, null, null);
	}

	GuajiTaskState(xbean.GuajiTaskState _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof GuajiTaskState) assign((GuajiTaskState)_o1_);
		else if (_o1_ instanceof GuajiTaskState.Data) assign((GuajiTaskState.Data)_o1_);
		else if (_o1_ instanceof GuajiTaskState.Const) assign(((GuajiTaskState.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(GuajiTaskState _o_) {
		_o_._xdb_verify_unsafe_();
		guajitypeids = new java.util.LinkedList<Integer>();
		guajitypeids.addAll(_o_.guajitypeids);
		initialmapid = _o_.initialmapid;
		guajitypeindex = _o_.guajitypeindex;
		mapidindex = _o_.mapidindex;
		lastruntimestamp = _o_.lastruntimestamp;
		starttime = _o_.starttime;
		source = _o_.source;
		status = _o_.status;
	}

	private void assign(GuajiTaskState.Data _o_) {
		guajitypeids = new java.util.LinkedList<Integer>();
		guajitypeids.addAll(_o_.guajitypeids);
		initialmapid = _o_.initialmapid;
		guajitypeindex = _o_.guajitypeindex;
		mapidindex = _o_.mapidindex;
		lastruntimestamp = _o_.lastruntimestamp;
		starttime = _o_.starttime;
		source = _o_.source;
		status = _o_.status;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.compact_uint32(guajitypeids.size());
		for (Integer _v_ : guajitypeids) {
			_os_.marshal(_v_);
		}
		_os_.marshal(initialmapid);
		_os_.marshal(guajitypeindex);
		_os_.marshal(mapidindex);
		_os_.marshal(lastruntimestamp);
		_os_.marshal(starttime);
		_os_.marshal(source, mkdb.Const.IO_CHARSET);
		_os_.marshal(status);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			guajitypeids.add(_v_);
		}
		initialmapid = _os_.unmarshal_int();
		guajitypeindex = _os_.unmarshal_int();
		mapidindex = _os_.unmarshal_int();
		lastruntimestamp = _os_.unmarshal_long();
		starttime = _os_.unmarshal_long();
		source = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		status = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.GuajiTaskState copy() {
		_xdb_verify_unsafe_();
		return new GuajiTaskState(this);
	}

	@Override
	public xbean.GuajiTaskState toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.GuajiTaskState toBean() {
		_xdb_verify_unsafe_();
		return new GuajiTaskState(this); // same as copy()
	}

	@Override
	public xbean.GuajiTaskState toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.GuajiTaskState toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public java.util.List<Integer> getGuajitypeids() { // 挂机类型ID列表
		_xdb_verify_unsafe_();
		return mkdb.Logs.logList(new mkdb.LogKey(this, "guajitypeids"), guajitypeids);
	}

	public java.util.List<Integer> getGuajitypeidsAsData() { // 挂机类型ID列表
		_xdb_verify_unsafe_();
		java.util.List<Integer> guajitypeids;
		GuajiTaskState _o_ = this;
		guajitypeids = new java.util.LinkedList<Integer>();
		guajitypeids.addAll(_o_.guajitypeids);
		return guajitypeids;
	}

	@Override
	public int getInitialmapid() { // 初始地图ID
		_xdb_verify_unsafe_();
		return initialmapid;
	}

	@Override
	public int getGuajitypeindex() { // 当前挂机类型索引
		_xdb_verify_unsafe_();
		return guajitypeindex;
	}

	@Override
	public int getMapidindex() { // 当前地图ID索引
		_xdb_verify_unsafe_();
		return mapidindex;
	}

	@Override
	public long getLastruntimestamp() { // 最后运行时间戳
		_xdb_verify_unsafe_();
		return lastruntimestamp;
	}

	@Override
	public long getStarttime() { // 挂机开始时间
		_xdb_verify_unsafe_();
		return starttime;
	}

	@Override
	public String getSource() { // 挂机来源(client/gm)
		_xdb_verify_unsafe_();
		return source;
	}

	@Override
	public com.locojoy.base.Octets getSourceOctets() { // 挂机来源(client/gm)
		_xdb_verify_unsafe_();
		return com.locojoy.base.Octets.wrap(getSource(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public int getStatus() { // 挂机状态: 0=已停止, 1=运行中, 2=暂停
		_xdb_verify_unsafe_();
		return status;
	}

	@Override
	public void setInitialmapid(int _v_) { // 初始地图ID
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "initialmapid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, initialmapid) {
					public void rollback() { initialmapid = _xdb_saved; }
				};}});
		initialmapid = _v_;
	}

	@Override
	public void setGuajitypeindex(int _v_) { // 当前挂机类型索引
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "guajitypeindex") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, guajitypeindex) {
					public void rollback() { guajitypeindex = _xdb_saved; }
				};}});
		guajitypeindex = _v_;
	}

	@Override
	public void setMapidindex(int _v_) { // 当前地图ID索引
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "mapidindex") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, mapidindex) {
					public void rollback() { mapidindex = _xdb_saved; }
				};}});
		mapidindex = _v_;
	}

	@Override
	public void setLastruntimestamp(long _v_) { // 最后运行时间戳
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "lastruntimestamp") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, lastruntimestamp) {
					public void rollback() { lastruntimestamp = _xdb_saved; }
				};}});
		lastruntimestamp = _v_;
	}

	@Override
	public void setStarttime(long _v_) { // 挂机开始时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "starttime") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, starttime) {
					public void rollback() { starttime = _xdb_saved; }
				};}});
		starttime = _v_;
	}

	@Override
	public void setSource(String _v_) { // 挂机来源(client/gm)
		_xdb_verify_unsafe_();
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "source") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, source) {
					public void rollback() { source = _xdb_saved; }
				};}});
		source = _v_;
	}

	@Override
	public void setSourceOctets(com.locojoy.base.Octets _v_) { // 挂机来源(client/gm)
		_xdb_verify_unsafe_();
		this.setSource(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setStatus(int _v_) { // 挂机状态: 0=已停止, 1=运行中, 2=暂停
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "status") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, status) {
					public void rollback() { status = _xdb_saved; }
				};}});
		status = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		GuajiTaskState _o_ = null;
		if ( _o1_ instanceof GuajiTaskState ) _o_ = (GuajiTaskState)_o1_;
		else if ( _o1_ instanceof GuajiTaskState.Const ) _o_ = ((GuajiTaskState.Const)_o1_).nThis();
		else return false;
		if (!guajitypeids.equals(_o_.guajitypeids)) return false;
		if (initialmapid != _o_.initialmapid) return false;
		if (guajitypeindex != _o_.guajitypeindex) return false;
		if (mapidindex != _o_.mapidindex) return false;
		if (lastruntimestamp != _o_.lastruntimestamp) return false;
		if (starttime != _o_.starttime) return false;
		if (!source.equals(_o_.source)) return false;
		if (status != _o_.status) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += guajitypeids.hashCode();
		_h_ += initialmapid;
		_h_ += guajitypeindex;
		_h_ += mapidindex;
		_h_ += lastruntimestamp;
		_h_ += starttime;
		_h_ += source.hashCode();
		_h_ += status;
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(guajitypeids);
		_sb_.append(",");
		_sb_.append(initialmapid);
		_sb_.append(",");
		_sb_.append(guajitypeindex);
		_sb_.append(",");
		_sb_.append(mapidindex);
		_sb_.append(",");
		_sb_.append(lastruntimestamp);
		_sb_.append(",");
		_sb_.append(starttime);
		_sb_.append(",");
		_sb_.append("'").append(source).append("'");
		_sb_.append(",");
		_sb_.append(status);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("guajitypeids"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("initialmapid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("guajitypeindex"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("mapidindex"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("lastruntimestamp"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("starttime"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("source"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("status"));
		return lb;
	}

	private class Const implements xbean.GuajiTaskState {
		GuajiTaskState nThis() {
			return GuajiTaskState.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.GuajiTaskState copy() {
			return GuajiTaskState.this.copy();
		}

		@Override
		public xbean.GuajiTaskState toData() {
			return GuajiTaskState.this.toData();
		}

		public xbean.GuajiTaskState toBean() {
			return GuajiTaskState.this.toBean();
		}

		@Override
		public xbean.GuajiTaskState toDataIf() {
			return GuajiTaskState.this.toDataIf();
		}

		public xbean.GuajiTaskState toBeanIf() {
			return GuajiTaskState.this.toBeanIf();
		}

		@Override
		public java.util.List<Integer> getGuajitypeids() { // 挂机类型ID列表
			_xdb_verify_unsafe_();
			return mkdb.Consts.constList(guajitypeids);
		}

		public java.util.List<Integer> getGuajitypeidsAsData() { // 挂机类型ID列表
			_xdb_verify_unsafe_();
			java.util.List<Integer> guajitypeids;
			GuajiTaskState _o_ = GuajiTaskState.this;
		guajitypeids = new java.util.LinkedList<Integer>();
		guajitypeids.addAll(_o_.guajitypeids);
			return guajitypeids;
		}

		@Override
		public int getInitialmapid() { // 初始地图ID
			_xdb_verify_unsafe_();
			return initialmapid;
		}

		@Override
		public int getGuajitypeindex() { // 当前挂机类型索引
			_xdb_verify_unsafe_();
			return guajitypeindex;
		}

		@Override
		public int getMapidindex() { // 当前地图ID索引
			_xdb_verify_unsafe_();
			return mapidindex;
		}

		@Override
		public long getLastruntimestamp() { // 最后运行时间戳
			_xdb_verify_unsafe_();
			return lastruntimestamp;
		}

		@Override
		public long getStarttime() { // 挂机开始时间
			_xdb_verify_unsafe_();
			return starttime;
		}

		@Override
		public String getSource() { // 挂机来源(client/gm)
			_xdb_verify_unsafe_();
			return source;
		}

		@Override
		public com.locojoy.base.Octets getSourceOctets() { // 挂机来源(client/gm)
			_xdb_verify_unsafe_();
			return GuajiTaskState.this.getSourceOctets();
		}

		@Override
		public int getStatus() { // 挂机状态: 0=已停止, 1=运行中, 2=暂停
			_xdb_verify_unsafe_();
			return status;
		}

		@Override
		public void setInitialmapid(int _v_) { // 初始地图ID
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setGuajitypeindex(int _v_) { // 当前挂机类型索引
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMapidindex(int _v_) { // 当前地图ID索引
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLastruntimestamp(long _v_) { // 最后运行时间戳
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setStarttime(long _v_) { // 挂机开始时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setSource(String _v_) { // 挂机来源(client/gm)
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setSourceOctets(com.locojoy.base.Octets _v_) { // 挂机来源(client/gm)
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setStatus(int _v_) { // 挂机状态: 0=已停止, 1=运行中, 2=暂停
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
			return GuajiTaskState.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return GuajiTaskState.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return GuajiTaskState.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return GuajiTaskState.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return GuajiTaskState.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return GuajiTaskState.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return GuajiTaskState.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return GuajiTaskState.this.hashCode();
		}

		@Override
		public String toString() {
			return GuajiTaskState.this.toString();
		}

	}

	public static final class Data implements xbean.GuajiTaskState {
		private java.util.LinkedList<Integer> guajitypeids; // 挂机类型ID列表
		private int initialmapid; // 初始地图ID
		private int guajitypeindex; // 当前挂机类型索引
		private int mapidindex; // 当前地图ID索引
		private long lastruntimestamp; // 最后运行时间戳
		private long starttime; // 挂机开始时间
		private String source; // 挂机来源(client/gm)
		private int status; // 挂机状态: 0=已停止, 1=运行中, 2=暂停

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			guajitypeids = new java.util.LinkedList<Integer>();
			guajitypeindex = 0;
			mapidindex = 0;
			lastruntimestamp = 0;
			source = "";
			status = 1;
		}

		Data(xbean.GuajiTaskState _o1_) {
			if (_o1_ instanceof GuajiTaskState) assign((GuajiTaskState)_o1_);
			else if (_o1_ instanceof GuajiTaskState.Data) assign((GuajiTaskState.Data)_o1_);
			else if (_o1_ instanceof GuajiTaskState.Const) assign(((GuajiTaskState.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(GuajiTaskState _o_) {
			guajitypeids = new java.util.LinkedList<Integer>();
			guajitypeids.addAll(_o_.guajitypeids);
			initialmapid = _o_.initialmapid;
			guajitypeindex = _o_.guajitypeindex;
			mapidindex = _o_.mapidindex;
			lastruntimestamp = _o_.lastruntimestamp;
			starttime = _o_.starttime;
			source = _o_.source;
			status = _o_.status;
		}

		private void assign(GuajiTaskState.Data _o_) {
			guajitypeids = new java.util.LinkedList<Integer>();
			guajitypeids.addAll(_o_.guajitypeids);
			initialmapid = _o_.initialmapid;
			guajitypeindex = _o_.guajitypeindex;
			mapidindex = _o_.mapidindex;
			lastruntimestamp = _o_.lastruntimestamp;
			starttime = _o_.starttime;
			source = _o_.source;
			status = _o_.status;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(guajitypeids.size());
			for (Integer _v_ : guajitypeids) {
				_os_.marshal(_v_);
			}
			_os_.marshal(initialmapid);
			_os_.marshal(guajitypeindex);
			_os_.marshal(mapidindex);
			_os_.marshal(lastruntimestamp);
			_os_.marshal(starttime);
			_os_.marshal(source, mkdb.Const.IO_CHARSET);
			_os_.marshal(status);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				guajitypeids.add(_v_);
			}
			initialmapid = _os_.unmarshal_int();
			guajitypeindex = _os_.unmarshal_int();
			mapidindex = _os_.unmarshal_int();
			lastruntimestamp = _os_.unmarshal_long();
			starttime = _os_.unmarshal_long();
			source = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			status = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.GuajiTaskState copy() {
			return new Data(this);
		}

		@Override
		public xbean.GuajiTaskState toData() {
			return new Data(this);
		}

		public xbean.GuajiTaskState toBean() {
			return new GuajiTaskState(this, null, null);
		}

		@Override
		public xbean.GuajiTaskState toDataIf() {
			return this;
		}

		public xbean.GuajiTaskState toBeanIf() {
			return new GuajiTaskState(this, null, null);
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
		public java.util.List<Integer> getGuajitypeids() { // 挂机类型ID列表
			return guajitypeids;
		}

		@Override
		public java.util.List<Integer> getGuajitypeidsAsData() { // 挂机类型ID列表
			return guajitypeids;
		}

		@Override
		public int getInitialmapid() { // 初始地图ID
			return initialmapid;
		}

		@Override
		public int getGuajitypeindex() { // 当前挂机类型索引
			return guajitypeindex;
		}

		@Override
		public int getMapidindex() { // 当前地图ID索引
			return mapidindex;
		}

		@Override
		public long getLastruntimestamp() { // 最后运行时间戳
			return lastruntimestamp;
		}

		@Override
		public long getStarttime() { // 挂机开始时间
			return starttime;
		}

		@Override
		public String getSource() { // 挂机来源(client/gm)
			return source;
		}

		@Override
		public com.locojoy.base.Octets getSourceOctets() { // 挂机来源(client/gm)
			return com.locojoy.base.Octets.wrap(getSource(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public int getStatus() { // 挂机状态: 0=已停止, 1=运行中, 2=暂停
			return status;
		}

		@Override
		public void setInitialmapid(int _v_) { // 初始地图ID
			initialmapid = _v_;
		}

		@Override
		public void setGuajitypeindex(int _v_) { // 当前挂机类型索引
			guajitypeindex = _v_;
		}

		@Override
		public void setMapidindex(int _v_) { // 当前地图ID索引
			mapidindex = _v_;
		}

		@Override
		public void setLastruntimestamp(long _v_) { // 最后运行时间戳
			lastruntimestamp = _v_;
		}

		@Override
		public void setStarttime(long _v_) { // 挂机开始时间
			starttime = _v_;
		}

		@Override
		public void setSource(String _v_) { // 挂机来源(client/gm)
			if (null == _v_)
				throw new NullPointerException();
			source = _v_;
		}

		@Override
		public void setSourceOctets(com.locojoy.base.Octets _v_) { // 挂机来源(client/gm)
			this.setSource(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setStatus(int _v_) { // 挂机状态: 0=已停止, 1=运行中, 2=暂停
			status = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof GuajiTaskState.Data)) return false;
			GuajiTaskState.Data _o_ = (GuajiTaskState.Data) _o1_;
			if (!guajitypeids.equals(_o_.guajitypeids)) return false;
			if (initialmapid != _o_.initialmapid) return false;
			if (guajitypeindex != _o_.guajitypeindex) return false;
			if (mapidindex != _o_.mapidindex) return false;
			if (lastruntimestamp != _o_.lastruntimestamp) return false;
			if (starttime != _o_.starttime) return false;
			if (!source.equals(_o_.source)) return false;
			if (status != _o_.status) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += guajitypeids.hashCode();
			_h_ += initialmapid;
			_h_ += guajitypeindex;
			_h_ += mapidindex;
			_h_ += lastruntimestamp;
			_h_ += starttime;
			_h_ += source.hashCode();
			_h_ += status;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(guajitypeids);
			_sb_.append(",");
			_sb_.append(initialmapid);
			_sb_.append(",");
			_sb_.append(guajitypeindex);
			_sb_.append(",");
			_sb_.append(mapidindex);
			_sb_.append(",");
			_sb_.append(lastruntimestamp);
			_sb_.append(",");
			_sb_.append(starttime);
			_sb_.append(",");
			_sb_.append("'").append(source).append("'");
			_sb_.append(",");
			_sb_.append(status);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
