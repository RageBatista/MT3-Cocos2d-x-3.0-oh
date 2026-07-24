
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class DataType extends mkdb.XBean implements xbean.DataType {
	private int id; // int value
	private long max; // long value
	private short mshort; // short value
	private float mfloat; // float value
	private String name; // string value
	private byte [] mobject; // object, binary
	private xbean.SubBean sub; // SubBean value
	private mkdb.util.SetX<xbean.SubBean> set; // SubBean set
	private java.util.LinkedList<xbean.SubBean> list; // SubBean list
	private java.util.HashMap<String, xbean.SubBean> map; // string-SubBean map

	@Override
	public void _reset_unsafe_() {
		id = 0;
		max = 0L;
		mshort = 0;
		mfloat = 0.0f;
		name = "";
		mobject = new byte[0];
		sub._reset_unsafe_();
		set.clear();
		list.clear();
		map.clear();
	}

	DataType(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		name = "";
		mobject = new byte[0];
		sub = new SubBean(0, this, "sub");
		set = new mkdb.util.SetX<xbean.SubBean>();
		list = new java.util.LinkedList<xbean.SubBean>();
		map = new java.util.HashMap<String, xbean.SubBean>();
	}

	public DataType() {
		this(0, null, null);
	}

	public DataType(DataType _o_) {
		this(_o_, null, null);
	}

	DataType(xbean.DataType _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof DataType) assign((DataType)_o1_);
		else if (_o1_ instanceof DataType.Data) assign((DataType.Data)_o1_);
		else if (_o1_ instanceof DataType.Const) assign(((DataType.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(DataType _o_) {
		id = _o_.id;
		max = _o_.max;
		mshort = _o_.mshort;
		mfloat = _o_.mfloat;
		name = _o_.name;
		mobject = java.util.Arrays.copyOf(_o_.mobject, _o_.mobject.length);
		sub = new SubBean(_o_.sub, this, "sub");
		set = new mkdb.util.SetX<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.set)
			set.add(new SubBean(_v_, this, "set"));
		list = new java.util.LinkedList<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.list)
			list.add(new SubBean(_v_, this, "list"));
		map = new java.util.HashMap<String, xbean.SubBean>();
		for (java.util.Map.Entry<String, xbean.SubBean> _e_ : _o_.map.entrySet())
			map.put(_e_.getKey(), new SubBean(_e_.getValue(), this, "map"));
	}

	private void assign(DataType.Data _o_) {
		id = _o_.id;
		max = _o_.max;
		mshort = _o_.mshort;
		mfloat = _o_.mfloat;
		name = _o_.name;
		mobject = java.util.Arrays.copyOf(_o_.mobject, _o_.mobject.length);
		sub = new SubBean(_o_.sub, this, "sub");
		set = new mkdb.util.SetX<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.set)
			set.add(new SubBean(_v_, this, "set"));
		list = new java.util.LinkedList<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.list)
			list.add(new SubBean(_v_, this, "list"));
		map = new java.util.HashMap<String, xbean.SubBean>();
		for (java.util.Map.Entry<String, xbean.SubBean> _e_ : _o_.map.entrySet())
			map.put(_e_.getKey(), new SubBean(_e_.getValue(), this, "map"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		_os_.marshal(max);
		_os_.marshal(mshort);
		_os_.marshal(mfloat);
		_os_.marshal(name, mkdb.Const.IO_CHARSET);
		_os_.marshal(mobject);
		sub.marshal(_os_);
		_os_.compact_uint32(set.size());
		for (xbean.SubBean _v_ : set) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(list.size());
		for (xbean.SubBean _v_ : list) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(map.size());
		for (java.util.Map.Entry<String, xbean.SubBean> _e_ : map.entrySet())
		{
			_os_.marshal(_e_.getKey(), mkdb.Const.IO_CHARSET);
			_e_.getValue().marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		max = _os_.unmarshal_long();
		mshort = _os_.unmarshal_short();
		mfloat = _os_.unmarshal_float();
		name = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		mobject = _os_.unmarshal_bytes();
		sub.unmarshal(_os_);
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.SubBean _v_ = new SubBean(0, this, "set");
			_v_.unmarshal(_os_);
			set.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.SubBean _v_ = new SubBean(0, this, "list");
			_v_.unmarshal(_os_);
			list.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				map = new java.util.HashMap<String, xbean.SubBean>(size * 2);
			}
			for (; size > 0; --size)
			{
				String _k_ = "";
				_k_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
				xbean.SubBean _v_ = new SubBean(0, this, "map");
				_v_.unmarshal(_os_);
				map.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.DataType copy() {
		return new DataType(this);
	}

	@Override
	public xbean.DataType toData() {
		return new Data(this);
	}

	public xbean.DataType toBean() {
		return new DataType(this); // same as copy()
	}

	@Override
	public xbean.DataType toDataIf() {
		return new Data(this);
	}

	public xbean.DataType toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // int value
		return id;
	}

	@Override
	public long getMax() { // long value
		return max;
	}

	@Override
	public short getMshort() { // short value
		return mshort;
	}

	@Override
	public float getMfloat() { // float value
		return mfloat;
	}

	@Override
	public String getName() { // string value
		return name;
	}

	@Override
	public com.locojoy.base.Octets getNameOctets() { // string value
		return com.locojoy.base.Octets.wrap(getName(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public <T extends com.locojoy.base.Marshal.Marshal> T getMobject(T _v_) { // object, binary
		try {
			_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(mobject)));
			return _v_;
		} catch (MarshalException _e_) {
			throw new mkio.MarshalError();
		}
	}

	@Override
	public boolean isMobjectEmpty() { // object, binary
		return mobject.length == 0;
	}

	@Override
	public byte[] getMobjectCopy() { // object, binary
		return java.util.Arrays.copyOf(mobject, mobject.length);
	}

	@Override
	public xbean.SubBean getSub() { // SubBean value
		return sub;
	}

	@Override
	public java.util.Set<xbean.SubBean> getSet() { // SubBean set
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "set"), set);
	}

	public java.util.Set<xbean.SubBean> getSetAsData() { // SubBean set
		java.util.Set<xbean.SubBean> set;
		DataType _o_ = this;
		set = new mkdb.util.SetX<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.set)
			set.add(new SubBean.Data(_v_));
		return set;
	}

	@Override
	public java.util.List<xbean.SubBean> getList() { // SubBean list
		return mkdb.Logs.logList(new mkdb.LogKey(this, "list"), list);
	}

	public java.util.List<xbean.SubBean> getListAsData() { // SubBean list
		java.util.List<xbean.SubBean> list;
		DataType _o_ = this;
		list = new java.util.LinkedList<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.list)
			list.add(new SubBean.Data(_v_));
		return list;
	}

	@Override
	public java.util.Map<String, xbean.SubBean> getMap() { // string-SubBean map
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "map"), map);
	}

	@Override
	public java.util.Map<String, xbean.SubBean> getMapAsData() { // string-SubBean map
		java.util.Map<String, xbean.SubBean> map;
		DataType _o_ = this;
		map = new java.util.HashMap<String, xbean.SubBean>();
		for (java.util.Map.Entry<String, xbean.SubBean> _e_ : _o_.map.entrySet())
			map.put(_e_.getKey(), new SubBean.Data(_e_.getValue()));
		return map;
	}

	@Override
	public void setId(int _v_) { // int value
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setMax(long _v_) { // long value
		mkdb.Logs.logIf(new mkdb.LogKey(this, "max") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, max) {
					public void rollback() { max = _xdb_saved; }
				};}});
		max = _v_;
	}

	@Override
	public void setMshort(short _v_) { // short value
		mkdb.Logs.logIf(new mkdb.LogKey(this, "mshort") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogShort(this, mshort) {
					public void rollback() { mshort = _xdb_saved; }
				};}});
		mshort = _v_;
	}

	@Override
	public void setMfloat(float _v_) { // float value
		mkdb.Logs.logIf(new mkdb.LogKey(this, "mfloat") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogFloat(this, mfloat) {
					public void rollback() { mfloat = _xdb_saved; }
				};}});
		mfloat = _v_;
	}

	@Override
	public void setName(String _v_) { // string value
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
	public void setNameOctets(com.locojoy.base.Octets _v_) { // string value
		this.setName(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public void setMobject(com.locojoy.base.Marshal.Marshal _v_) { // object, binary
		mkdb.Logs.logIf(new mkdb.LogKey(this, "mobject") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, mobject) {
					public void rollback() { mobject = _xdb_saved; }
			}; }});
		mobject = _v_.marshal(new OctetsStream()).getBytes();
	}

	@Override
	public void setMobjectCopy(byte[] _v_) { // object, binary
		mkdb.Logs.logIf(new mkdb.LogKey(this, "mobject") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, mobject) {
					public void rollback() { mobject = _xdb_saved; }
			}; }});
		mobject = java.util.Arrays.copyOf(_v_, _v_.length);
	}

	@Override
	public final boolean equals(Object _o1_) {
		DataType _o_ = null;
		if ( _o1_ instanceof DataType ) _o_ = (DataType)_o1_;
		else if ( _o1_ instanceof DataType.Const ) _o_ = ((DataType.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (max != _o_.max) return false;
		if (mshort != _o_.mshort) return false;
		if (mfloat != _o_.mfloat) return false;
		if (!name.equals(_o_.name)) return false;
		if (!java.util.Arrays.equals(mobject, _o_.mobject)) return false;
		if (!sub.equals(_o_.sub)) return false;
		if (!set.equals(_o_.set)) return false;
		if (!list.equals(_o_.list)) return false;
		if (!map.equals(_o_.map)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		_h_ += max;
		_h_ += mshort;
		_h_ += mfloat;
		_h_ += name.hashCode();
		_h_ += java.util.Arrays.hashCode(mobject);
		_h_ += sub.hashCode();
		_h_ += set.hashCode();
		_h_ += list.hashCode();
		_h_ += map.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(max);
		_sb_.append(",");
		_sb_.append(mshort);
		_sb_.append(",");
		_sb_.append(mfloat);
		_sb_.append(",");
		_sb_.append("'").append(name).append("'");
		_sb_.append(",");
		_sb_.append('B').append(mobject.length);
		_sb_.append(",");
		_sb_.append(sub);
		_sb_.append(",");
		_sb_.append(set);
		_sb_.append(",");
		_sb_.append(list);
		_sb_.append(",");
		_sb_.append(map);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("max"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("mshort"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("mfloat"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("name"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("mobject"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("sub"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("set"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("list"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("map"));
		return lb;
	}

	private class Const implements xbean.DataType {
		DataType nThis() {
			return DataType.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.DataType copy() {
			return DataType.this.copy();
		}

		@Override
		public xbean.DataType toData() {
			return DataType.this.toData();
		}

		public xbean.DataType toBean() {
			return DataType.this.toBean();
		}

		@Override
		public xbean.DataType toDataIf() {
			return DataType.this.toDataIf();
		}

		public xbean.DataType toBeanIf() {
			return DataType.this.toBeanIf();
		}

		@Override
		public int getId() { // int value
			return id;
		}

		@Override
		public long getMax() { // long value
			return max;
		}

		@Override
		public short getMshort() { // short value
			return mshort;
		}

		@Override
		public float getMfloat() { // float value
			return mfloat;
		}

		@Override
		public String getName() { // string value
			return name;
		}

		@Override
		public com.locojoy.base.Octets getNameOctets() { // string value
			return DataType.this.getNameOctets();
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMobject(T _v_) { // object, binary
			return DataType.this.getMobject(_v_);
		}

		@Override
		public boolean isMobjectEmpty() { // object, binary
			return DataType.this.isMobjectEmpty();
		}

		@Override
		public byte[] getMobjectCopy() { // object, binary
			return DataType.this.getMobjectCopy();
		}

		@Override
		public xbean.SubBean getSub() { // SubBean value
			return mkdb.Consts.toConst(sub);
		}

		@Override
		public java.util.Set<xbean.SubBean> getSet() { // SubBean set
			return mkdb.Consts.constSet(set);
		}

		public java.util.Set<xbean.SubBean> getSetAsData() { // SubBean set
			java.util.Set<xbean.SubBean> set;
			DataType _o_ = DataType.this;
		set = new mkdb.util.SetX<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.set)
			set.add(new SubBean.Data(_v_));
			return set;
		}

		@Override
		public java.util.List<xbean.SubBean> getList() { // SubBean list
			return mkdb.Consts.constList(list);
		}

		public java.util.List<xbean.SubBean> getListAsData() { // SubBean list
			java.util.List<xbean.SubBean> list;
			DataType _o_ = DataType.this;
		list = new java.util.LinkedList<xbean.SubBean>();
		for (xbean.SubBean _v_ : _o_.list)
			list.add(new SubBean.Data(_v_));
			return list;
		}

		@Override
		public java.util.Map<String, xbean.SubBean> getMap() { // string-SubBean map
			return mkdb.Consts.constMap(map);
		}

		@Override
		public java.util.Map<String, xbean.SubBean> getMapAsData() { // string-SubBean map
			java.util.Map<String, xbean.SubBean> map;
			DataType _o_ = DataType.this;
			map = new java.util.HashMap<String, xbean.SubBean>();
			for (java.util.Map.Entry<String, xbean.SubBean> _e_ : _o_.map.entrySet())
				map.put(_e_.getKey(), new SubBean.Data(_e_.getValue()));
			return map;
		}

		@Override
		public void setId(int _v_) { // int value
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMax(long _v_) { // long value
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMshort(short _v_) { // short value
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMfloat(float _v_) { // float value
			throw new UnsupportedOperationException();
		}

		@Override
		public void setName(String _v_) { // string value
			throw new UnsupportedOperationException();
		}

		@Override
		public void setNameOctets(com.locojoy.base.Octets _v_) { // string value
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMobject(com.locojoy.base.Marshal.Marshal _v_) { // object, binary
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMobjectCopy(byte[] _v_) { // object, binary
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
			return DataType.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return DataType.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return DataType.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return DataType.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return DataType.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return DataType.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return DataType.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return DataType.this.hashCode();
		}

		@Override
		public String toString() {
			return DataType.this.toString();
		}

	}

	public static final class Data implements xbean.DataType {
		private int id; // int value
		private long max; // long value
		private short mshort; // short value
		private float mfloat; // float value
		private String name; // string value
		private byte [] mobject; // object, binary
		private xbean.SubBean sub; // SubBean value
		private java.util.HashSet<xbean.SubBean> set; // SubBean set
		private java.util.LinkedList<xbean.SubBean> list; // SubBean list
		private java.util.HashMap<String, xbean.SubBean> map; // string-SubBean map

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			name = "";
			mobject = new byte[0];
			sub = new SubBean.Data();
			set = new java.util.HashSet<xbean.SubBean>();
			list = new java.util.LinkedList<xbean.SubBean>();
			map = new java.util.HashMap<String, xbean.SubBean>();
		}

		Data(xbean.DataType _o1_) {
			if (_o1_ instanceof DataType) assign((DataType)_o1_);
			else if (_o1_ instanceof DataType.Data) assign((DataType.Data)_o1_);
			else if (_o1_ instanceof DataType.Const) assign(((DataType.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(DataType _o_) {
			id = _o_.id;
			max = _o_.max;
			mshort = _o_.mshort;
			mfloat = _o_.mfloat;
			name = _o_.name;
			mobject = java.util.Arrays.copyOf(_o_.mobject, _o_.mobject.length);
			sub = new SubBean.Data(_o_.sub);
			set = new java.util.HashSet<xbean.SubBean>();
			for (xbean.SubBean _v_ : _o_.set)
				set.add(new SubBean.Data(_v_));
			list = new java.util.LinkedList<xbean.SubBean>();
			for (xbean.SubBean _v_ : _o_.list)
				list.add(new SubBean.Data(_v_));
			map = new java.util.HashMap<String, xbean.SubBean>();
			for (java.util.Map.Entry<String, xbean.SubBean> _e_ : _o_.map.entrySet())
				map.put(_e_.getKey(), new SubBean.Data(_e_.getValue()));
		}

		private void assign(DataType.Data _o_) {
			id = _o_.id;
			max = _o_.max;
			mshort = _o_.mshort;
			mfloat = _o_.mfloat;
			name = _o_.name;
			mobject = java.util.Arrays.copyOf(_o_.mobject, _o_.mobject.length);
			sub = new SubBean.Data(_o_.sub);
			set = new java.util.HashSet<xbean.SubBean>();
			for (xbean.SubBean _v_ : _o_.set)
				set.add(new SubBean.Data(_v_));
			list = new java.util.LinkedList<xbean.SubBean>();
			for (xbean.SubBean _v_ : _o_.list)
				list.add(new SubBean.Data(_v_));
			map = new java.util.HashMap<String, xbean.SubBean>();
			for (java.util.Map.Entry<String, xbean.SubBean> _e_ : _o_.map.entrySet())
				map.put(_e_.getKey(), new SubBean.Data(_e_.getValue()));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(max);
			_os_.marshal(mshort);
			_os_.marshal(mfloat);
			_os_.marshal(name, mkdb.Const.IO_CHARSET);
			_os_.marshal(mobject);
			sub.marshal(_os_);
			_os_.compact_uint32(set.size());
			for (xbean.SubBean _v_ : set) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(list.size());
			for (xbean.SubBean _v_ : list) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(map.size());
			for (java.util.Map.Entry<String, xbean.SubBean> _e_ : map.entrySet())
			{
				_os_.marshal(_e_.getKey(), mkdb.Const.IO_CHARSET);
				_e_.getValue().marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			max = _os_.unmarshal_long();
			mshort = _os_.unmarshal_short();
			mfloat = _os_.unmarshal_float();
			name = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			mobject = _os_.unmarshal_bytes();
			sub.unmarshal(_os_);
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.SubBean _v_ = xbean.Pod.newSubBeanData();
				_v_.unmarshal(_os_);
				set.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.SubBean _v_ = xbean.Pod.newSubBeanData();
				_v_.unmarshal(_os_);
				list.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					map = new java.util.HashMap<String, xbean.SubBean>(size * 2);
				}
				for (; size > 0; --size)
				{
					String _k_ = "";
					_k_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
					xbean.SubBean _v_ = xbean.Pod.newSubBeanData();
					_v_.unmarshal(_os_);
					map.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.DataType copy() {
			return new Data(this);
		}

		@Override
		public xbean.DataType toData() {
			return new Data(this);
		}

		public xbean.DataType toBean() {
			return new DataType(this, null, null);
		}

		@Override
		public xbean.DataType toDataIf() {
			return this;
		}

		public xbean.DataType toBeanIf() {
			return new DataType(this, null, null);
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
		public int getId() { // int value
			return id;
		}

		@Override
		public long getMax() { // long value
			return max;
		}

		@Override
		public short getMshort() { // short value
			return mshort;
		}

		@Override
		public float getMfloat() { // float value
			return mfloat;
		}

		@Override
		public String getName() { // string value
			return name;
		}

		@Override
		public com.locojoy.base.Octets getNameOctets() { // string value
			return com.locojoy.base.Octets.wrap(getName(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMobject(T _v_) { // object, binary
			try {
				_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(mobject)));
				return _v_;
			} catch (MarshalException _e_) {
				throw new mkio.MarshalError();
			}
		}

		@Override
		public boolean isMobjectEmpty() { // object, binary
			return mobject.length == 0;
		}

		@Override
		public byte[] getMobjectCopy() { // object, binary
			return java.util.Arrays.copyOf(mobject, mobject.length);
		}

		@Override
		public xbean.SubBean getSub() { // SubBean value
			return sub;
		}

		@Override
		public java.util.Set<xbean.SubBean> getSet() { // SubBean set
			return set;
		}

		@Override
		public java.util.Set<xbean.SubBean> getSetAsData() { // SubBean set
			return set;
		}

		@Override
		public java.util.List<xbean.SubBean> getList() { // SubBean list
			return list;
		}

		@Override
		public java.util.List<xbean.SubBean> getListAsData() { // SubBean list
			return list;
		}

		@Override
		public java.util.Map<String, xbean.SubBean> getMap() { // string-SubBean map
			return map;
		}

		@Override
		public java.util.Map<String, xbean.SubBean> getMapAsData() { // string-SubBean map
			return map;
		}

		@Override
		public void setId(int _v_) { // int value
			id = _v_;
		}

		@Override
		public void setMax(long _v_) { // long value
			max = _v_;
		}

		@Override
		public void setMshort(short _v_) { // short value
			mshort = _v_;
		}

		@Override
		public void setMfloat(float _v_) { // float value
			mfloat = _v_;
		}

		@Override
		public void setName(String _v_) { // string value
			if (null == _v_)
				throw new NullPointerException();
			name = _v_;
		}

		@Override
		public void setNameOctets(com.locojoy.base.Octets _v_) { // string value
			this.setName(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public void setMobject(com.locojoy.base.Marshal.Marshal _v_) { // object, binary
			mobject = _v_.marshal(new OctetsStream()).getBytes();
		}

		@Override
		public void setMobjectCopy(byte[] _v_) { // object, binary
			mobject = java.util.Arrays.copyOf(_v_, _v_.length);
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof DataType.Data)) return false;
			DataType.Data _o_ = (DataType.Data) _o1_;
			if (id != _o_.id) return false;
			if (max != _o_.max) return false;
			if (mshort != _o_.mshort) return false;
			if (mfloat != _o_.mfloat) return false;
			if (!name.equals(_o_.name)) return false;
			if (!java.util.Arrays.equals(mobject, _o_.mobject)) return false;
			if (!sub.equals(_o_.sub)) return false;
			if (!set.equals(_o_.set)) return false;
			if (!list.equals(_o_.list)) return false;
			if (!map.equals(_o_.map)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += max;
			_h_ += mshort;
			_h_ += mfloat;
			_h_ += name.hashCode();
			_h_ += java.util.Arrays.hashCode(mobject);
			_h_ += sub.hashCode();
			_h_ += set.hashCode();
			_h_ += list.hashCode();
			_h_ += map.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(max);
			_sb_.append(",");
			_sb_.append(mshort);
			_sb_.append(",");
			_sb_.append(mfloat);
			_sb_.append(",");
			_sb_.append("'").append(name).append("'");
			_sb_.append(",");
			_sb_.append('B').append(mobject.length);
			_sb_.append(",");
			_sb_.append(sub);
			_sb_.append(",");
			_sb_.append(set);
			_sb_.append(",");
			_sb_.append(list);
			_sb_.append(",");
			_sb_.append(map);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
