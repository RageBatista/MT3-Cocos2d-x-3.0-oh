
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class PotentialExtra extends mkdb.XBean implements xbean.PotentialExtra {
	private java.util.HashMap<Integer, Integer> extramap; // 潜灵果额外属性 key=属性类型 value=属性值

	@Override
	public void _reset_unsafe_() {
		extramap.clear();
	}

	PotentialExtra(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		extramap = new java.util.HashMap<Integer, Integer>();
	}

	public PotentialExtra() {
		this(0, null, null);
	}

	public PotentialExtra(PotentialExtra _o_) {
		this(_o_, null, null);
	}

	PotentialExtra(xbean.PotentialExtra _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof PotentialExtra) assign((PotentialExtra)_o1_);
		else if (_o1_ instanceof PotentialExtra.Data) assign((PotentialExtra.Data)_o1_);
		else if (_o1_ instanceof PotentialExtra.Const) assign(((PotentialExtra.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(PotentialExtra _o_) {
		_o_._xdb_verify_unsafe_();
		extramap = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.extramap.entrySet())
			extramap.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(PotentialExtra.Data _o_) {
		extramap = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.extramap.entrySet())
			extramap.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.compact_uint32(extramap.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : extramap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				extramap = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				extramap.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.PotentialExtra copy() {
		_xdb_verify_unsafe_();
		return new PotentialExtra(this);
	}

	@Override
	public xbean.PotentialExtra toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.PotentialExtra toBean() {
		_xdb_verify_unsafe_();
		return new PotentialExtra(this); // same as copy()
	}

	@Override
	public xbean.PotentialExtra toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.PotentialExtra toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public java.util.Map<Integer, Integer> getExtramap() { // 潜灵果额外属性 key=属性类型 value=属性值
		_xdb_verify_unsafe_();
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "extramap"), extramap);
	}

	@Override
	public java.util.Map<Integer, Integer> getExtramapAsData() { // 潜灵果额外属性 key=属性类型 value=属性值
		_xdb_verify_unsafe_();
		java.util.Map<Integer, Integer> extramap;
		PotentialExtra _o_ = this;
		extramap = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.extramap.entrySet())
			extramap.put(_e_.getKey(), _e_.getValue());
		return extramap;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		PotentialExtra _o_ = null;
		if ( _o1_ instanceof PotentialExtra ) _o_ = (PotentialExtra)_o1_;
		else if ( _o1_ instanceof PotentialExtra.Const ) _o_ = ((PotentialExtra.Const)_o1_).nThis();
		else return false;
		if (!extramap.equals(_o_.extramap)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += extramap.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(extramap);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableMap().setVarName("extramap"));
		return lb;
	}

	private class Const implements xbean.PotentialExtra {
		PotentialExtra nThis() {
			return PotentialExtra.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.PotentialExtra copy() {
			return PotentialExtra.this.copy();
		}

		@Override
		public xbean.PotentialExtra toData() {
			return PotentialExtra.this.toData();
		}

		public xbean.PotentialExtra toBean() {
			return PotentialExtra.this.toBean();
		}

		@Override
		public xbean.PotentialExtra toDataIf() {
			return PotentialExtra.this.toDataIf();
		}

		public xbean.PotentialExtra toBeanIf() {
			return PotentialExtra.this.toBeanIf();
		}

		@Override
		public java.util.Map<Integer, Integer> getExtramap() { // 潜灵果额外属性 key=属性类型 value=属性值
			_xdb_verify_unsafe_();
			return mkdb.Consts.constMap(extramap);
		}

		@Override
		public java.util.Map<Integer, Integer> getExtramapAsData() { // 潜灵果额外属性 key=属性类型 value=属性值
			_xdb_verify_unsafe_();
			java.util.Map<Integer, Integer> extramap;
			PotentialExtra _o_ = PotentialExtra.this;
			extramap = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.extramap.entrySet())
				extramap.put(_e_.getKey(), _e_.getValue());
			return extramap;
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
			return PotentialExtra.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return PotentialExtra.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return PotentialExtra.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return PotentialExtra.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return PotentialExtra.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return PotentialExtra.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return PotentialExtra.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return PotentialExtra.this.hashCode();
		}

		@Override
		public String toString() {
			return PotentialExtra.this.toString();
		}

	}

	public static final class Data implements xbean.PotentialExtra {
		private java.util.HashMap<Integer, Integer> extramap; // 潜灵果额外属性 key=属性类型 value=属性值

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			extramap = new java.util.HashMap<Integer, Integer>();
		}

		Data(xbean.PotentialExtra _o1_) {
			if (_o1_ instanceof PotentialExtra) assign((PotentialExtra)_o1_);
			else if (_o1_ instanceof PotentialExtra.Data) assign((PotentialExtra.Data)_o1_);
			else if (_o1_ instanceof PotentialExtra.Const) assign(((PotentialExtra.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(PotentialExtra _o_) {
			extramap = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.extramap.entrySet())
				extramap.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(PotentialExtra.Data _o_) {
			extramap = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.extramap.entrySet())
				extramap.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(extramap.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : extramap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					extramap = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					extramap.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.PotentialExtra copy() {
			return new Data(this);
		}

		@Override
		public xbean.PotentialExtra toData() {
			return new Data(this);
		}

		public xbean.PotentialExtra toBean() {
			return new PotentialExtra(this, null, null);
		}

		@Override
		public xbean.PotentialExtra toDataIf() {
			return this;
		}

		public xbean.PotentialExtra toBeanIf() {
			return new PotentialExtra(this, null, null);
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
		public java.util.Map<Integer, Integer> getExtramap() { // 潜灵果额外属性 key=属性类型 value=属性值
			return extramap;
		}

		@Override
		public java.util.Map<Integer, Integer> getExtramapAsData() { // 潜灵果额外属性 key=属性类型 value=属性值
			return extramap;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof PotentialExtra.Data)) return false;
			PotentialExtra.Data _o_ = (PotentialExtra.Data) _o1_;
			if (!extramap.equals(_o_.extramap)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += extramap.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(extramap);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
