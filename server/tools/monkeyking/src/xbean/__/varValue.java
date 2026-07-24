
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class varValue extends mkdb.XBean implements xbean.varValue {
	private int vint; // 
	private String vstring; // 
	private short vshort; // 
	private boolean vbool; // 
	private long vlong; // 
	private byte [] vbinary; // 
	private xbean.xxx vxxx; // 
	private xbean.xxx vyyy; // 
	private java.util.HashMap<Integer, String> vmap; // 
	private mkdb.util.SetX<xbean.xxx> vset; // 
	private java.util.LinkedList<xbean.yyy> vlist; // 
	private java.util.ArrayList<Short> vvector; // 

	@Override
	public void _reset_unsafe_() {
		vint = 0;
		vstring = "i am string";
		vshort = 0;
		vbool = false;
		vlong = 0L;
		vbinary = new byte[0];
		vxxx._reset_unsafe_();
		vyyy._reset_unsafe_();
		vmap.clear();
		vset.clear();
		vlist.clear();
		vvector.clear();
	}

	varValue(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		vstring = "i am string";
		vbinary = new byte[0];
		vxxx = new xxx(0, this, "vxxx");
		vyyy = new xxx(0, this, "vyyy");
		vmap = new java.util.HashMap<Integer, String>();
		vset = new mkdb.util.SetX<xbean.xxx>();
		vlist = new java.util.LinkedList<xbean.yyy>();
		vvector = new java.util.ArrayList<Short>();
	}

	public varValue() {
		this(0, null, null);
	}

	public varValue(varValue _o_) {
		this(_o_, null, null);
	}

	varValue(xbean.varValue _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof varValue) assign((varValue)_o1_);
		else if (_o1_ instanceof varValue.Data) assign((varValue.Data)_o1_);
		else if (_o1_ instanceof varValue.Const) assign(((varValue.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(varValue _o_) {
		vint = _o_.vint;
		vstring = _o_.vstring;
		vshort = _o_.vshort;
		vbool = _o_.vbool;
		vlong = _o_.vlong;
		vbinary = java.util.Arrays.copyOf(_o_.vbinary, _o_.vbinary.length);
		vxxx = new xxx(_o_.vxxx, this, "vxxx");
		vyyy = new xxx(_o_.vyyy, this, "vyyy");
		vmap = new java.util.HashMap<Integer, String>();
		for (java.util.Map.Entry<Integer, String> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), _e_.getValue());
		vset = new mkdb.util.SetX<xbean.xxx>();
		for (xbean.xxx _v_ : _o_.vset)
			vset.add(new xxx(_v_, this, "vset"));
		vlist = new java.util.LinkedList<xbean.yyy>();
		for (xbean.yyy _v_ : _o_.vlist)
			vlist.add(new yyy(_v_, this, "vlist"));
		vvector = new java.util.ArrayList<Short>();
		vvector.addAll(_o_.vvector);
	}

	private void assign(varValue.Data _o_) {
		vint = _o_.vint;
		vstring = _o_.vstring;
		vshort = _o_.vshort;
		vbool = _o_.vbool;
		vlong = _o_.vlong;
		vbinary = java.util.Arrays.copyOf(_o_.vbinary, _o_.vbinary.length);
		vxxx = new xxx(_o_.vxxx, this, "vxxx");
		vyyy = new xxx(_o_.vyyy, this, "vyyy");
		vmap = new java.util.HashMap<Integer, String>();
		for (java.util.Map.Entry<Integer, String> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), _e_.getValue());
		vset = new mkdb.util.SetX<xbean.xxx>();
		for (xbean.xxx _v_ : _o_.vset)
			vset.add(new xxx(_v_, this, "vset"));
		vlist = new java.util.LinkedList<xbean.yyy>();
		for (xbean.yyy _v_ : _o_.vlist)
			vlist.add(new yyy(_v_, this, "vlist"));
		vvector = new java.util.ArrayList<Short>();
		vvector.addAll(_o_.vvector);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(vint);
		_os_.marshal(vstring, mkdb.Const.IO_CHARSET);
		_os_.marshal(vshort);
		_os_.marshal(vbool);
		_os_.marshal(vlong);
		_os_.marshal(vbinary);
		vxxx.marshal(_os_);
		vyyy.marshal(_os_);
		_os_.compact_uint32(vmap.size());
		for (java.util.Map.Entry<Integer, String> _e_ : vmap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue(), mkdb.Const.IO_CHARSET);
		}
		_os_.compact_uint32(vset.size());
		for (xbean.xxx _v_ : vset) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(vlist.size());
		for (xbean.yyy _v_ : vlist) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(vvector.size());
		for (Short _v_ : vvector) {
			_os_.marshal(_v_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		vint = _os_.unmarshal_int();
		vstring = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		vshort = _os_.unmarshal_short();
		vbool = _os_.unmarshal_boolean();
		vlong = _os_.unmarshal_long();
		vbinary = _os_.unmarshal_bytes();
		vxxx.unmarshal(_os_);
		vyyy.unmarshal(_os_);
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				vmap = new java.util.HashMap<Integer, String>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				String _v_ = "";
				_v_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
				vmap.put(_k_, _v_);
			}
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.xxx _v_ = new xxx(0, this, "vset");
			_v_.unmarshal(_os_);
			vset.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.yyy _v_ = new yyy(0, this, "vlist");
			_v_.unmarshal(_os_);
			vlist.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			short _v_ = 0;
			_v_ = _os_.unmarshal_short();
			vvector.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.varValue copy() {
		return new varValue(this);
	}

	@Override
	public xbean.varValue toData() {
		return new Data(this);
	}

	public xbean.varValue toBean() {
		return new varValue(this); // same as copy()
	}

	@Override
	public xbean.varValue toDataIf() {
		return new Data(this);
	}

	public xbean.varValue toBeanIf() {
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
	public short getVshort() { // 
		return vshort;
	}

	@Override
	public boolean getVbool() { // 
		return vbool;
	}

	@Override
	public long getVlong() { // 
		return vlong;
	}

	@Override
	public <T extends com.locojoy.base.Marshal.Marshal> T getVbinary(T _v_) { // 
		try {
			_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(vbinary)));
			return _v_;
		} catch (MarshalException _e_) {
			throw new mkio.MarshalError();
		}
	}

	@Override
	public boolean isVbinaryEmpty() { // 
		return vbinary.length == 0;
	}

	@Override
	public byte[] getVbinaryCopy() { // 
		return java.util.Arrays.copyOf(vbinary, vbinary.length);
	}

	@Override
	public xbean.xxx getVxxx() { // 
		return vxxx;
	}

	@Override
	public xbean.xxx getVyyy() { // 
		return vyyy;
	}

	@Override
	public java.util.Map<Integer, String> getVmap() { // 
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "vmap"), vmap);
	}

	@Override
	public java.util.Map<Integer, String> getVmapAsData() { // 
		java.util.Map<Integer, String> vmap;
		varValue _o_ = this;
		vmap = new java.util.HashMap<Integer, String>();
		for (java.util.Map.Entry<Integer, String> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), _e_.getValue());
		return vmap;
	}

	@Override
	public java.util.Set<xbean.xxx> getVset() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "vset"), vset);
	}

	public java.util.Set<xbean.xxx> getVsetAsData() { // 
		java.util.Set<xbean.xxx> vset;
		varValue _o_ = this;
		vset = new mkdb.util.SetX<xbean.xxx>();
		for (xbean.xxx _v_ : _o_.vset)
			vset.add(new xxx.Data(_v_));
		return vset;
	}

	@Override
	public java.util.List<xbean.yyy> getVlist() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "vlist"), vlist);
	}

	public java.util.List<xbean.yyy> getVlistAsData() { // 
		java.util.List<xbean.yyy> vlist;
		varValue _o_ = this;
		vlist = new java.util.LinkedList<xbean.yyy>();
		for (xbean.yyy _v_ : _o_.vlist)
			vlist.add(new yyy.Data(_v_));
		return vlist;
	}

	@Override
	public java.util.List<Short> getVvector() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "vvector"), vvector);
	}

	public java.util.List<Short> getVvectorAsData() { // 
		java.util.List<Short> vvector;
		varValue _o_ = this;
		vvector = new java.util.ArrayList<Short>();
		vvector.addAll(_o_.vvector);
		return vvector;
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
	public void setVshort(short _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vshort") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogShort(this, vshort) {
					public void rollback() { vshort = _xdb_saved; }
				};}});
		vshort = _v_;
	}

	@Override
	public void setVbool(boolean _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vbool") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<Boolean>(this, vbool) {
					public void rollback() { vbool = _xdb_saved; }
				};}});
		vbool = _v_;
	}

	@Override
	public void setVlong(long _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vlong") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, vlong) {
					public void rollback() { vlong = _xdb_saved; }
				};}});
		vlong = _v_;
	}

	@Override
	public void setVbinary(com.locojoy.base.Marshal.Marshal _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vbinary") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, vbinary) {
					public void rollback() { vbinary = _xdb_saved; }
			}; }});
		vbinary = _v_.marshal(new OctetsStream()).getBytes();
	}

	@Override
	public void setVbinaryCopy(byte[] _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "vbinary") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, vbinary) {
					public void rollback() { vbinary = _xdb_saved; }
			}; }});
		vbinary = java.util.Arrays.copyOf(_v_, _v_.length);
	}

	@Override
	public final boolean equals(Object _o1_) {
		varValue _o_ = null;
		if ( _o1_ instanceof varValue ) _o_ = (varValue)_o1_;
		else if ( _o1_ instanceof varValue.Const ) _o_ = ((varValue.Const)_o1_).nThis();
		else return false;
		if (vint != _o_.vint) return false;
		if (!vstring.equals(_o_.vstring)) return false;
		if (vshort != _o_.vshort) return false;
		if (vbool != _o_.vbool) return false;
		if (vlong != _o_.vlong) return false;
		if (!java.util.Arrays.equals(vbinary, _o_.vbinary)) return false;
		if (!vxxx.equals(_o_.vxxx)) return false;
		if (!vyyy.equals(_o_.vyyy)) return false;
		if (!vmap.equals(_o_.vmap)) return false;
		if (!vset.equals(_o_.vset)) return false;
		if (!vlist.equals(_o_.vlist)) return false;
		if (!vvector.equals(_o_.vvector)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += vint;
		_h_ += vstring.hashCode();
		_h_ += vshort;
		_h_ += vbool ? 1231 : 1237;
		_h_ += vlong;
		_h_ += java.util.Arrays.hashCode(vbinary);
		_h_ += vxxx.hashCode();
		_h_ += vyyy.hashCode();
		_h_ += vmap.hashCode();
		_h_ += vset.hashCode();
		_h_ += vlist.hashCode();
		_h_ += vvector.hashCode();
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
		_sb_.append(vshort);
		_sb_.append(",");
		_sb_.append(vbool);
		_sb_.append(",");
		_sb_.append(vlong);
		_sb_.append(",");
		_sb_.append('B').append(vbinary.length);
		_sb_.append(",");
		_sb_.append(vxxx);
		_sb_.append(",");
		_sb_.append(vyyy);
		_sb_.append(",");
		_sb_.append(vmap);
		_sb_.append(",");
		_sb_.append(vset);
		_sb_.append(",");
		_sb_.append(vlist);
		_sb_.append(",");
		_sb_.append(vvector);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vint"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vstring"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vshort"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vbool"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vlong"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vbinary"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vxxx"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vyyy"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("vmap"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("vset"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vlist"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vvector"));
		return lb;
	}

	private class Const implements xbean.varValue {
		varValue nThis() {
			return varValue.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.varValue copy() {
			return varValue.this.copy();
		}

		@Override
		public xbean.varValue toData() {
			return varValue.this.toData();
		}

		public xbean.varValue toBean() {
			return varValue.this.toBean();
		}

		@Override
		public xbean.varValue toDataIf() {
			return varValue.this.toDataIf();
		}

		public xbean.varValue toBeanIf() {
			return varValue.this.toBeanIf();
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
			return varValue.this.getVstringOctets();
		}

		@Override
		public short getVshort() { // 
			return vshort;
		}

		@Override
		public boolean getVbool() { // 
			return vbool;
		}

		@Override
		public long getVlong() { // 
			return vlong;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getVbinary(T _v_) { // 
			return varValue.this.getVbinary(_v_);
		}

		@Override
		public boolean isVbinaryEmpty() { // 
			return varValue.this.isVbinaryEmpty();
		}

		@Override
		public byte[] getVbinaryCopy() { // 
			return varValue.this.getVbinaryCopy();
		}

		@Override
		public xbean.xxx getVxxx() { // 
			return mkdb.Consts.toConst(vxxx);
		}

		@Override
		public xbean.xxx getVyyy() { // 
			return mkdb.Consts.toConst(vyyy);
		}

		@Override
		public java.util.Map<Integer, String> getVmap() { // 
			return mkdb.Consts.constMap(vmap);
		}

		@Override
		public java.util.Map<Integer, String> getVmapAsData() { // 
			java.util.Map<Integer, String> vmap;
			varValue _o_ = varValue.this;
			vmap = new java.util.HashMap<Integer, String>();
			for (java.util.Map.Entry<Integer, String> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), _e_.getValue());
			return vmap;
		}

		@Override
		public java.util.Set<xbean.xxx> getVset() { // 
			return mkdb.Consts.constSet(vset);
		}

		public java.util.Set<xbean.xxx> getVsetAsData() { // 
			java.util.Set<xbean.xxx> vset;
			varValue _o_ = varValue.this;
		vset = new mkdb.util.SetX<xbean.xxx>();
		for (xbean.xxx _v_ : _o_.vset)
			vset.add(new xxx.Data(_v_));
			return vset;
		}

		@Override
		public java.util.List<xbean.yyy> getVlist() { // 
			return mkdb.Consts.constList(vlist);
		}

		public java.util.List<xbean.yyy> getVlistAsData() { // 
			java.util.List<xbean.yyy> vlist;
			varValue _o_ = varValue.this;
		vlist = new java.util.LinkedList<xbean.yyy>();
		for (xbean.yyy _v_ : _o_.vlist)
			vlist.add(new yyy.Data(_v_));
			return vlist;
		}

		@Override
		public java.util.List<Short> getVvector() { // 
			return mkdb.Consts.constList(vvector);
		}

		public java.util.List<Short> getVvectorAsData() { // 
			java.util.List<Short> vvector;
			varValue _o_ = varValue.this;
		vvector = new java.util.ArrayList<Short>();
		vvector.addAll(_o_.vvector);
			return vvector;
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
		public void setVshort(short _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setVbool(boolean _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setVlong(long _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setVbinary(com.locojoy.base.Marshal.Marshal _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setVbinaryCopy(byte[] _v_) { // 
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
			return varValue.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return varValue.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return varValue.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return varValue.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return varValue.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return varValue.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return varValue.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return varValue.this.hashCode();
		}

		@Override
		public String toString() {
			return varValue.this.toString();
		}

	}

	public static final class Data implements xbean.varValue {
		private int vint; // 
		private String vstring; // 
		private short vshort; // 
		private boolean vbool; // 
		private long vlong; // 
		private byte [] vbinary; // 
		private xbean.xxx vxxx; // 
		private xbean.xxx vyyy; // 
		private java.util.HashMap<Integer, String> vmap; // 
		private java.util.HashSet<xbean.xxx> vset; // 
		private java.util.LinkedList<xbean.yyy> vlist; // 
		private java.util.ArrayList<Short> vvector; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			vstring = "i am string";
			vbinary = new byte[0];
			vxxx = new xxx.Data();
			vyyy = new xxx.Data();
			vmap = new java.util.HashMap<Integer, String>();
			vset = new java.util.HashSet<xbean.xxx>();
			vlist = new java.util.LinkedList<xbean.yyy>();
			vvector = new java.util.ArrayList<Short>();
		}

		Data(xbean.varValue _o1_) {
			if (_o1_ instanceof varValue) assign((varValue)_o1_);
			else if (_o1_ instanceof varValue.Data) assign((varValue.Data)_o1_);
			else if (_o1_ instanceof varValue.Const) assign(((varValue.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(varValue _o_) {
			vint = _o_.vint;
			vstring = _o_.vstring;
			vshort = _o_.vshort;
			vbool = _o_.vbool;
			vlong = _o_.vlong;
			vbinary = java.util.Arrays.copyOf(_o_.vbinary, _o_.vbinary.length);
			vxxx = new xxx.Data(_o_.vxxx);
			vyyy = new xxx.Data(_o_.vyyy);
			vmap = new java.util.HashMap<Integer, String>();
			for (java.util.Map.Entry<Integer, String> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), _e_.getValue());
			vset = new java.util.HashSet<xbean.xxx>();
			for (xbean.xxx _v_ : _o_.vset)
				vset.add(new xxx.Data(_v_));
			vlist = new java.util.LinkedList<xbean.yyy>();
			for (xbean.yyy _v_ : _o_.vlist)
				vlist.add(new yyy.Data(_v_));
			vvector = new java.util.ArrayList<Short>();
			vvector.addAll(_o_.vvector);
		}

		private void assign(varValue.Data _o_) {
			vint = _o_.vint;
			vstring = _o_.vstring;
			vshort = _o_.vshort;
			vbool = _o_.vbool;
			vlong = _o_.vlong;
			vbinary = java.util.Arrays.copyOf(_o_.vbinary, _o_.vbinary.length);
			vxxx = new xxx.Data(_o_.vxxx);
			vyyy = new xxx.Data(_o_.vyyy);
			vmap = new java.util.HashMap<Integer, String>();
			for (java.util.Map.Entry<Integer, String> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), _e_.getValue());
			vset = new java.util.HashSet<xbean.xxx>();
			for (xbean.xxx _v_ : _o_.vset)
				vset.add(new xxx.Data(_v_));
			vlist = new java.util.LinkedList<xbean.yyy>();
			for (xbean.yyy _v_ : _o_.vlist)
				vlist.add(new yyy.Data(_v_));
			vvector = new java.util.ArrayList<Short>();
			vvector.addAll(_o_.vvector);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(vint);
			_os_.marshal(vstring, mkdb.Const.IO_CHARSET);
			_os_.marshal(vshort);
			_os_.marshal(vbool);
			_os_.marshal(vlong);
			_os_.marshal(vbinary);
			vxxx.marshal(_os_);
			vyyy.marshal(_os_);
			_os_.compact_uint32(vmap.size());
			for (java.util.Map.Entry<Integer, String> _e_ : vmap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue(), mkdb.Const.IO_CHARSET);
			}
			_os_.compact_uint32(vset.size());
			for (xbean.xxx _v_ : vset) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(vlist.size());
			for (xbean.yyy _v_ : vlist) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(vvector.size());
			for (Short _v_ : vvector) {
				_os_.marshal(_v_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			vint = _os_.unmarshal_int();
			vstring = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			vshort = _os_.unmarshal_short();
			vbool = _os_.unmarshal_boolean();
			vlong = _os_.unmarshal_long();
			vbinary = _os_.unmarshal_bytes();
			vxxx.unmarshal(_os_);
			vyyy.unmarshal(_os_);
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					vmap = new java.util.HashMap<Integer, String>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					String _v_ = "";
					_v_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
					vmap.put(_k_, _v_);
				}
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.xxx _v_ = xbean.Pod.newxxxData();
				_v_.unmarshal(_os_);
				vset.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.yyy _v_ = xbean.Pod.newyyyData();
				_v_.unmarshal(_os_);
				vlist.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				short _v_ = 0;
				_v_ = _os_.unmarshal_short();
				vvector.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.varValue copy() {
			return new Data(this);
		}

		@Override
		public xbean.varValue toData() {
			return new Data(this);
		}

		public xbean.varValue toBean() {
			return new varValue(this, null, null);
		}

		@Override
		public xbean.varValue toDataIf() {
			return this;
		}

		public xbean.varValue toBeanIf() {
			return new varValue(this, null, null);
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
		public short getVshort() { // 
			return vshort;
		}

		@Override
		public boolean getVbool() { // 
			return vbool;
		}

		@Override
		public long getVlong() { // 
			return vlong;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getVbinary(T _v_) { // 
			try {
				_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(vbinary)));
				return _v_;
			} catch (MarshalException _e_) {
				throw new mkio.MarshalError();
			}
		}

		@Override
		public boolean isVbinaryEmpty() { // 
			return vbinary.length == 0;
		}

		@Override
		public byte[] getVbinaryCopy() { // 
			return java.util.Arrays.copyOf(vbinary, vbinary.length);
		}

		@Override
		public xbean.xxx getVxxx() { // 
			return vxxx;
		}

		@Override
		public xbean.xxx getVyyy() { // 
			return vyyy;
		}

		@Override
		public java.util.Map<Integer, String> getVmap() { // 
			return vmap;
		}

		@Override
		public java.util.Map<Integer, String> getVmapAsData() { // 
			return vmap;
		}

		@Override
		public java.util.Set<xbean.xxx> getVset() { // 
			return vset;
		}

		@Override
		public java.util.Set<xbean.xxx> getVsetAsData() { // 
			return vset;
		}

		@Override
		public java.util.List<xbean.yyy> getVlist() { // 
			return vlist;
		}

		@Override
		public java.util.List<xbean.yyy> getVlistAsData() { // 
			return vlist;
		}

		@Override
		public java.util.List<Short> getVvector() { // 
			return vvector;
		}

		@Override
		public java.util.List<Short> getVvectorAsData() { // 
			return vvector;
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
		public void setVshort(short _v_) { // 
			vshort = _v_;
		}

		@Override
		public void setVbool(boolean _v_) { // 
			vbool = _v_;
		}

		@Override
		public void setVlong(long _v_) { // 
			vlong = _v_;
		}

		@Override
		public void setVbinary(com.locojoy.base.Marshal.Marshal _v_) { // 
			vbinary = _v_.marshal(new OctetsStream()).getBytes();
		}

		@Override
		public void setVbinaryCopy(byte[] _v_) { // 
			vbinary = java.util.Arrays.copyOf(_v_, _v_.length);
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof varValue.Data)) return false;
			varValue.Data _o_ = (varValue.Data) _o1_;
			if (vint != _o_.vint) return false;
			if (!vstring.equals(_o_.vstring)) return false;
			if (vshort != _o_.vshort) return false;
			if (vbool != _o_.vbool) return false;
			if (vlong != _o_.vlong) return false;
			if (!java.util.Arrays.equals(vbinary, _o_.vbinary)) return false;
			if (!vxxx.equals(_o_.vxxx)) return false;
			if (!vyyy.equals(_o_.vyyy)) return false;
			if (!vmap.equals(_o_.vmap)) return false;
			if (!vset.equals(_o_.vset)) return false;
			if (!vlist.equals(_o_.vlist)) return false;
			if (!vvector.equals(_o_.vvector)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += vint;
			_h_ += vstring.hashCode();
			_h_ += vshort;
			_h_ += vbool ? 1231 : 1237;
			_h_ += vlong;
			_h_ += java.util.Arrays.hashCode(vbinary);
			_h_ += vxxx.hashCode();
			_h_ += vyyy.hashCode();
			_h_ += vmap.hashCode();
			_h_ += vset.hashCode();
			_h_ += vlist.hashCode();
			_h_ += vvector.hashCode();
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
			_sb_.append(vshort);
			_sb_.append(",");
			_sb_.append(vbool);
			_sb_.append(",");
			_sb_.append(vlong);
			_sb_.append(",");
			_sb_.append('B').append(vbinary.length);
			_sb_.append(",");
			_sb_.append(vxxx);
			_sb_.append(",");
			_sb_.append(vyyy);
			_sb_.append(",");
			_sb_.append(vmap);
			_sb_.append(",");
			_sb_.append(vset);
			_sb_.append(",");
			_sb_.append(vlist);
			_sb_.append(",");
			_sb_.append(vvector);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
