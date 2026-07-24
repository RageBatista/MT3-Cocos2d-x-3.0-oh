
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Jingmai extends mkdb.XBean implements xbean.Jingmai {
	private int id; // 装备等级
	private int qianyuandan; // 装备等级
	private int qiankundan; // 装备等级
	private int fangan; // 装备等级
	private int state; // 装备等级
	private java.util.HashMap<Integer, Integer> jingmais; // 潜能。未分配点数
	private java.util.HashMap<Integer, xbean.XingChenItem> xingchen; // 拥有的称谓列表

	@Override
	public void _reset_unsafe_() {
		id = 0;
		qianyuandan = 0;
		qiankundan = 0;
		fangan = 0;
		state = 0;
		jingmais.clear();
		xingchen.clear();
	}

	Jingmai(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		jingmais = new java.util.HashMap<Integer, Integer>();
		xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
	}

	public Jingmai() {
		this(0, null, null);
	}

	public Jingmai(Jingmai _o_) {
		this(_o_, null, null);
	}

	Jingmai(xbean.Jingmai _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Jingmai) assign((Jingmai)_o1_);
		else if (_o1_ instanceof Jingmai.Data) assign((Jingmai.Data)_o1_);
		else if (_o1_ instanceof Jingmai.Const) assign(((Jingmai.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Jingmai _o_) {
		_o_._xdb_verify_unsafe_();
		id = _o_.id;
		qianyuandan = _o_.qianyuandan;
		qiankundan = _o_.qiankundan;
		fangan = _o_.fangan;
		state = _o_.state;
		jingmais = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.jingmais.entrySet())
			jingmais.put(_e_.getKey(), _e_.getValue());
		xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
		for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : _o_.xingchen.entrySet())
			xingchen.put(_e_.getKey(), new XingChenItem(_e_.getValue(), this, "xingchen"));
	}

	private void assign(Jingmai.Data _o_) {
		id = _o_.id;
		qianyuandan = _o_.qianyuandan;
		qiankundan = _o_.qiankundan;
		fangan = _o_.fangan;
		state = _o_.state;
		jingmais = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.jingmais.entrySet())
			jingmais.put(_e_.getKey(), _e_.getValue());
		xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
		for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : _o_.xingchen.entrySet())
			xingchen.put(_e_.getKey(), new XingChenItem(_e_.getValue(), this, "xingchen"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(id);
		_os_.marshal(qianyuandan);
		_os_.marshal(qiankundan);
		_os_.marshal(fangan);
		_os_.marshal(state);
		_os_.compact_uint32(jingmais.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : jingmais.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		_os_.compact_uint32(xingchen.size());
		for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : xingchen.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		id = _os_.unmarshal_int();
		qianyuandan = _os_.unmarshal_int();
		qiankundan = _os_.unmarshal_int();
		fangan = _os_.unmarshal_int();
		state = _os_.unmarshal_int();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				jingmais = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				jingmais.put(_k_, _v_);
			}
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.XingChenItem _v_ = new XingChenItem(0, this, "xingchen");
				_v_.unmarshal(_os_);
				xingchen.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.Jingmai copy() {
		_xdb_verify_unsafe_();
		return new Jingmai(this);
	}

	@Override
	public xbean.Jingmai toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.Jingmai toBean() {
		_xdb_verify_unsafe_();
		return new Jingmai(this); // same as copy()
	}

	@Override
	public xbean.Jingmai toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.Jingmai toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public int getId() { // 装备等级
		_xdb_verify_unsafe_();
		return id;
	}

	@Override
	public int getQianyuandan() { // 装备等级
		_xdb_verify_unsafe_();
		return qianyuandan;
	}

	@Override
	public int getQiankundan() { // 装备等级
		_xdb_verify_unsafe_();
		return qiankundan;
	}

	@Override
	public int getFangan() { // 装备等级
		_xdb_verify_unsafe_();
		return fangan;
	}

	@Override
	public int getState() { // 装备等级
		_xdb_verify_unsafe_();
		return state;
	}

	@Override
	public java.util.Map<Integer, Integer> getJingmais() { // 潜能。未分配点数
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "jingmais"), jingmais);
	}

	@Override
	public java.util.Map<Integer, Integer> getJingmaisAsData() { // 潜能。未分配点数
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Integer> jingmais;
		Jingmai _o_ = this;
		jingmais = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.jingmais.entrySet())
			jingmais.put(_e_.getKey(), _e_.getValue());
		return jingmais;
	}

	@Override
	public java.util.Map<Integer, xbean.XingChenItem> getXingchen() { // 拥有的称谓列表
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "xingchen"), xingchen);
	}

	@Override
	public java.util.Map<Integer, xbean.XingChenItem> getXingchenAsData() { // 拥有的称谓列表
		_xdb_verify_unsafe_();
		java.util.Map<Integer, xbean.XingChenItem> xingchen;
		Jingmai _o_ = this;
		xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
		for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : _o_.xingchen.entrySet())
			xingchen.put(_e_.getKey(), new XingChenItem.Data(_e_.getValue()));
		return xingchen;
	}

	@Override
	public void setId(int _v_) { // 装备等级
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setQianyuandan(int _v_) { // 装备等级
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "qianyuandan") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, qianyuandan) {
					public void rollback() { qianyuandan = _xdb_saved; }
				};}});
		qianyuandan = _v_;
	}

	@Override
	public void setQiankundan(int _v_) { // 装备等级
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "qiankundan") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, qiankundan) {
					public void rollback() { qiankundan = _xdb_saved; }
				};}});
		qiankundan = _v_;
	}

	@Override
	public void setFangan(int _v_) { // 装备等级
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "fangan") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, fangan) {
					public void rollback() { fangan = _xdb_saved; }
				};}});
		fangan = _v_;
	}

	@Override
	public void setState(int _v_) { // 装备等级
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "state") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, state) {
					public void rollback() { state = _xdb_saved; }
				};}});
		state = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		Jingmai _o_ = null;
		if ( _o1_ instanceof Jingmai ) _o_ = (Jingmai)_o1_;
		else if ( _o1_ instanceof Jingmai.Const ) _o_ = ((Jingmai.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (qianyuandan != _o_.qianyuandan) return false;
		if (qiankundan != _o_.qiankundan) return false;
		if (fangan != _o_.fangan) return false;
		if (state != _o_.state) return false;
		if (!jingmais.equals(_o_.jingmais)) return false;
		if (!xingchen.equals(_o_.xingchen)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += id;
		_h_ += qianyuandan;
		_h_ += qiankundan;
		_h_ += fangan;
		_h_ += state;
		_h_ += jingmais.hashCode();
		_h_ += xingchen.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(qianyuandan);
		_sb_.append(",");
		_sb_.append(qiankundan);
		_sb_.append(",");
		_sb_.append(fangan);
		_sb_.append(",");
		_sb_.append(state);
		_sb_.append(",");
		_sb_.append(jingmais);
		_sb_.append(",");
		_sb_.append(xingchen);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("qianyuandan"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("qiankundan"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("fangan"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("state"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("jingmais"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("xingchen"));
		return lb;
	}

	private class Const implements xbean.Jingmai {
		Jingmai nThis() {
			return Jingmai.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Jingmai copy() {
			return Jingmai.this.copy();
		}

		@Override
		public xbean.Jingmai toData() {
			return Jingmai.this.toData();
		}

		public xbean.Jingmai toBean() {
			return Jingmai.this.toBean();
		}

		@Override
		public xbean.Jingmai toDataIf() {
			return Jingmai.this.toDataIf();
		}

		public xbean.Jingmai toBeanIf() {
			return Jingmai.this.toBeanIf();
		}

		@Override
		public int getId() { // 装备等级
			_xdb_verify_unsafe_();
			return id;
		}

		@Override
		public int getQianyuandan() { // 装备等级
			_xdb_verify_unsafe_();
			return qianyuandan;
		}

		@Override
		public int getQiankundan() { // 装备等级
			_xdb_verify_unsafe_();
			return qiankundan;
		}

		@Override
		public int getFangan() { // 装备等级
			_xdb_verify_unsafe_();
			return fangan;
		}

		@Override
		public int getState() { // 装备等级
			_xdb_verify_unsafe_();
			return state;
		}

		@Override
		public java.util.Map<Integer, Integer> getJingmais() { // 潜能。未分配点数
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(jingmais);
		}

		@Override
		public java.util.Map<Integer, Integer> getJingmaisAsData() { // 潜能。未分配点数
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Integer> jingmais;
			Jingmai _o_ = Jingmai.this;
			jingmais = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.jingmais.entrySet())
				jingmais.put(_e_.getKey(), _e_.getValue());
			return jingmais;
		}

		@Override
		public java.util.Map<Integer, xbean.XingChenItem> getXingchen() { // 拥有的称谓列表
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(xingchen);
		}

		@Override
		public java.util.Map<Integer, xbean.XingChenItem> getXingchenAsData() { // 拥有的称谓列表
			_xdb_verify_unsafe_();
			java.util.Map<Integer, xbean.XingChenItem> xingchen;
			Jingmai _o_ = Jingmai.this;
			xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
			for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : _o_.xingchen.entrySet())
				xingchen.put(_e_.getKey(), new XingChenItem.Data(_e_.getValue()));
			return xingchen;
		}

		@Override
		public void setId(int _v_) { // 装备等级
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setQianyuandan(int _v_) { // 装备等级
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setQiankundan(int _v_) { // 装备等级
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setFangan(int _v_) { // 装备等级
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setState(int _v_) { // 装备等级
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
			return Jingmai.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Jingmai.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Jingmai.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Jingmai.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Jingmai.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Jingmai.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Jingmai.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Jingmai.this.hashCode();
		}

		@Override
		public String toString() {
			return Jingmai.this.toString();
		}

	}

	public static final class Data implements xbean.Jingmai {
		private int id; // 装备等级
		private int qianyuandan; // 装备等级
		private int qiankundan; // 装备等级
		private int fangan; // 装备等级
		private int state; // 装备等级
		private java.util.HashMap<Integer, Integer> jingmais; // 潜能。未分配点数
		private java.util.HashMap<Integer, xbean.XingChenItem> xingchen; // 拥有的称谓列表

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			jingmais = new java.util.HashMap<Integer, Integer>();
			xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
		}

		Data(xbean.Jingmai _o1_) {
			if (_o1_ instanceof Jingmai) assign((Jingmai)_o1_);
			else if (_o1_ instanceof Jingmai.Data) assign((Jingmai.Data)_o1_);
			else if (_o1_ instanceof Jingmai.Const) assign(((Jingmai.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Jingmai _o_) {
			id = _o_.id;
			qianyuandan = _o_.qianyuandan;
			qiankundan = _o_.qiankundan;
			fangan = _o_.fangan;
			state = _o_.state;
			jingmais = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.jingmais.entrySet())
				jingmais.put(_e_.getKey(), _e_.getValue());
			xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
			for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : _o_.xingchen.entrySet())
				xingchen.put(_e_.getKey(), new XingChenItem.Data(_e_.getValue()));
		}

		private void assign(Jingmai.Data _o_) {
			id = _o_.id;
			qianyuandan = _o_.qianyuandan;
			qiankundan = _o_.qiankundan;
			fangan = _o_.fangan;
			state = _o_.state;
			jingmais = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.jingmais.entrySet())
				jingmais.put(_e_.getKey(), _e_.getValue());
			xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>();
			for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : _o_.xingchen.entrySet())
				xingchen.put(_e_.getKey(), new XingChenItem.Data(_e_.getValue()));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(qianyuandan);
			_os_.marshal(qiankundan);
			_os_.marshal(fangan);
			_os_.marshal(state);
			_os_.compact_uint32(jingmais.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : jingmais.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			_os_.compact_uint32(xingchen.size());
			for (java.util.Map.Entry<Integer, xbean.XingChenItem> _e_ : xingchen.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			qianyuandan = _os_.unmarshal_int();
			qiankundan = _os_.unmarshal_int();
			fangan = _os_.unmarshal_int();
			state = _os_.unmarshal_int();
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					jingmais = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					jingmais.put(_k_, _v_);
				}
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					xingchen = new java.util.HashMap<Integer, xbean.XingChenItem>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.XingChenItem _v_ = xbean.Pod.newXingChenItemData();
					_v_.unmarshal(_os_);
					xingchen.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.Jingmai copy() {
			return new Data(this);
		}

		@Override
		public xbean.Jingmai toData() {
			return new Data(this);
		}

		public xbean.Jingmai toBean() {
			return new Jingmai(this, null, null);
		}

		@Override
		public xbean.Jingmai toDataIf() {
			return this;
		}

		public xbean.Jingmai toBeanIf() {
			return new Jingmai(this, null, null);
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
		public int getId() { // 装备等级
			return id;
		}

		@Override
		public int getQianyuandan() { // 装备等级
			return qianyuandan;
		}

		@Override
		public int getQiankundan() { // 装备等级
			return qiankundan;
		}

		@Override
		public int getFangan() { // 装备等级
			return fangan;
		}

		@Override
		public int getState() { // 装备等级
			return state;
		}

		@Override
		public java.util.Map<Integer, Integer> getJingmais() { // 潜能。未分配点数
			return jingmais;
		}

		@Override
		public java.util.Map<Integer, Integer> getJingmaisAsData() { // 潜能。未分配点数
			return jingmais;
		}

		@Override
		public java.util.Map<Integer, xbean.XingChenItem> getXingchen() { // 拥有的称谓列表
			return xingchen;
		}

		@Override
		public java.util.Map<Integer, xbean.XingChenItem> getXingchenAsData() { // 拥有的称谓列表
			return xingchen;
		}

		@Override
		public void setId(int _v_) { // 装备等级
			id = _v_;
		}

		@Override
		public void setQianyuandan(int _v_) { // 装备等级
			qianyuandan = _v_;
		}

		@Override
		public void setQiankundan(int _v_) { // 装备等级
			qiankundan = _v_;
		}

		@Override
		public void setFangan(int _v_) { // 装备等级
			fangan = _v_;
		}

		@Override
		public void setState(int _v_) { // 装备等级
			state = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Jingmai.Data)) return false;
			Jingmai.Data _o_ = (Jingmai.Data) _o1_;
			if (id != _o_.id) return false;
			if (qianyuandan != _o_.qianyuandan) return false;
			if (qiankundan != _o_.qiankundan) return false;
			if (fangan != _o_.fangan) return false;
			if (state != _o_.state) return false;
			if (!jingmais.equals(_o_.jingmais)) return false;
			if (!xingchen.equals(_o_.xingchen)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += qianyuandan;
			_h_ += qiankundan;
			_h_ += fangan;
			_h_ += state;
			_h_ += jingmais.hashCode();
			_h_ += xingchen.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(qianyuandan);
			_sb_.append(",");
			_sb_.append(qiankundan);
			_sb_.append(",");
			_sb_.append(fangan);
			_sb_.append(",");
			_sb_.append(state);
			_sb_.append(",");
			_sb_.append(jingmais);
			_sb_.append(",");
			_sb_.append(xingchen);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
