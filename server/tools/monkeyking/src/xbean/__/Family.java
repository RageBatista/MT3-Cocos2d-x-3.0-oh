
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Family extends mkdb.XBean implements xbean.Family {
	private int id; // 
	private int level; // 
	private int contribution; // 
	private int leaderid; // 
	private int creatorid; // 
	private String name; // 
	private String aim; // 
	private String pub; // 
	private java.util.HashMap<Integer, xbean.MemberInfo> memebers; // 
	private int status; // 
	private long create_time; // 
	private int well_known; // 

	@Override
	public void _reset_unsafe_() {
		id = 0;
		level = 0;
		contribution = 0;
		leaderid = 0;
		creatorid = 0;
		name = "";
		aim = "";
		pub = "";
		memebers.clear();
		status = 0;
		create_time = 0L;
		well_known = 0;
	}

	Family(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		name = "";
		aim = "";
		pub = "";
		memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
	}

	public Family() {
		this(0, null, null);
	}

	public Family(Family _o_) {
		this(_o_, null, null);
	}

	Family(xbean.Family _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Family) assign((Family)_o1_);
		else if (_o1_ instanceof Family.Data) assign((Family.Data)_o1_);
		else if (_o1_ instanceof Family.Const) assign(((Family.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Family _o_) {
		id = _o_.id;
		level = _o_.level;
		contribution = _o_.contribution;
		leaderid = _o_.leaderid;
		creatorid = _o_.creatorid;
		name = _o_.name;
		aim = _o_.aim;
		pub = _o_.pub;
		memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
		for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.memebers.entrySet())
			memebers.put(_e_.getKey(), new MemberInfo(_e_.getValue(), this, "memebers"));
		status = _o_.status;
		create_time = _o_.create_time;
		well_known = _o_.well_known;
	}

	private void assign(Family.Data _o_) {
		id = _o_.id;
		level = _o_.level;
		contribution = _o_.contribution;
		leaderid = _o_.leaderid;
		creatorid = _o_.creatorid;
		name = _o_.name;
		aim = _o_.aim;
		pub = _o_.pub;
		memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
		for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.memebers.entrySet())
			memebers.put(_e_.getKey(), new MemberInfo(_e_.getValue(), this, "memebers"));
		status = _o_.status;
		create_time = _o_.create_time;
		well_known = _o_.well_known;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		_os_.marshal(level);
		_os_.marshal(contribution);
		_os_.marshal(leaderid);
		_os_.marshal(creatorid);
		_os_.marshal(name, mkdb.Const.IO_CHARSET);
		_os_.marshal(aim, mkdb.Const.IO_CHARSET);
		_os_.marshal(pub, mkdb.Const.IO_CHARSET);
		_os_.compact_uint32(memebers.size());
		for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : memebers.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		_os_.marshal(status);
		_os_.marshal(create_time);
		_os_.marshal(well_known);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		level = _os_.unmarshal_int();
		contribution = _os_.unmarshal_int();
		leaderid = _os_.unmarshal_int();
		creatorid = _os_.unmarshal_int();
		name = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		aim = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		pub = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				memebers = new java.util.HashMap<Integer, xbean.MemberInfo>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.MemberInfo _v_ = new MemberInfo(0, this, "memebers");
				_v_.unmarshal(_os_);
				memebers.put(_k_, _v_);
			}
		}
		status = _os_.unmarshal_int();
		create_time = _os_.unmarshal_long();
		well_known = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.Family copy() {
		return new Family(this);
	}

	@Override
	public xbean.Family toData() {
		return new Data(this);
	}

	public xbean.Family toBean() {
		return new Family(this); // same as copy()
	}

	@Override
	public xbean.Family toDataIf() {
		return new Data(this);
	}

	public xbean.Family toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // 
		return id;
	}

	@Override
	public int getLevel() { // 
		return level;
	}

	@Override
	public int getContribution() { // 
		return contribution;
	}

	@Override
	public int getLeaderid() { // 
		return leaderid;
	}

	@Override
	public int getCreatorid() { // 
		return creatorid;
	}

	@Override
	public String getName() { // 
		return name;
	}

	@Override
	public com.locojoy.base.Octets getNameOctets() { // 
		return com.locojoy.base.Octets.wrap(getName(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public String getAim() { // 
		return aim;
	}

	@Override
	public com.locojoy.base.Octets getAimOctets() { // 
		return com.locojoy.base.Octets.wrap(getAim(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public String getPub() { // 
		return pub;
	}

	@Override
	public com.locojoy.base.Octets getPubOctets() { // 
		return com.locojoy.base.Octets.wrap(getPub(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public java.util.Map<Integer, xbean.MemberInfo> getMemebers() { // 
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "memebers"), memebers);
	}

	@Override
	public java.util.Map<Integer, xbean.MemberInfo> getMemebersAsData() { // 
		java.util.Map<Integer, xbean.MemberInfo> memebers;
		Family _o_ = this;
		memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
		for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.memebers.entrySet())
			memebers.put(_e_.getKey(), new MemberInfo.Data(_e_.getValue()));
		return memebers;
	}

	@Override
	public int getStatus() { // 
		return status;
	}

	@Override
	public long getCreate_time() { // 
		return create_time;
	}

	@Override
	public int getWell_known() { // 
		return well_known;
	}

	@Override
	public void setId(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setLevel(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "level") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, level) {
					public void rollback() { level = _xdb_saved; }
				};}});
		level = _v_;
	}

	@Override
	public void setContribution(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "contribution") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, contribution) {
					public void rollback() { contribution = _xdb_saved; }
				};}});
		contribution = _v_;
	}

	@Override
	public void setLeaderid(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "leaderid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, leaderid) {
					public void rollback() { leaderid = _xdb_saved; }
				};}});
		leaderid = _v_;
	}

	@Override
	public void setCreatorid(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "creatorid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, creatorid) {
					public void rollback() { creatorid = _xdb_saved; }
				};}});
		creatorid = _v_;
	}

	@Override
	public void setName(String _v_) { // 
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "name") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, name) {
					public void rollback() { name = _xdb_saved; }
				};}});
		name = _v_;
	}

	@Override
	public void setNameOctets(com.locojoy.base.Octets _v_) { // 
		this.setName(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setAim(String _v_) { // 
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "aim") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, aim) {
					public void rollback() { aim = _xdb_saved; }
				};}});
		aim = _v_;
	}

	@Override
	public void setAimOctets(com.locojoy.base.Octets _v_) { // 
		this.setAim(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setPub(String _v_) { // 
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "pub") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, pub) {
					public void rollback() { pub = _xdb_saved; }
				};}});
		pub = _v_;
	}

	@Override
	public void setPubOctets(com.locojoy.base.Octets _v_) { // 
		this.setPub(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setStatus(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "status") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, status) {
					public void rollback() { status = _xdb_saved; }
				};}});
		status = _v_;
	}

	@Override
	public void setCreate_time(long _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "create_time") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, create_time) {
					public void rollback() { create_time = _xdb_saved; }
				};}});
		create_time = _v_;
	}

	@Override
	public void setWell_known(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "well_known") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, well_known) {
					public void rollback() { well_known = _xdb_saved; }
				};}});
		well_known = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		Family _o_ = null;
		if ( _o1_ instanceof Family ) _o_ = (Family)_o1_;
		else if ( _o1_ instanceof Family.Const ) _o_ = ((Family.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (level != _o_.level) return false;
		if (contribution != _o_.contribution) return false;
		if (leaderid != _o_.leaderid) return false;
		if (creatorid != _o_.creatorid) return false;
		if (!name.equals(_o_.name)) return false;
		if (!aim.equals(_o_.aim)) return false;
		if (!pub.equals(_o_.pub)) return false;
		if (!memebers.equals(_o_.memebers)) return false;
		if (status != _o_.status) return false;
		if (create_time != _o_.create_time) return false;
		if (well_known != _o_.well_known) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		_h_ += level;
		_h_ += contribution;
		_h_ += leaderid;
		_h_ += creatorid;
		_h_ += name.hashCode();
		_h_ += aim.hashCode();
		_h_ += pub.hashCode();
		_h_ += memebers.hashCode();
		_h_ += status;
		_h_ += create_time;
		_h_ += well_known;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(level);
		_sb_.append(",");
		_sb_.append(contribution);
		_sb_.append(",");
		_sb_.append(leaderid);
		_sb_.append(",");
		_sb_.append(creatorid);
		_sb_.append(",");
		_sb_.append("'").append(name).append("'");
		_sb_.append(",");
		_sb_.append("'").append(aim).append("'");
		_sb_.append(",");
		_sb_.append("'").append(pub).append("'");
		_sb_.append(",");
		_sb_.append(memebers);
		_sb_.append(",");
		_sb_.append(status);
		_sb_.append(",");
		_sb_.append(create_time);
		_sb_.append(",");
		_sb_.append(well_known);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("level"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("contribution"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("leaderid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("creatorid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("name"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("aim"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("pub"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("memebers"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("status"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("create_time"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("well_known"));
		return lb;
	}

	private class Const implements xbean.Family {
		Family nThis() {
			return Family.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Family copy() {
			return Family.this.copy();
		}

		@Override
		public xbean.Family toData() {
			return Family.this.toData();
		}

		public xbean.Family toBean() {
			return Family.this.toBean();
		}

		@Override
		public xbean.Family toDataIf() {
			return Family.this.toDataIf();
		}

		public xbean.Family toBeanIf() {
			return Family.this.toBeanIf();
		}

		@Override
		public int getId() { // 
			return id;
		}

		@Override
		public int getLevel() { // 
			return level;
		}

		@Override
		public int getContribution() { // 
			return contribution;
		}

		@Override
		public int getLeaderid() { // 
			return leaderid;
		}

		@Override
		public int getCreatorid() { // 
			return creatorid;
		}

		@Override
		public String getName() { // 
			return name;
		}

		@Override
		public com.locojoy.base.Octets getNameOctets() { // 
			return Family.this.getNameOctets();
		}

		@Override
		public String getAim() { // 
			return aim;
		}

		@Override
		public com.locojoy.base.Octets getAimOctets() { // 
			return Family.this.getAimOctets();
		}

		@Override
		public String getPub() { // 
			return pub;
		}

		@Override
		public com.locojoy.base.Octets getPubOctets() { // 
			return Family.this.getPubOctets();
		}

		@Override
		public java.util.Map<Integer, xbean.MemberInfo> getMemebers() { // 
			return mkdb.Consts.constMap(memebers);
		}

		@Override
		public java.util.Map<Integer, xbean.MemberInfo> getMemebersAsData() { // 
			java.util.Map<Integer, xbean.MemberInfo> memebers;
			Family _o_ = Family.this;
			memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
			for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.memebers.entrySet())
				memebers.put(_e_.getKey(), new MemberInfo.Data(_e_.getValue()));
			return memebers;
		}

		@Override
		public int getStatus() { // 
			return status;
		}

		@Override
		public long getCreate_time() { // 
			return create_time;
		}

		@Override
		public int getWell_known() { // 
			return well_known;
		}

		@Override
		public void setId(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLevel(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setContribution(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLeaderid(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setCreatorid(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setName(String _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setNameOctets(com.locojoy.base.Octets _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setAim(String _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setAimOctets(com.locojoy.base.Octets _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPub(String _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPubOctets(com.locojoy.base.Octets _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setStatus(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setCreate_time(long _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setWell_known(int _v_) { // 
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
			return Family.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Family.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Family.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Family.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Family.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Family.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Family.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Family.this.hashCode();
		}

		@Override
		public String toString() {
			return Family.this.toString();
		}

	}

	public static final class Data implements xbean.Family {
		private int id; // 
		private int level; // 
		private int contribution; // 
		private int leaderid; // 
		private int creatorid; // 
		private String name; // 
		private String aim; // 
		private String pub; // 
		private java.util.HashMap<Integer, xbean.MemberInfo> memebers; // 
		private int status; // 
		private long create_time; // 
		private int well_known; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			name = "";
			aim = "";
			pub = "";
			memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
		}

		Data(xbean.Family _o1_) {
			if (_o1_ instanceof Family) assign((Family)_o1_);
			else if (_o1_ instanceof Family.Data) assign((Family.Data)_o1_);
			else if (_o1_ instanceof Family.Const) assign(((Family.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Family _o_) {
			id = _o_.id;
			level = _o_.level;
			contribution = _o_.contribution;
			leaderid = _o_.leaderid;
			creatorid = _o_.creatorid;
			name = _o_.name;
			aim = _o_.aim;
			pub = _o_.pub;
			memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
			for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.memebers.entrySet())
				memebers.put(_e_.getKey(), new MemberInfo.Data(_e_.getValue()));
			status = _o_.status;
			create_time = _o_.create_time;
			well_known = _o_.well_known;
		}

		private void assign(Family.Data _o_) {
			id = _o_.id;
			level = _o_.level;
			contribution = _o_.contribution;
			leaderid = _o_.leaderid;
			creatorid = _o_.creatorid;
			name = _o_.name;
			aim = _o_.aim;
			pub = _o_.pub;
			memebers = new java.util.HashMap<Integer, xbean.MemberInfo>();
			for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.memebers.entrySet())
				memebers.put(_e_.getKey(), new MemberInfo.Data(_e_.getValue()));
			status = _o_.status;
			create_time = _o_.create_time;
			well_known = _o_.well_known;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(level);
			_os_.marshal(contribution);
			_os_.marshal(leaderid);
			_os_.marshal(creatorid);
			_os_.marshal(name, mkdb.Const.IO_CHARSET);
			_os_.marshal(aim, mkdb.Const.IO_CHARSET);
			_os_.marshal(pub, mkdb.Const.IO_CHARSET);
			_os_.compact_uint32(memebers.size());
			for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : memebers.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			_os_.marshal(status);
			_os_.marshal(create_time);
			_os_.marshal(well_known);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			level = _os_.unmarshal_int();
			contribution = _os_.unmarshal_int();
			leaderid = _os_.unmarshal_int();
			creatorid = _os_.unmarshal_int();
			name = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			aim = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			pub = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					memebers = new java.util.HashMap<Integer, xbean.MemberInfo>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.MemberInfo _v_ = xbean.Pod.newMemberInfoData();
					_v_.unmarshal(_os_);
					memebers.put(_k_, _v_);
				}
			}
			status = _os_.unmarshal_int();
			create_time = _os_.unmarshal_long();
			well_known = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.Family copy() {
			return new Data(this);
		}

		@Override
		public xbean.Family toData() {
			return new Data(this);
		}

		public xbean.Family toBean() {
			return new Family(this, null, null);
		}

		@Override
		public xbean.Family toDataIf() {
			return this;
		}

		public xbean.Family toBeanIf() {
			return new Family(this, null, null);
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
		public int getId() { // 
			return id;
		}

		@Override
		public int getLevel() { // 
			return level;
		}

		@Override
		public int getContribution() { // 
			return contribution;
		}

		@Override
		public int getLeaderid() { // 
			return leaderid;
		}

		@Override
		public int getCreatorid() { // 
			return creatorid;
		}

		@Override
		public String getName() { // 
			return name;
		}

		@Override
		public com.locojoy.base.Octets getNameOctets() { // 
			return com.locojoy.base.Octets.wrap(getName(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public String getAim() { // 
			return aim;
		}

		@Override
		public com.locojoy.base.Octets getAimOctets() { // 
			return com.locojoy.base.Octets.wrap(getAim(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public String getPub() { // 
			return pub;
		}

		@Override
		public com.locojoy.base.Octets getPubOctets() { // 
			return com.locojoy.base.Octets.wrap(getPub(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public java.util.Map<Integer, xbean.MemberInfo> getMemebers() { // 
			return memebers;
		}

		@Override
		public java.util.Map<Integer, xbean.MemberInfo> getMemebersAsData() { // 
			return memebers;
		}

		@Override
		public int getStatus() { // 
			return status;
		}

		@Override
		public long getCreate_time() { // 
			return create_time;
		}

		@Override
		public int getWell_known() { // 
			return well_known;
		}

		@Override
		public void setId(int _v_) { // 
			id = _v_;
		}

		@Override
		public void setLevel(int _v_) { // 
			level = _v_;
		}

		@Override
		public void setContribution(int _v_) { // 
			contribution = _v_;
		}

		@Override
		public void setLeaderid(int _v_) { // 
			leaderid = _v_;
		}

		@Override
		public void setCreatorid(int _v_) { // 
			creatorid = _v_;
		}

		@Override
		public void setName(String _v_) { // 
			if (null == _v_)
				throw new NullPointerException();
			name = _v_;
		}

		@Override
		public void setNameOctets(com.locojoy.base.Octets _v_) { // 
			this.setName(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setAim(String _v_) { // 
			if (null == _v_)
				throw new NullPointerException();
			aim = _v_;
		}

		@Override
		public void setAimOctets(com.locojoy.base.Octets _v_) { // 
			this.setAim(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setPub(String _v_) { // 
			if (null == _v_)
				throw new NullPointerException();
			pub = _v_;
		}

		@Override
		public void setPubOctets(com.locojoy.base.Octets _v_) { // 
			this.setPub(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setStatus(int _v_) { // 
			status = _v_;
		}

		@Override
		public void setCreate_time(long _v_) { // 
			create_time = _v_;
		}

		@Override
		public void setWell_known(int _v_) { // 
			well_known = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Family.Data)) return false;
			Family.Data _o_ = (Family.Data) _o1_;
			if (id != _o_.id) return false;
			if (level != _o_.level) return false;
			if (contribution != _o_.contribution) return false;
			if (leaderid != _o_.leaderid) return false;
			if (creatorid != _o_.creatorid) return false;
			if (!name.equals(_o_.name)) return false;
			if (!aim.equals(_o_.aim)) return false;
			if (!pub.equals(_o_.pub)) return false;
			if (!memebers.equals(_o_.memebers)) return false;
			if (status != _o_.status) return false;
			if (create_time != _o_.create_time) return false;
			if (well_known != _o_.well_known) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += level;
			_h_ += contribution;
			_h_ += leaderid;
			_h_ += creatorid;
			_h_ += name.hashCode();
			_h_ += aim.hashCode();
			_h_ += pub.hashCode();
			_h_ += memebers.hashCode();
			_h_ += status;
			_h_ += create_time;
			_h_ += well_known;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(level);
			_sb_.append(",");
			_sb_.append(contribution);
			_sb_.append(",");
			_sb_.append(leaderid);
			_sb_.append(",");
			_sb_.append(creatorid);
			_sb_.append(",");
			_sb_.append("'").append(name).append("'");
			_sb_.append(",");
			_sb_.append("'").append(aim).append("'");
			_sb_.append(",");
			_sb_.append("'").append(pub).append("'");
			_sb_.append(",");
			_sb_.append(memebers);
			_sb_.append(",");
			_sb_.append(status);
			_sb_.append(",");
			_sb_.append(create_time);
			_sb_.append(",");
			_sb_.append(well_known);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
