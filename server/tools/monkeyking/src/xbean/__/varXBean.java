
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class varXBean extends mkdb.XBean implements xbean.varXBean {
	private int vint; // 
	private String vstring; // 
	private mkdb.util.SetX<Integer> vset; // 
	private java.util.HashMap<Integer, Integer> vmap; // 

	@Override
	public void _reset_unsafe_() {
		vint = 0;
		vstring = "";
		vset.clear();
		vmap.clear();
	}

	varXBean(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		vstring = "";
		vset = new mkdb.util.SetX<Integer>();
		vmap = new java.util.HashMap<Integer, Integer>();
	}

	public varXBean() {
		this(0, null, null);
	}

	public varXBean(varXBean _o_) {
		this(_o_, null, null);
	}

	varXBean(xbean.varXBean _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof varXBean) assign((varXBean)_o1_);
		else if (_o1_ instanceof varXBean.Data) assign((varXBean.Data)_o1_);
		else if (_o1_ instanceof varXBean.Const) assign(((varXBean.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(varXBean _o_) {
		vint = _o_.vint;
		vstring = _o_.vstring;
		vset = new mkdb.util.SetX<Integer>();
		vset.addAll(_o_.vset);
		vmap = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(varXBean.Data _o_) {
		vint = _o_.vint;
		vstring = _o_.vstring;
		vset = new mkdb.util.SetX<Integer>();
		vset.addAll(_o_.vset);
		vmap = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(vint);
		_os_.marshal(vstring, mkdb.Const.IO_CHARSET);
		_os_.compact_uint32(vset.size());
		for (Integer _v_ : vset) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(vmap.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : vmap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		vint = _os_.unmarshal_int();
		vstring = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			vset.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				vmap = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				vmap.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.varXBean copy() {
		return new varXBean(this);
	}

	@Override
	public xbean.varXBean toData() {
		return new Data(this);
	}

	public xbean.varXBean toBean() {
		return new varXBean(this); // same as copy()
	}

	@Override
	public xbean.varXBean toDataIf() {
		return new Data(this);
	}

	public xbean.varXBean toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getVint() { // 
		return vint;
	}

	@Override
	public String getVstring() { // 
		return vstring;
	}

	@Override
	public com.locojoy.base.Octets getVstringOctets() { // 
		return com.locojoy.base.Octets.wrap(getVstring(), mkdb.Const.IO_CHARSET);
	}

	@Override
	public java.util.Set<Integer> getVset() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "vset"), vset);
	}

	public java.util.Set<Integer> getVsetAsData() { // 
		java.util.Set<Integer> vset;
		varXBean _o_ = this;
		vset = new mkdb.util.SetX<Integer>();
		vset.addAll(_o_.vset);
		return vset;
	}

	@Override
	public java.util.Map<Integer, Integer> getVmap() { // 
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "vmap"), vmap);
	}

	@Override
	public java.util.Map<Integer, Integer> getVmapAsData() { // 
		java.util.Map<Integer, Integer> vmap;
		varXBean _o_ = this;
		vmap = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), _e_.getValue());
		return vmap;
	}

	@Override
	public void setVint(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vint") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, vint) {
					public void rollback() { vint = _xdb_saved; }
				};}});
		vint = _v_;
	}

	@Override
	public void setVstring(String _v_) { // 
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vstring") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, vstring) {
					public void rollback() { vstring = _xdb_saved; }
				};}});
		vstring = _v_;
	}

	@Override
	public void setVstringOctets(com.locojoy.base.Octets _v_) { // 
		this.setVstring(_v_.getString(mkdb.Const.IO_CHARSET));
	}

	@Override
	public final boolean equals(Object _o1_) {
		varXBean _o_ = null;
		if ( _o1_ instanceof varXBean ) _o_ = (varXBean)_o1_;
		else if ( _o1_ instanceof varXBean.Const ) _o_ = ((varXBean.Const)_o1_).nThis();
		else return false;
		if (vint != _o_.vint) return false;
		if (!vstring.equals(_o_.vstring)) return false;
		if (!vset.equals(_o_.vset)) return false;
		if (!vmap.equals(_o_.vmap)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += vint;
		_h_ += vstring.hashCode();
		_h_ += vset.hashCode();
		_h_ += vmap.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(vint);
		_sb_.append(",");
		_sb_.append("'").append(vstring).append("'");
		_sb_.append(",");
		_sb_.append(vset);
		_sb_.append(",");
		_sb_.append(vmap);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vint"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vstring"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("vset"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("vmap"));
		return lb;
	}

	private class Const implements xbean.varXBean {
		varXBean nThis() {
			return varXBean.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.varXBean copy() {
			return varXBean.this.copy();
		}

		@Override
		public xbean.varXBean toData() {
			return varXBean.this.toData();
		}

		public xbean.varXBean toBean() {
			return varXBean.this.toBean();
		}

		@Override
		public xbean.varXBean toDataIf() {
			return varXBean.this.toDataIf();
		}

		public xbean.varXBean toBeanIf() {
			return varXBean.this.toBeanIf();
		}

		@Override
		public int getVint() { // 
			return vint;
		}

		@Override
		public String getVstring() { // 
			return vstring;
		}

		@Override
		public com.locojoy.base.Octets getVstringOctets() { // 
			return varXBean.this.getVstringOctets();
		}

		@Override
		public java.util.Set<Integer> getVset() { // 
			return mkdb.Consts.constSet(vset);
		}

		public java.util.Set<Integer> getVsetAsData() { // 
			java.util.Set<Integer> vset;
			varXBean _o_ = varXBean.this;
		vset = new mkdb.util.SetX<Integer>();
		vset.addAll(_o_.vset);
			return vset;
		}

		@Override
		public java.util.Map<Integer, Integer> getVmap() { // 
			return mkdb.Consts.constMap(vmap);
		}

		@Override
		public java.util.Map<Integer, Integer> getVmapAsData() { // 
			java.util.Map<Integer, Integer> vmap;
			varXBean _o_ = varXBean.this;
			vmap = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), _e_.getValue());
			return vmap;
		}

		@Override
		public void setVint(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setVstring(String _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setVstringOctets(com.locojoy.base.Octets _v_) { // 
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
			return varXBean.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return varXBean.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return varXBean.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return varXBean.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return varXBean.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return varXBean.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return varXBean.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return varXBean.this.hashCode();
		}

		@Override
		public String toString() {
			return varXBean.this.toString();
		}

	}

	public static final class Data implements xbean.varXBean {
		private int vint; // 
		private String vstring; // 
		private java.util.HashSet<Integer> vset; // 
		private java.util.HashMap<Integer, Integer> vmap; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			vstring = "";
			vset = new java.util.HashSet<Integer>();
			vmap = new java.util.HashMap<Integer, Integer>();
		}

		Data(xbean.varXBean _o1_) {
			if (_o1_ instanceof varXBean) assign((varXBean)_o1_);
			else if (_o1_ instanceof varXBean.Data) assign((varXBean.Data)_o1_);
			else if (_o1_ instanceof varXBean.Const) assign(((varXBean.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(varXBean _o_) {
			vint = _o_.vint;
			vstring = _o_.vstring;
			vset = new java.util.HashSet<Integer>();
			vset.addAll(_o_.vset);
			vmap = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(varXBean.Data _o_) {
			vint = _o_.vint;
			vstring = _o_.vstring;
			vset = new java.util.HashSet<Integer>();
			vset.addAll(_o_.vset);
			vmap = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(vint);
			_os_.marshal(vstring, mkdb.Const.IO_CHARSET);
			_os_.compact_uint32(vset.size());
			for (Integer _v_ : vset) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(vmap.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : vmap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			vint = _os_.unmarshal_int();
			vstring = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				vset.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					vmap = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					vmap.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.varXBean copy() {
			return new Data(this);
		}

		@Override
		public xbean.varXBean toData() {
			return new Data(this);
		}

		public xbean.varXBean toBean() {
			return new varXBean(this, null, null);
		}

		@Override
		public xbean.varXBean toDataIf() {
			return this;
		}

		public xbean.varXBean toBeanIf() {
			return new varXBean(this, null, null);
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
		public int getVint() { // 
			return vint;
		}

		@Override
		public String getVstring() { // 
			return vstring;
		}

		@Override
		public com.locojoy.base.Octets getVstringOctets() { // 
			return com.locojoy.base.Octets.wrap(getVstring(), mkdb.Const.IO_CHARSET);
		}

		@Override
		public java.util.Set<Integer> getVset() { // 
			return vset;
		}

		@Override
		public java.util.Set<Integer> getVsetAsData() { // 
			return vset;
		}

		@Override
		public java.util.Map<Integer, Integer> getVmap() { // 
			return vmap;
		}

		@Override
		public java.util.Map<Integer, Integer> getVmapAsData() { // 
			return vmap;
		}

		@Override
		public void setVint(int _v_) { // 
			vint = _v_;
		}

		@Override
		public void setVstring(String _v_) { // 
			if (null == _v_)
				throw new NullPointerException();
			vstring = _v_;
		}

		@Override
		public void setVstringOctets(com.locojoy.base.Octets _v_) { // 
			this.setVstring(_v_.getString(mkdb.Const.IO_CHARSET));
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof varXBean.Data)) return false;
			varXBean.Data _o_ = (varXBean.Data) _o1_;
			if (vint != _o_.vint) return false;
			if (!vstring.equals(_o_.vstring)) return false;
			if (!vset.equals(_o_.vset)) return false;
			if (!vmap.equals(_o_.vmap)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += vint;
			_h_ += vstring.hashCode();
			_h_ += vset.hashCode();
			_h_ += vmap.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(vint);
			_sb_.append(",");
			_sb_.append("'").append(vstring).append("'");
			_sb_.append(",");
			_sb_.append(vset);
			_sb_.append(",");
			_sb_.append(vmap);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
