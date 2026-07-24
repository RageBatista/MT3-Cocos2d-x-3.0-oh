
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class jiebaiAskInfo extends mkdb.XBean implements xbean.jiebaiAskInfo {
	private String titlename; // 结拜称号名称
	private java.util.HashMap<Long, String> jiebaiinfo; // 角色ID -> 个人称号

	@Override
	public void _reset_unsafe_() {
		titlename = "";
		jiebaiinfo.clear();
	}

	jiebaiAskInfo(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		titlename = "";
		jiebaiinfo = new java.util.HashMap<Long, String>();
	}

	public jiebaiAskInfo() {
		this(0, null, null);
	}

	public jiebaiAskInfo(jiebaiAskInfo _o_) {
		this(_o_, null, null);
	}

	jiebaiAskInfo(xbean.jiebaiAskInfo _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof jiebaiAskInfo) assign((jiebaiAskInfo)_o1_);
		else if (_o1_ instanceof jiebaiAskInfo.Data) assign((jiebaiAskInfo.Data)_o1_);
		else if (_o1_ instanceof jiebaiAskInfo.Const) assign(((jiebaiAskInfo.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(jiebaiAskInfo _o_) {
		_o_._xdb_verify_unsafe_();
		titlename = _o_.titlename;
		jiebaiinfo = new java.util.HashMap<Long, String>();
		for (java.util.Map.Entry<Long, String> _e_ : _o_.jiebaiinfo.entrySet())
			jiebaiinfo.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(jiebaiAskInfo.Data _o_) {
		titlename = _o_.titlename;
		jiebaiinfo = new java.util.HashMap<Long, String>();
		for (java.util.Map.Entry<Long, String> _e_ : _o_.jiebaiinfo.entrySet())
			jiebaiinfo.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(titlename, mkdb.Const.IO_CHARSET);
		_os_.compact_uint32(jiebaiinfo.size());
		for (java.util.Map.Entry<Long, String> _e_ : jiebaiinfo.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue(), mkdb.Const.IO_CHARSET);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		titlename = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				jiebaiinfo = new java.util.HashMap<Long, String>(size * 2);
			}
			for (; size > 0; --size)
			{
				long _k_ = 0;
				_k_ = _os_.unmarshal_long();
				String _v_ = "";
				_v_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
				jiebaiinfo.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.jiebaiAskInfo copy() {
		_xdb_verify_unsafe_();
		return new jiebaiAskInfo(this);
	}

	@Override
	public xbean.jiebaiAskInfo toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.jiebaiAskInfo toBean() {
		_xdb_verify_unsafe_();
		return new jiebaiAskInfo(this); // same as copy()
	}

	@Override
	public xbean.jiebaiAskInfo toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.jiebaiAskInfo toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public String getTitlename() { // 结拜称号名称
		_xdb_verify_unsafe_();
		return titlename;
	}

	@Override
	public com.locojoy.base.Octets getTitlenameOctets() { // 结拜称号名称
		_xdb_verify_unsafe_();
		return com.locojoy.base.Octets.wrap(getTitlename(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public java.util.Map<Long, String> getJiebaiinfo() { // 角色ID -> 个人称号
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "jiebaiinfo"), jiebaiinfo);
	}

	@Override
	public java.util.Map<Long, String> getJiebaiinfoAsData() { // 角色ID -> 个人称号
		_xdb_verify_unsafe_();
		java.util.Map<Long, String> jiebaiinfo;
		jiebaiAskInfo _o_ = this;
		jiebaiinfo = new java.util.HashMap<Long, String>();
		for (java.util.Map.Entry<Long, String> _e_ : _o_.jiebaiinfo.entrySet())
			jiebaiinfo.put(_e_.getKey(), _e_.getValue());
		return jiebaiinfo;
	}

	@Override
	public void setTitlename(String _v_) { // 结拜称号名称
		_xdb_verify_unsafe_();
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "titlename") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, titlename) {
					public void rollback() { titlename = _xdb_saved; }
				};}});
		titlename = _v_;
	}

	@Override
	public void setTitlenameOctets(com.locojoy.base.Octets _v_) { // 结拜称号名称
		_xdb_verify_unsafe_();
		this.setTitlename(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		jiebaiAskInfo _o_ = null;
		if ( _o1_ instanceof jiebaiAskInfo ) _o_ = (jiebaiAskInfo)_o1_;
		else if ( _o1_ instanceof jiebaiAskInfo.Const ) _o_ = ((jiebaiAskInfo.Const)_o1_).nThis();
		else return false;
		if (!titlename.equals(_o_.titlename)) return false;
		if (!jiebaiinfo.equals(_o_.jiebaiinfo)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += titlename.hashCode();
		_h_ += jiebaiinfo.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append("'").append(titlename).append("'");
		_sb_.append(",");
		_sb_.append(jiebaiinfo);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("titlename"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("jiebaiinfo"));
		return lb;
	}

	private class Const implements xbean.jiebaiAskInfo {
		jiebaiAskInfo nThis() {
			return jiebaiAskInfo.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.jiebaiAskInfo copy() {
			return jiebaiAskInfo.this.copy();
		}

		@Override
		public xbean.jiebaiAskInfo toData() {
			return jiebaiAskInfo.this.toData();
		}

		public xbean.jiebaiAskInfo toBean() {
			return jiebaiAskInfo.this.toBean();
		}

		@Override
		public xbean.jiebaiAskInfo toDataIf() {
			return jiebaiAskInfo.this.toDataIf();
		}

		public xbean.jiebaiAskInfo toBeanIf() {
			return jiebaiAskInfo.this.toBeanIf();
		}

		@Override
		public String getTitlename() { // 结拜称号名称
			_xdb_verify_unsafe_();
			return titlename;
		}

		@Override
		public com.locojoy.base.Octets getTitlenameOctets() { // 结拜称号名称
			_xdb_verify_unsafe_();
			return jiebaiAskInfo.this.getTitlenameOctets();
		}

		@Override
		public java.util.Map<Long, String> getJiebaiinfo() { // 角色ID -> 个人称号
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(jiebaiinfo);
		}

		@Override
		public java.util.Map<Long, String> getJiebaiinfoAsData() { // 角色ID -> 个人称号
			_xdb_verify_unsafe_();
			java.util.Map<Long, String> jiebaiinfo;
			jiebaiAskInfo _o_ = jiebaiAskInfo.this;
			jiebaiinfo = new java.util.HashMap<Long, String>();
			for (java.util.Map.Entry<Long, String> _e_ : _o_.jiebaiinfo.entrySet())
				jiebaiinfo.put(_e_.getKey(), _e_.getValue());
			return jiebaiinfo;
		}

		@Override
		public void setTitlename(String _v_) { // 结拜称号名称
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setTitlenameOctets(com.locojoy.base.Octets _v_) { // 结拜称号名称
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
			return jiebaiAskInfo.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return jiebaiAskInfo.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return jiebaiAskInfo.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return jiebaiAskInfo.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return jiebaiAskInfo.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return jiebaiAskInfo.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return jiebaiAskInfo.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return jiebaiAskInfo.this.hashCode();
		}

		@Override
		public String toString() {
			return jiebaiAskInfo.this.toString();
		}

	}

	public static final class Data implements xbean.jiebaiAskInfo {
		private String titlename; // 结拜称号名称
		private java.util.HashMap<Long, String> jiebaiinfo; // 角色ID -> 个人称号

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			titlename = "";
			jiebaiinfo = new java.util.HashMap<Long, String>();
		}

		Data(xbean.jiebaiAskInfo _o1_) {
			if (_o1_ instanceof jiebaiAskInfo) assign((jiebaiAskInfo)_o1_);
			else if (_o1_ instanceof jiebaiAskInfo.Data) assign((jiebaiAskInfo.Data)_o1_);
			else if (_o1_ instanceof jiebaiAskInfo.Const) assign(((jiebaiAskInfo.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(jiebaiAskInfo _o_) {
			titlename = _o_.titlename;
			jiebaiinfo = new java.util.HashMap<Long, String>();
			for (java.util.Map.Entry<Long, String> _e_ : _o_.jiebaiinfo.entrySet())
				jiebaiinfo.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(jiebaiAskInfo.Data _o_) {
			titlename = _o_.titlename;
			jiebaiinfo = new java.util.HashMap<Long, String>();
			for (java.util.Map.Entry<Long, String> _e_ : _o_.jiebaiinfo.entrySet())
				jiebaiinfo.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(titlename, mkdb.Const.IO_CHARSET);
			_os_.compact_uint32(jiebaiinfo.size());
			for (java.util.Map.Entry<Long, String> _e_ : jiebaiinfo.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue(), mkdb.Const.IO_CHARSET);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			titlename = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					jiebaiinfo = new java.util.HashMap<Long, String>(size * 2);
				}
				for (; size > 0; --size)
				{
					long _k_ = 0;
					_k_ = _os_.unmarshal_long();
					String _v_ = "";
					_v_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
					jiebaiinfo.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.jiebaiAskInfo copy() {
			return new Data(this);
		}

		@Override
		public xbean.jiebaiAskInfo toData() {
			return new Data(this);
		}

		public xbean.jiebaiAskInfo toBean() {
			return new jiebaiAskInfo(this, null, null);
		}

		@Override
		public xbean.jiebaiAskInfo toDataIf() {
			return this;
		}

		public xbean.jiebaiAskInfo toBeanIf() {
			return new jiebaiAskInfo(this, null, null);
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
		public String getTitlename() { // 结拜称号名称
			return titlename;
		}

		@Override
		public com.locojoy.base.Octets getTitlenameOctets() { // 结拜称号名称
			return com.locojoy.base.Octets.wrap(getTitlename(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public java.util.Map<Long, String> getJiebaiinfo() { // 角色ID -> 个人称号
			return jiebaiinfo;
		}

		@Override
		public java.util.Map<Long, String> getJiebaiinfoAsData() { // 角色ID -> 个人称号
			return jiebaiinfo;
		}

		@Override
		public void setTitlename(String _v_) { // 结拜称号名称
			if (null == _v_)
				throw new NullPointerException();
			titlename = _v_;
		}

		@Override
		public void setTitlenameOctets(com.locojoy.base.Octets _v_) { // 结拜称号名称
			this.setTitlename(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof jiebaiAskInfo.Data)) return false;
			jiebaiAskInfo.Data _o_ = (jiebaiAskInfo.Data) _o1_;
			if (!titlename.equals(_o_.titlename)) return false;
			if (!jiebaiinfo.equals(_o_.jiebaiinfo)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += titlename.hashCode();
			_h_ += jiebaiinfo.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append("'").append(titlename).append("'");
			_sb_.append(",");
			_sb_.append(jiebaiinfo);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
