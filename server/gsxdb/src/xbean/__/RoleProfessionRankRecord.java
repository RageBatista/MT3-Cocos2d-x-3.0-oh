
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class RoleProfessionRankRecord extends mkdb.XBean implements xbean.RoleProfessionRankRecord {
	private int rank; // 排名
	private long roleid; // 人物ID
	private String rolename; // 人物名称
	private int school; // 职业
	private int level; // 等级
	private int score; // 总评分
	private String clanname; // 帮会，作者 changhao
	private long triggertime; // 触发时间，作者 changhao
	private int shape; // 角色造型
	private int color1; // 颜色1
	private int color2; // 颜色2
	private java.util.HashMap<Integer, Integer> components; // 装备部件

	@Override
	public void _reset_unsafe_() {
		rank = 0;
		roleid = 0L;
		rolename = "";
		school = 0;
		level = 0;
		score = 0;
		clanname = "";
		triggertime = 0L;
		shape = 0;
		color1 = 0;
		color2 = 0;
		components.clear();
	}

	RoleProfessionRankRecord(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		rolename = "";
		clanname = "";
		components = new java.util.HashMap<Integer, Integer>();
	}

	public RoleProfessionRankRecord() {
		this(0, null, null);
	}

	public RoleProfessionRankRecord(RoleProfessionRankRecord _o_) {
		this(_o_, null, null);
	}

	RoleProfessionRankRecord(xbean.RoleProfessionRankRecord _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof RoleProfessionRankRecord) assign((RoleProfessionRankRecord)_o1_);
		else if (_o1_ instanceof RoleProfessionRankRecord.Data) assign((RoleProfessionRankRecord.Data)_o1_);
		else if (_o1_ instanceof RoleProfessionRankRecord.Const) assign(((RoleProfessionRankRecord.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(RoleProfessionRankRecord _o_) {
		_o_._xdb_verify_unsafe_();
		rank = _o_.rank;
		roleid = _o_.roleid;
		rolename = _o_.rolename;
		school = _o_.school;
		level = _o_.level;
		score = _o_.score;
		clanname = _o_.clanname;
		triggertime = _o_.triggertime;
		shape = _o_.shape;
		color1 = _o_.color1;
		color2 = _o_.color2;
		components = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.components.entrySet())
			components.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(RoleProfessionRankRecord.Data _o_) {
		rank = _o_.rank;
		roleid = _o_.roleid;
		rolename = _o_.rolename;
		school = _o_.school;
		level = _o_.level;
		score = _o_.score;
		clanname = _o_.clanname;
		triggertime = _o_.triggertime;
		shape = _o_.shape;
		color1 = _o_.color1;
		color2 = _o_.color2;
		components = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.components.entrySet())
			components.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(rank);
		_os_.marshal(roleid);
		_os_.marshal(rolename, mkdb.Const.IO_CHARSET);
		_os_.marshal(school);
		_os_.marshal(level);
		_os_.marshal(score);
		_os_.marshal(clanname, mkdb.Const.IO_CHARSET);
		_os_.marshal(triggertime);
		_os_.marshal(shape);
		_os_.marshal(color1);
		_os_.marshal(color2);
		_os_.compact_uint32(components.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : components.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		rank = _os_.unmarshal_int();
		roleid = _os_.unmarshal_long();
		rolename = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		school = _os_.unmarshal_int();
		level = _os_.unmarshal_int();
		score = _os_.unmarshal_int();
		clanname = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		triggertime = _os_.unmarshal_long();
		shape = _os_.unmarshal_int();
		color1 = _os_.unmarshal_int();
		color2 = _os_.unmarshal_int();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				components = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				components.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.RoleProfessionRankRecord copy() {
		_xdb_verify_unsafe_();
		return new RoleProfessionRankRecord(this);
	}

	@Override
	public xbean.RoleProfessionRankRecord toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.RoleProfessionRankRecord toBean() {
		_xdb_verify_unsafe_();
		return new RoleProfessionRankRecord(this); // same as copy()
	}

	@Override
	public xbean.RoleProfessionRankRecord toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.RoleProfessionRankRecord toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public int getRank() { // 排名
		_xdb_verify_unsafe_();
		return rank;
	}

	@Override
	public long getRoleid() { // 人物ID
		_xdb_verify_unsafe_();
		return roleid;
	}

	@Override
	public String getRolename() { // 人物名称
		_xdb_verify_unsafe_();
		return rolename;
	}

	@Override
	public com.locojoy.base.Octets getRolenameOctets() { // 人物名称
		_xdb_verify_unsafe_();
		return com.locojoy.base.Octets.wrap(getRolename(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public int getSchool() { // 职业
		_xdb_verify_unsafe_();
		return school;
	}

	@Override
	public int getLevel() { // 等级
		_xdb_verify_unsafe_();
		return level;
	}

	@Override
	public int getScore() { // 总评分
		_xdb_verify_unsafe_();
		return score;
	}

	@Override
	public String getClanname() { // 帮会，作者 changhao
		_xdb_verify_unsafe_();
		return clanname;
	}

	@Override
	public com.locojoy.base.Octets getClannameOctets() { // 帮会，作者 changhao
		_xdb_verify_unsafe_();
		return com.locojoy.base.Octets.wrap(getClanname(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public long getTriggertime() { // 触发时间，作者 changhao
		_xdb_verify_unsafe_();
		return triggertime;
	}

	@Override
	public int getShape() { // 角色造型
		_xdb_verify_unsafe_();
		return shape;
	}

	@Override
	public int getColor1() { // 颜色1
		_xdb_verify_unsafe_();
		return color1;
	}

	@Override
	public int getColor2() { // 颜色2
		_xdb_verify_unsafe_();
		return color2;
	}

	@Override
	public java.util.Map<Integer, Integer> getComponents() { // 装备部件
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "components"), components);
	}

	@Override
	public java.util.Map<Integer, Integer> getComponentsAsData() { // 装备部件
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Integer> components;
		RoleProfessionRankRecord _o_ = this;
		components = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.components.entrySet())
			components.put(_e_.getKey(), _e_.getValue());
		return components;
	}

	@Override
	public void setRank(int _v_) { // 排名
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "rank") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, rank) {
					public void rollback() { rank = _xdb_saved; }
				};}});
		rank = _v_;
	}

	@Override
	public void setRoleid(long _v_) { // 人物ID
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "roleid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, roleid) {
					public void rollback() { roleid = _xdb_saved; }
				};}});
		roleid = _v_;
	}

	@Override
	public void setRolename(String _v_) { // 人物名称
		_xdb_verify_unsafe_();
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "rolename") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, rolename) {
					public void rollback() { rolename = _xdb_saved; }
				};}});
		rolename = _v_;
	}

	@Override
	public void setRolenameOctets(com.locojoy.base.Octets _v_) { // 人物名称
		_xdb_verify_unsafe_();
		this.setRolename(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setSchool(int _v_) { // 职业
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "school") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, school) {
					public void rollback() { school = _xdb_saved; }
				};}});
		school = _v_;
	}

	@Override
	public void setLevel(int _v_) { // 等级
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "level") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, level) {
					public void rollback() { level = _xdb_saved; }
				};}});
		level = _v_;
	}

	@Override
	public void setScore(int _v_) { // 总评分
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "score") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, score) {
					public void rollback() { score = _xdb_saved; }
				};}});
		score = _v_;
	}

	@Override
	public void setClanname(String _v_) { // 帮会，作者 changhao
		_xdb_verify_unsafe_();
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "clanname") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, clanname) {
					public void rollback() { clanname = _xdb_saved; }
				};}});
		clanname = _v_;
	}

	@Override
	public void setClannameOctets(com.locojoy.base.Octets _v_) { // 帮会，作者 changhao
		_xdb_verify_unsafe_();
		this.setClanname(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setTriggertime(long _v_) { // 触发时间，作者 changhao
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "triggertime") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, triggertime) {
					public void rollback() { triggertime = _xdb_saved; }
				};}});
		triggertime = _v_;
	}

	@Override
	public void setShape(int _v_) { // 角色造型
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "shape") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, shape) {
					public void rollback() { shape = _xdb_saved; }
				};}});
		shape = _v_;
	}

	@Override
	public void setColor1(int _v_) { // 颜色1
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "color1") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, color1) {
					public void rollback() { color1 = _xdb_saved; }
				};}});
		color1 = _v_;
	}

	@Override
	public void setColor2(int _v_) { // 颜色2
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "color2") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, color2) {
					public void rollback() { color2 = _xdb_saved; }
				};}});
		color2 = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		RoleProfessionRankRecord _o_ = null;
		if ( _o1_ instanceof RoleProfessionRankRecord ) _o_ = (RoleProfessionRankRecord)_o1_;
		else if ( _o1_ instanceof RoleProfessionRankRecord.Const ) _o_ = ((RoleProfessionRankRecord.Const)_o1_).nThis();
		else return false;
		if (rank != _o_.rank) return false;
		if (roleid != _o_.roleid) return false;
		if (!rolename.equals(_o_.rolename)) return false;
		if (school != _o_.school) return false;
		if (level != _o_.level) return false;
		if (score != _o_.score) return false;
		if (!clanname.equals(_o_.clanname)) return false;
		if (triggertime != _o_.triggertime) return false;
		if (shape != _o_.shape) return false;
		if (color1 != _o_.color1) return false;
		if (color2 != _o_.color2) return false;
		if (!components.equals(_o_.components)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += rank;
		_h_ += roleid;
		_h_ += rolename.hashCode();
		_h_ += school;
		_h_ += level;
		_h_ += score;
		_h_ += clanname.hashCode();
		_h_ += triggertime;
		_h_ += shape;
		_h_ += color1;
		_h_ += color2;
		_h_ += components.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(rank);
		_sb_.append(",");
		_sb_.append(roleid);
		_sb_.append(",");
		_sb_.append("'").append(rolename).append("'");
		_sb_.append(",");
		_sb_.append(school);
		_sb_.append(",");
		_sb_.append(level);
		_sb_.append(",");
		_sb_.append(score);
		_sb_.append(",");
		_sb_.append("'").append(clanname).append("'");
		_sb_.append(",");
		_sb_.append(triggertime);
		_sb_.append(",");
		_sb_.append(shape);
		_sb_.append(",");
		_sb_.append(color1);
		_sb_.append(",");
		_sb_.append(color2);
		_sb_.append(",");
		_sb_.append(components);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("rank"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("roleid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("rolename"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("school"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("level"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("score"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("clanname"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("triggertime"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("shape"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("color1"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("color2"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("components"));
		return lb;
	}

	private class Const implements xbean.RoleProfessionRankRecord {
		RoleProfessionRankRecord nThis() {
			return RoleProfessionRankRecord.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.RoleProfessionRankRecord copy() {
			return RoleProfessionRankRecord.this.copy();
		}

		@Override
		public xbean.RoleProfessionRankRecord toData() {
			return RoleProfessionRankRecord.this.toData();
		}

		public xbean.RoleProfessionRankRecord toBean() {
			return RoleProfessionRankRecord.this.toBean();
		}

		@Override
		public xbean.RoleProfessionRankRecord toDataIf() {
			return RoleProfessionRankRecord.this.toDataIf();
		}

		public xbean.RoleProfessionRankRecord toBeanIf() {
			return RoleProfessionRankRecord.this.toBeanIf();
		}

		@Override
		public int getRank() { // 排名
			_xdb_verify_unsafe_();
			return rank;
		}

		@Override
		public long getRoleid() { // 人物ID
			_xdb_verify_unsafe_();
			return roleid;
		}

		@Override
		public String getRolename() { // 人物名称
			_xdb_verify_unsafe_();
			return rolename;
		}

		@Override
		public com.locojoy.base.Octets getRolenameOctets() { // 人物名称
			_xdb_verify_unsafe_();
			return RoleProfessionRankRecord.this.getRolenameOctets();
		}

		@Override
		public int getSchool() { // 职业
			_xdb_verify_unsafe_();
			return school;
		}

		@Override
		public int getLevel() { // 等级
			_xdb_verify_unsafe_();
			return level;
		}

		@Override
		public int getScore() { // 总评分
			_xdb_verify_unsafe_();
			return score;
		}

		@Override
		public String getClanname() { // 帮会，作者 changhao
			_xdb_verify_unsafe_();
			return clanname;
		}

		@Override
		public com.locojoy.base.Octets getClannameOctets() { // 帮会，作者 changhao
			_xdb_verify_unsafe_();
			return RoleProfessionRankRecord.this.getClannameOctets();
		}

		@Override
		public long getTriggertime() { // 触发时间，作者 changhao
			_xdb_verify_unsafe_();
			return triggertime;
		}

		@Override
		public int getShape() { // 角色造型
			_xdb_verify_unsafe_();
			return shape;
		}

		@Override
		public int getColor1() { // 颜色1
			_xdb_verify_unsafe_();
			return color1;
		}

		@Override
		public int getColor2() { // 颜色2
			_xdb_verify_unsafe_();
			return color2;
		}

		@Override
		public java.util.Map<Integer, Integer> getComponents() { // 装备部件
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(components);
		}

		@Override
		public java.util.Map<Integer, Integer> getComponentsAsData() { // 装备部件
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Integer> components;
			RoleProfessionRankRecord _o_ = RoleProfessionRankRecord.this;
			components = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.components.entrySet())
				components.put(_e_.getKey(), _e_.getValue());
			return components;
		}

		@Override
		public void setRank(int _v_) { // 排名
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setRoleid(long _v_) { // 人物ID
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setRolename(String _v_) { // 人物名称
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setRolenameOctets(com.locojoy.base.Octets _v_) { // 人物名称
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setSchool(int _v_) { // 职业
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLevel(int _v_) { // 等级
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setScore(int _v_) { // 总评分
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setClanname(String _v_) { // 帮会，作者 changhao
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setClannameOctets(com.locojoy.base.Octets _v_) { // 帮会，作者 changhao
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setTriggertime(long _v_) { // 触发时间，作者 changhao
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setShape(int _v_) { // 角色造型
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setColor1(int _v_) { // 颜色1
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setColor2(int _v_) { // 颜色2
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
			return RoleProfessionRankRecord.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return RoleProfessionRankRecord.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return RoleProfessionRankRecord.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return RoleProfessionRankRecord.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return RoleProfessionRankRecord.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return RoleProfessionRankRecord.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return RoleProfessionRankRecord.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return RoleProfessionRankRecord.this.hashCode();
		}

		@Override
		public String toString() {
			return RoleProfessionRankRecord.this.toString();
		}

	}

	public static final class Data implements xbean.RoleProfessionRankRecord {
		private int rank; // 排名
		private long roleid; // 人物ID
		private String rolename; // 人物名称
		private int school; // 职业
		private int level; // 等级
		private int score; // 总评分
		private String clanname; // 帮会，作者 changhao
		private long triggertime; // 触发时间，作者 changhao
		private int shape; // 角色造型
		private int color1; // 颜色1
		private int color2; // 颜色2
		private java.util.HashMap<Integer, Integer> components; // 装备部件

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			rolename = "";
			clanname = "";
			components = new java.util.HashMap<Integer, Integer>();
		}

		Data(xbean.RoleProfessionRankRecord _o1_) {
			if (_o1_ instanceof RoleProfessionRankRecord) assign((RoleProfessionRankRecord)_o1_);
			else if (_o1_ instanceof RoleProfessionRankRecord.Data) assign((RoleProfessionRankRecord.Data)_o1_);
			else if (_o1_ instanceof RoleProfessionRankRecord.Const) assign(((RoleProfessionRankRecord.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(RoleProfessionRankRecord _o_) {
			rank = _o_.rank;
			roleid = _o_.roleid;
			rolename = _o_.rolename;
			school = _o_.school;
			level = _o_.level;
			score = _o_.score;
			clanname = _o_.clanname;
			triggertime = _o_.triggertime;
			shape = _o_.shape;
			color1 = _o_.color1;
			color2 = _o_.color2;
			components = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.components.entrySet())
				components.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(RoleProfessionRankRecord.Data _o_) {
			rank = _o_.rank;
			roleid = _o_.roleid;
			rolename = _o_.rolename;
			school = _o_.school;
			level = _o_.level;
			score = _o_.score;
			clanname = _o_.clanname;
			triggertime = _o_.triggertime;
			shape = _o_.shape;
			color1 = _o_.color1;
			color2 = _o_.color2;
			components = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.components.entrySet())
				components.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(rank);
			_os_.marshal(roleid);
			_os_.marshal(rolename, mkdb.Const.IO_CHARSET);
			_os_.marshal(school);
			_os_.marshal(level);
			_os_.marshal(score);
			_os_.marshal(clanname, mkdb.Const.IO_CHARSET);
			_os_.marshal(triggertime);
			_os_.marshal(shape);
			_os_.marshal(color1);
			_os_.marshal(color2);
			_os_.compact_uint32(components.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : components.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			rank = _os_.unmarshal_int();
			roleid = _os_.unmarshal_long();
			rolename = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			school = _os_.unmarshal_int();
			level = _os_.unmarshal_int();
			score = _os_.unmarshal_int();
			clanname = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			triggertime = _os_.unmarshal_long();
			shape = _os_.unmarshal_int();
			color1 = _os_.unmarshal_int();
			color2 = _os_.unmarshal_int();
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					components = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					components.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.RoleProfessionRankRecord copy() {
			return new Data(this);
		}

		@Override
		public xbean.RoleProfessionRankRecord toData() {
			return new Data(this);
		}

		public xbean.RoleProfessionRankRecord toBean() {
			return new RoleProfessionRankRecord(this, null, null);
		}

		@Override
		public xbean.RoleProfessionRankRecord toDataIf() {
			return this;
		}

		public xbean.RoleProfessionRankRecord toBeanIf() {
			return new RoleProfessionRankRecord(this, null, null);
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
		public int getRank() { // 排名
			return rank;
		}

		@Override
		public long getRoleid() { // 人物ID
			return roleid;
		}

		@Override
		public String getRolename() { // 人物名称
			return rolename;
		}

		@Override
		public com.locojoy.base.Octets getRolenameOctets() { // 人物名称
			return com.locojoy.base.Octets.wrap(getRolename(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public int getSchool() { // 职业
			return school;
		}

		@Override
		public int getLevel() { // 等级
			return level;
		}

		@Override
		public int getScore() { // 总评分
			return score;
		}

		@Override
		public String getClanname() { // 帮会，作者 changhao
			return clanname;
		}

		@Override
		public com.locojoy.base.Octets getClannameOctets() { // 帮会，作者 changhao
			return com.locojoy.base.Octets.wrap(getClanname(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public long getTriggertime() { // 触发时间，作者 changhao
			return triggertime;
		}

		@Override
		public int getShape() { // 角色造型
			return shape;
		}

		@Override
		public int getColor1() { // 颜色1
			return color1;
		}

		@Override
		public int getColor2() { // 颜色2
			return color2;
		}

		@Override
		public java.util.Map<Integer, Integer> getComponents() { // 装备部件
			return components;
		}

		@Override
		public java.util.Map<Integer, Integer> getComponentsAsData() { // 装备部件
			return components;
		}

		@Override
		public void setRank(int _v_) { // 排名
			rank = _v_;
		}

		@Override
		public void setRoleid(long _v_) { // 人物ID
			roleid = _v_;
		}

		@Override
		public void setRolename(String _v_) { // 人物名称
			if (null == _v_)
				throw new NullPointerException();
			rolename = _v_;
		}

		@Override
		public void setRolenameOctets(com.locojoy.base.Octets _v_) { // 人物名称
			this.setRolename(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setSchool(int _v_) { // 职业
			school = _v_;
		}

		@Override
		public void setLevel(int _v_) { // 等级
			level = _v_;
		}

		@Override
		public void setScore(int _v_) { // 总评分
			score = _v_;
		}

		@Override
		public void setClanname(String _v_) { // 帮会，作者 changhao
			if (null == _v_)
				throw new NullPointerException();
			clanname = _v_;
		}

		@Override
		public void setClannameOctets(com.locojoy.base.Octets _v_) { // 帮会，作者 changhao
			this.setClanname(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setTriggertime(long _v_) { // 触发时间，作者 changhao
			triggertime = _v_;
		}

		@Override
		public void setShape(int _v_) { // 角色造型
			shape = _v_;
		}

		@Override
		public void setColor1(int _v_) { // 颜色1
			color1 = _v_;
		}

		@Override
		public void setColor2(int _v_) { // 颜色2
			color2 = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof RoleProfessionRankRecord.Data)) return false;
			RoleProfessionRankRecord.Data _o_ = (RoleProfessionRankRecord.Data) _o1_;
			if (rank != _o_.rank) return false;
			if (roleid != _o_.roleid) return false;
			if (!rolename.equals(_o_.rolename)) return false;
			if (school != _o_.school) return false;
			if (level != _o_.level) return false;
			if (score != _o_.score) return false;
			if (!clanname.equals(_o_.clanname)) return false;
			if (triggertime != _o_.triggertime) return false;
			if (shape != _o_.shape) return false;
			if (color1 != _o_.color1) return false;
			if (color2 != _o_.color2) return false;
			if (!components.equals(_o_.components)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += rank;
			_h_ += roleid;
			_h_ += rolename.hashCode();
			_h_ += school;
			_h_ += level;
			_h_ += score;
			_h_ += clanname.hashCode();
			_h_ += triggertime;
			_h_ += shape;
			_h_ += color1;
			_h_ += color2;
			_h_ += components.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(rank);
			_sb_.append(",");
			_sb_.append(roleid);
			_sb_.append(",");
			_sb_.append("'").append(rolename).append("'");
			_sb_.append(",");
			_sb_.append(school);
			_sb_.append(",");
			_sb_.append(level);
			_sb_.append(",");
			_sb_.append(score);
			_sb_.append(",");
			_sb_.append("'").append(clanname).append("'");
			_sb_.append(",");
			_sb_.append(triggertime);
			_sb_.append(",");
			_sb_.append(shape);
			_sb_.append(",");
			_sb_.append(color1);
			_sb_.append(",");
			_sb_.append(color2);
			_sb_.append(",");
			_sb_.append(components);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
