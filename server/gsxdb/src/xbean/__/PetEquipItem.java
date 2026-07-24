
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class PetEquipItem extends mkdb.XBean implements xbean.PetEquipItem {
	private long id; // 主键id
	private int itemid; // 工具编号
	private int pos; // 宠物装备位置
	private int taozhuangid; // 套装ID
	private java.util.HashMap<Integer, Integer> pro; // 宠物装备属性
	private java.util.HashMap<Integer, Integer> skill; // 宠物装备技能

	@Override
	public void _reset_unsafe_() {
		id = 0;
		itemid = 0;
		pos = 0;
		taozhuangid = 0;
		pro.clear();
		skill.clear();
	}

	PetEquipItem(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		id = 0;
		itemid = 0;
		pos = 0;
		taozhuangid = 0;
		pro = new java.util.HashMap<Integer, Integer>();
		skill = new java.util.HashMap<Integer, Integer>();
	}

	public PetEquipItem() {
		this(0, null, null);
	}

	public PetEquipItem(PetEquipItem _o_) {
		this(_o_, null, null);
	}

	PetEquipItem(xbean.PetEquipItem _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof PetEquipItem) assign((PetEquipItem)_o1_);
		else if (_o1_ instanceof PetEquipItem.Data) assign((PetEquipItem.Data)_o1_);
		else if (_o1_ instanceof PetEquipItem.Const) assign(((PetEquipItem.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(PetEquipItem _o_) {
		_o_._xdb_verify_unsafe_();
		id = _o_.id;
		itemid = _o_.itemid;
		pos = _o_.pos;
		taozhuangid = _o_.taozhuangid;
		pro = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.pro.entrySet())
			pro.put(_e_.getKey(), _e_.getValue());
		skill = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.skill.entrySet())
			skill.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(PetEquipItem.Data _o_) {
		id = _o_.id;
		itemid = _o_.itemid;
		pos = _o_.pos;
		taozhuangid = _o_.taozhuangid;
		pro = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.pro.entrySet())
			pro.put(_e_.getKey(), _e_.getValue());
		skill = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.skill.entrySet())
			skill.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(id);
		_os_.marshal(itemid);
		_os_.marshal(pos);
		_os_.marshal(taozhuangid);
		_os_.compact_uint32(pro.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : pro.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		_os_.compact_uint32(skill.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : skill.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		id = _os_.unmarshal_long();
		itemid = _os_.unmarshal_int();
		pos = _os_.unmarshal_int();
		taozhuangid = _os_.unmarshal_int();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				pro = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				pro.put(_k_, _v_);
			}
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				skill = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				skill.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.PetEquipItem copy() {
		_xdb_verify_unsafe_();
		return new PetEquipItem(this);
	}

	@Override
	public xbean.PetEquipItem toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.PetEquipItem toBean() {
		_xdb_verify_unsafe_();
		return new PetEquipItem(this); // same as copy()
	}

	@Override
	public xbean.PetEquipItem toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.PetEquipItem toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public long getId() { // 主键id
		_xdb_verify_unsafe_();
		return id;
	}

	@Override
	public int getItemid() { // 工具编号
		_xdb_verify_unsafe_();
		return itemid;
	}

	@Override
	public int getPos() { // 宠物装备位置
		_xdb_verify_unsafe_();
		return pos;
	}

	@Override
	public int getTaozhuangid() { // 套装ID
		_xdb_verify_unsafe_();
		return taozhuangid;
	}

	@Override
	public java.util.Map<Integer, Integer> getPro() { // 宠物装备属性
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "pro"), pro);
	}

	@Override
	public java.util.Map<Integer, Integer> getProAsData() { // 宠物装备属性
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Integer> pro;
		PetEquipItem _o_ = this;
		pro = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.pro.entrySet())
			pro.put(_e_.getKey(), _e_.getValue());
		return pro;
	}

	@Override
	public java.util.Map<Integer, Integer> getSkill() { // 宠物装备技能
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "skill"), skill);
	}

	@Override
	public java.util.Map<Integer, Integer> getSkillAsData() { // 宠物装备技能
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Integer> skill;
		PetEquipItem _o_ = this;
		skill = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.skill.entrySet())
			skill.put(_e_.getKey(), _e_.getValue());
		return skill;
	}

	@Override
	public void setId(long _v_) { // 主键id
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setItemid(int _v_) { // 工具编号
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "itemid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, itemid) {
					public void rollback() { itemid = _xdb_saved; }
				};}});
		itemid = _v_;
	}

	@Override
	public void setPos(int _v_) { // 宠物装备位置
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "pos") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, pos) {
					public void rollback() { pos = _xdb_saved; }
				};}});
		pos = _v_;
	}

	@Override
	public void setTaozhuangid(int _v_) { // 套装ID
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "taozhuangid") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, taozhuangid) {
					public void rollback() { taozhuangid = _xdb_saved; }
				};}});
		taozhuangid = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		PetEquipItem _o_ = null;
		if ( _o1_ instanceof PetEquipItem ) _o_ = (PetEquipItem)_o1_;
		else if ( _o1_ instanceof PetEquipItem.Const ) _o_ = ((PetEquipItem.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (itemid != _o_.itemid) return false;
		if (pos != _o_.pos) return false;
		if (taozhuangid != _o_.taozhuangid) return false;
		if (!pro.equals(_o_.pro)) return false;
		if (!skill.equals(_o_.skill)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += id;
		_h_ += itemid;
		_h_ += pos;
		_h_ += taozhuangid;
		_h_ += pro.hashCode();
		_h_ += skill.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(itemid);
		_sb_.append(",");
		_sb_.append(pos);
		_sb_.append(",");
		_sb_.append(taozhuangid);
		_sb_.append(",");
		_sb_.append(pro);
		_sb_.append(",");
		_sb_.append(skill);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("itemid"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("pos"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("taozhuangid"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("pro"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("skill"));
		return lb;
	}

	private class Const implements xbean.PetEquipItem {
		PetEquipItem nThis() {
			return PetEquipItem.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.PetEquipItem copy() {
			return PetEquipItem.this.copy();
		}

		@Override
		public xbean.PetEquipItem toData() {
			return PetEquipItem.this.toData();
		}

		public xbean.PetEquipItem toBean() {
			return PetEquipItem.this.toBean();
		}

		@Override
		public xbean.PetEquipItem toDataIf() {
			return PetEquipItem.this.toDataIf();
		}

		public xbean.PetEquipItem toBeanIf() {
			return PetEquipItem.this.toBeanIf();
		}

		@Override
		public long getId() { // 主键id
			_xdb_verify_unsafe_();
			return id;
		}

		@Override
		public int getItemid() { // 工具编号
			_xdb_verify_unsafe_();
			return itemid;
		}

		@Override
		public int getPos() { // 宠物装备位置
			_xdb_verify_unsafe_();
			return pos;
		}

		@Override
		public int getTaozhuangid() { // 套装ID
			_xdb_verify_unsafe_();
			return taozhuangid;
		}

		@Override
		public java.util.Map<Integer, Integer> getPro() { // 宠物装备属性
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(pro);
		}

		@Override
		public java.util.Map<Integer, Integer> getProAsData() { // 宠物装备属性
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Integer> pro;
			PetEquipItem _o_ = PetEquipItem.this;
			pro = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.pro.entrySet())
				pro.put(_e_.getKey(), _e_.getValue());
			return pro;
		}

		@Override
		public java.util.Map<Integer, Integer> getSkill() { // 宠物装备技能
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(skill);
		}

		@Override
		public java.util.Map<Integer, Integer> getSkillAsData() { // 宠物装备技能
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Integer> skill;
			PetEquipItem _o_ = PetEquipItem.this;
			skill = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.skill.entrySet())
				skill.put(_e_.getKey(), _e_.getValue());
			return skill;
		}

		@Override
		public void setId(long _v_) { // 主键id
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setItemid(int _v_) { // 工具编号
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPos(int _v_) { // 宠物装备位置
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setTaozhuangid(int _v_) { // 套装ID
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
			return PetEquipItem.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return PetEquipItem.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return PetEquipItem.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return PetEquipItem.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return PetEquipItem.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return PetEquipItem.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return PetEquipItem.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return PetEquipItem.this.hashCode();
		}

		@Override
		public String toString() {
			return PetEquipItem.this.toString();
		}

	}

	public static final class Data implements xbean.PetEquipItem {
		private long id; // 主键id
		private int itemid; // 工具编号
		private int pos; // 宠物装备位置
		private int taozhuangid; // 套装ID
		private java.util.HashMap<Integer, Integer> pro; // 宠物装备属性
		private java.util.HashMap<Integer, Integer> skill; // 宠物装备技能

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			id = 0;
			itemid = 0;
			pos = 0;
			taozhuangid = 0;
			pro = new java.util.HashMap<Integer, Integer>();
			skill = new java.util.HashMap<Integer, Integer>();
		}

		Data(xbean.PetEquipItem _o1_) {
			if (_o1_ instanceof PetEquipItem) assign((PetEquipItem)_o1_);
			else if (_o1_ instanceof PetEquipItem.Data) assign((PetEquipItem.Data)_o1_);
			else if (_o1_ instanceof PetEquipItem.Const) assign(((PetEquipItem.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(PetEquipItem _o_) {
			id = _o_.id;
			itemid = _o_.itemid;
			pos = _o_.pos;
			taozhuangid = _o_.taozhuangid;
			pro = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.pro.entrySet())
				pro.put(_e_.getKey(), _e_.getValue());
			skill = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.skill.entrySet())
				skill.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(PetEquipItem.Data _o_) {
			id = _o_.id;
			itemid = _o_.itemid;
			pos = _o_.pos;
			taozhuangid = _o_.taozhuangid;
			pro = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.pro.entrySet())
				pro.put(_e_.getKey(), _e_.getValue());
			skill = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.skill.entrySet())
				skill.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(itemid);
			_os_.marshal(pos);
			_os_.marshal(taozhuangid);
			_os_.compact_uint32(pro.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : pro.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			_os_.compact_uint32(skill.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : skill.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_long();
			itemid = _os_.unmarshal_int();
			pos = _os_.unmarshal_int();
			taozhuangid = _os_.unmarshal_int();
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					pro = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					pro.put(_k_, _v_);
				}
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					skill = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					skill.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.PetEquipItem copy() {
			return new Data(this);
		}

		@Override
		public xbean.PetEquipItem toData() {
			return new Data(this);
		}

		public xbean.PetEquipItem toBean() {
			return new PetEquipItem(this, null, null);
		}

		@Override
		public xbean.PetEquipItem toDataIf() {
			return this;
		}

		public xbean.PetEquipItem toBeanIf() {
			return new PetEquipItem(this, null, null);
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
		public long getId() { // 主键id
			return id;
		}

		@Override
		public int getItemid() { // 工具编号
			return itemid;
		}

		@Override
		public int getPos() { // 宠物装备位置
			return pos;
		}

		@Override
		public int getTaozhuangid() { // 套装ID
			return taozhuangid;
		}

		@Override
		public java.util.Map<Integer, Integer> getPro() { // 宠物装备属性
			return pro;
		}

		@Override
		public java.util.Map<Integer, Integer> getProAsData() { // 宠物装备属性
			return pro;
		}

		@Override
		public java.util.Map<Integer, Integer> getSkill() { // 宠物装备技能
			return skill;
		}

		@Override
		public java.util.Map<Integer, Integer> getSkillAsData() { // 宠物装备技能
			return skill;
		}

		@Override
		public void setId(long _v_) { // 主键id
			id = _v_;
		}

		@Override
		public void setItemid(int _v_) { // 工具编号
			itemid = _v_;
		}

		@Override
		public void setPos(int _v_) { // 宠物装备位置
			pos = _v_;
		}

		@Override
		public void setTaozhuangid(int _v_) { // 套装ID
			taozhuangid = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof PetEquipItem.Data)) return false;
			PetEquipItem.Data _o_ = (PetEquipItem.Data) _o1_;
			if (id != _o_.id) return false;
			if (itemid != _o_.itemid) return false;
			if (pos != _o_.pos) return false;
			if (taozhuangid != _o_.taozhuangid) return false;
			if (!pro.equals(_o_.pro)) return false;
			if (!skill.equals(_o_.skill)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += itemid;
			_h_ += pos;
			_h_ += taozhuangid;
			_h_ += pro.hashCode();
			_h_ += skill.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(itemid);
			_sb_.append(",");
			_sb_.append(pos);
			_sb_.append(",");
			_sb_.append(taozhuangid);
			_sb_.append(",");
			_sb_.append(pro);
			_sb_.append(",");
			_sb_.append(skill);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
