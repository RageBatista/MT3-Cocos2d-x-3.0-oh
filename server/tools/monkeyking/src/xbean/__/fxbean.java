
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class fxbean extends mkdb.XBean implements xbean.fxbean {
	private mkdb.util.SetX<Boolean> a; // 
	private java.util.LinkedList<xbean.fcbean> b; // 
	private java.util.ArrayList<Float> c; // 
	private java.util.HashMap<Integer, xbean.fcbean> d; // 
	private java.util.TreeMap<String, Short> e; // 
	private xbean.fxbean0 f; // 
	private int g; // 
	private byte [] h; // 

	@Override
	public void _reset_unsafe_() {
		a.clear();
		b.clear();
		c.clear();
		d.clear();
		e.clear();
		f._reset_unsafe_();
		g = 1;
		h = new byte[0];
	}

	fxbean(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		a = new mkdb.util.SetX<Boolean>();
		b = new java.util.LinkedList<xbean.fcbean>();
		c = new java.util.ArrayList<Float>();
		d = new java.util.HashMap<Integer, xbean.fcbean>();
		e = new java.util.TreeMap<String, Short>();
		f = new fxbean0(0, this, "f");
		g = 1;
		h = new byte[0];
	}

	public fxbean() {
		this(0, null, null);
	}

	public fxbean(fxbean _o_) {
		this(_o_, null, null);
	}

	fxbean(xbean.fxbean _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof fxbean) assign((fxbean)_o1_);
		else if (_o1_ instanceof fxbean.Data) assign((fxbean.Data)_o1_);
		else if (_o1_ instanceof fxbean.Const) assign(((fxbean.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(fxbean _o_) {
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
		c = new java.util.ArrayList<Float>();
		c.addAll(_o_.c);
		d = new java.util.HashMap<Integer, xbean.fcbean>();
		for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : _o_.d.entrySet())
			d.put(_e_.getKey(), _e_.getValue());
		e = new java.util.TreeMap<String, Short>();
		for (java.util.Map.Entry<String, Short> _e_ : _o_.e.entrySet())
			e.put(_e_.getKey(), _e_.getValue());
		f = new fxbean0(_o_.f, this, "f");
		g = _o_.g;
		h = java.util.Arrays.copyOf(_o_.h, _o_.h.length);
	}

	private void assign(fxbean.Data _o_) {
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
		c = new java.util.ArrayList<Float>();
		c.addAll(_o_.c);
		d = new java.util.HashMap<Integer, xbean.fcbean>();
		for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : _o_.d.entrySet())
			d.put(_e_.getKey(), _e_.getValue());
		e = new java.util.TreeMap<String, Short>();
		for (java.util.Map.Entry<String, Short> _e_ : _o_.e.entrySet())
			e.put(_e_.getKey(), _e_.getValue());
		f = new fxbean0(_o_.f, this, "f");
		g = _o_.g;
		h = java.util.Arrays.copyOf(_o_.h, _o_.h.length);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(a.size());
		for (Boolean _v_ : a) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(b.size());
		for (xbean.fcbean _v_ : b) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(c.size());
		for (Float _v_ : c) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(d.size());
		for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : d.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		_os_.compact_uint32(e.size());
		for (java.util.Map.Entry<String, Short> _e_ : e.entrySet())
		{
			_os_.marshal(_e_.getKey(), mkdb.Const.IO_CHARSET);
			_os_.marshal(_e_.getValue());
		}
		f.marshal(_os_);
		_os_.marshal(g);
		_os_.marshal(h);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			boolean _v_ = false;
			_v_ = _os_.unmarshal_boolean();
			a.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.fcbean _v_ = new xbean.fcbean();
			_v_.unmarshal(_os_);
			b.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			float _v_ = 0.0f;
			_v_ = _os_.unmarshal_float();
			c.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				d = new java.util.HashMap<Integer, xbean.fcbean>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.fcbean _v_ = new xbean.fcbean();
				_v_.unmarshal(_os_);
				d.put(_k_, _v_);
			}
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size)
		{
			String _k_ = "";
			_k_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			short _v_ = 0;
			_v_ = _os_.unmarshal_short();
			e.put(_k_, _v_);
		}
		f.unmarshal(_os_);
		g = _os_.unmarshal_int();
		h = _os_.unmarshal_bytes();
		return _os_;
	}

	@Override
	public xbean.fxbean copy() {
		return new fxbean(this);
	}

	@Override
	public xbean.fxbean toData() {
		return new Data(this);
	}

	public xbean.fxbean toBean() {
		return new fxbean(this); // same as copy()
	}

	@Override
	public xbean.fxbean toDataIf() {
		return new Data(this);
	}

	public xbean.fxbean toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Set<Boolean> getA() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "a"), a);
	}

	public java.util.Set<Boolean> getAAsData() { // 
		java.util.Set<Boolean> a;
		fxbean _o_ = this;
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
		return a;
	}

	@Override
	public java.util.List<xbean.fcbean> getB() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "b"), b);
	}

	public java.util.List<xbean.fcbean> getBAsData() { // 
		java.util.List<xbean.fcbean> b;
		fxbean _o_ = this;
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
		return b;
	}

	@Override
	public java.util.List<Float> getC() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "c"), c);
	}

	public java.util.List<Float> getCAsData() { // 
		java.util.List<Float> c;
		fxbean _o_ = this;
		c = new java.util.ArrayList<Float>();
		c.addAll(_o_.c);
		return c;
	}

	@Override
	public java.util.Map<Integer, xbean.fcbean> getD() { // 
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "d"), d);
	}

	@Override
	public java.util.Map<Integer, xbean.fcbean> getDAsData() { // 
		java.util.Map<Integer, xbean.fcbean> d;
		fxbean _o_ = this;
		d = new java.util.HashMap<Integer, xbean.fcbean>();
		for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : _o_.d.entrySet())
			d.put(_e_.getKey(), _e_.getValue());
		return d;
	}

	@Override
	public java.util.NavigableMap<String, Short> getE() { // 
		return mkdb.Logs.logNavigableMap(new mkdb.LogKey(this, "e"), e);
	}

	public java.util.NavigableMap<String, Short> getEAsData() { // 
		java.util.NavigableMap<String, Short> e;
		fxbean _o_ = this;
		e = new java.util.TreeMap<String, Short>();
		for (java.util.Map.Entry<String, Short> _e_ : _o_.e.entrySet())
			e.put(_e_.getKey(), _e_.getValue());
		return e;
	}

	@Override
	public xbean.fxbean0 getF() { // 
		return f;
	}

	@Override
	public int getG() { // 
		return g;
	}

	@Override
	public <T extends com.locojoy.base.Marshal.Marshal> T getH(T _v_) { // 
		try {
			_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(h)));
			return _v_;
		} catch (MarshalException _e_) {
			throw new mkio.MarshalError();
		}
	}

	@Override
	public boolean isHEmpty() { // 
		return h.length == 0;
	}

	@Override
	public byte[] getHCopy() { // 
		return java.util.Arrays.copyOf(h, h.length);
	}

	@Override
	public void setG(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "g") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, g) {
					public void rollback() { g = _xdb_saved; }
				};}});
		g = _v_;
	}

	@Override
	public void setH(com.locojoy.base.Marshal.Marshal _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "h") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, h) {
					public void rollback() { h = _xdb_saved; }
			}; }});
		h = _v_.marshal(new OctetsStream()).getBytes();
	}

	@Override
	public void setHCopy(byte[] _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "h") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, h) {
					public void rollback() { h = _xdb_saved; }
			}; }});
		h = java.util.Arrays.copyOf(_v_, _v_.length);
	}

	@Override
	public final boolean equals(Object _o1_) {
		fxbean _o_ = null;
		if ( _o1_ instanceof fxbean ) _o_ = (fxbean)_o1_;
		else if ( _o1_ instanceof fxbean.Const ) _o_ = ((fxbean.Const)_o1_).nThis();
		else return false;
		if (!a.equals(_o_.a)) return false;
		if (!b.equals(_o_.b)) return false;
		if (!c.equals(_o_.c)) return false;
		if (!d.equals(_o_.d)) return false;
		if (!e.equals(_o_.e)) return false;
		if (!f.equals(_o_.f)) return false;
		if (g != _o_.g) return false;
		if (!java.util.Arrays.equals(h, _o_.h)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += a.hashCode();
		_h_ += b.hashCode();
		_h_ += c.hashCode();
		_h_ += d.hashCode();
		_h_ += e.hashCode();
		_h_ += f.hashCode();
		_h_ += g;
		_h_ += java.util.Arrays.hashCode(h);
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(a);
		_sb_.append(",");
		_sb_.append(b);
		_sb_.append(",");
		_sb_.append(c);
		_sb_.append(",");
		_sb_.append(d);
		_sb_.append(",");
		_sb_.append(e);
		_sb_.append(",");
		_sb_.append(f);
		_sb_.append(",");
		_sb_.append(g);
		_sb_.append(",");
		_sb_.append('B').append(h.length);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableSet().setVarName("a"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("b"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("c"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("d"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("e"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("f"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("g"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("h"));
		return lb;
	}

	private class Const implements xbean.fxbean {
		fxbean nThis() {
			return fxbean.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.fxbean copy() {
			return fxbean.this.copy();
		}

		@Override
		public xbean.fxbean toData() {
			return fxbean.this.toData();
		}

		public xbean.fxbean toBean() {
			return fxbean.this.toBean();
		}

		@Override
		public xbean.fxbean toDataIf() {
			return fxbean.this.toDataIf();
		}

		public xbean.fxbean toBeanIf() {
			return fxbean.this.toBeanIf();
		}

		@Override
		public java.util.Set<Boolean> getA() { // 
			return mkdb.Consts.constSet(a);
		}

		public java.util.Set<Boolean> getAAsData() { // 
			java.util.Set<Boolean> a;
			fxbean _o_ = fxbean.this;
		a = new mkdb.util.SetX<Boolean>();
		a.addAll(_o_.a);
			return a;
		}

		@Override
		public java.util.List<xbean.fcbean> getB() { // 
			return mkdb.Consts.constList(b);
		}

		public java.util.List<xbean.fcbean> getBAsData() { // 
			java.util.List<xbean.fcbean> b;
			fxbean _o_ = fxbean.this;
		b = new java.util.LinkedList<xbean.fcbean>();
		b.addAll(_o_.b);
			return b;
		}

		@Override
		public java.util.List<Float> getC() { // 
			return mkdb.Consts.constList(c);
		}

		public java.util.List<Float> getCAsData() { // 
			java.util.List<Float> c;
			fxbean _o_ = fxbean.this;
		c = new java.util.ArrayList<Float>();
		c.addAll(_o_.c);
			return c;
		}

		@Override
		public java.util.Map<Integer, xbean.fcbean> getD() { // 
			return mkdb.Consts.constMap(d);
		}

		@Override
		public java.util.Map<Integer, xbean.fcbean> getDAsData() { // 
			java.util.Map<Integer, xbean.fcbean> d;
			fxbean _o_ = fxbean.this;
			d = new java.util.HashMap<Integer, xbean.fcbean>();
			for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : _o_.d.entrySet())
				d.put(_e_.getKey(), _e_.getValue());
			return d;
		}

		@Override
		public java.util.NavigableMap<String, Short> getE() { // 
			return mkdb.Consts.constNavigableMap(e);
		}

		@Override
		public java.util.NavigableMap<String, Short> getEAsData() { // 
			java.util.NavigableMap<String, Short> e;
			fxbean _o_ = fxbean.this;
			e = new java.util.TreeMap<String, Short>();
			for (java.util.Map.Entry<String, Short> _e_ : _o_.e.entrySet())
				e.put(_e_.getKey(), _e_.getValue());
			return e;
		}

		@Override
		public xbean.fxbean0 getF() { // 
			return mkdb.Consts.toConst(f);
		}

		@Override
		public int getG() { // 
			return g;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getH(T _v_) { // 
			return fxbean.this.getH(_v_);
		}

		@Override
		public boolean isHEmpty() { // 
			return fxbean.this.isHEmpty();
		}

		@Override
		public byte[] getHCopy() { // 
			return fxbean.this.getHCopy();
		}

		@Override
		public void setG(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setH(com.locojoy.base.Marshal.Marshal _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setHCopy(byte[] _v_) { // 
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
			return fxbean.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return fxbean.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return fxbean.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return fxbean.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return fxbean.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return fxbean.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return fxbean.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return fxbean.this.hashCode();
		}

		@Override
		public String toString() {
			return fxbean.this.toString();
		}

	}

	public static final class Data implements xbean.fxbean {
		private java.util.HashSet<Boolean> a; // 
		private java.util.LinkedList<xbean.fcbean> b; // 
		private java.util.ArrayList<Float> c; // 
		private java.util.HashMap<Integer, xbean.fcbean> d; // 
		private java.util.TreeMap<String, Short> e; // 
		private xbean.fxbean0 f; // 
		private int g; // 
		private byte [] h; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			a = new java.util.HashSet<Boolean>();
			b = new java.util.LinkedList<xbean.fcbean>();
			c = new java.util.ArrayList<Float>();
			d = new java.util.HashMap<Integer, xbean.fcbean>();
			e = new java.util.TreeMap<String, Short>();
			f = new fxbean0.Data();
			g = 1;
			h = new byte[0];
		}

		Data(xbean.fxbean _o1_) {
			if (_o1_ instanceof fxbean) assign((fxbean)_o1_);
			else if (_o1_ instanceof fxbean.Data) assign((fxbean.Data)_o1_);
			else if (_o1_ instanceof fxbean.Const) assign(((fxbean.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(fxbean _o_) {
			a = new java.util.HashSet<Boolean>();
			a.addAll(_o_.a);
			b = new java.util.LinkedList<xbean.fcbean>();
			b.addAll(_o_.b);
			c = new java.util.ArrayList<Float>();
			c.addAll(_o_.c);
			d = new java.util.HashMap<Integer, xbean.fcbean>();
			for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : _o_.d.entrySet())
				d.put(_e_.getKey(), _e_.getValue());
			e = new java.util.TreeMap<String, Short>();
			for (java.util.Map.Entry<String, Short> _e_ : _o_.e.entrySet())
				e.put(_e_.getKey(), _e_.getValue());
			f = new fxbean0.Data(_o_.f);
			g = _o_.g;
			h = java.util.Arrays.copyOf(_o_.h, _o_.h.length);
		}

		private void assign(fxbean.Data _o_) {
			a = new java.util.HashSet<Boolean>();
			a.addAll(_o_.a);
			b = new java.util.LinkedList<xbean.fcbean>();
			b.addAll(_o_.b);
			c = new java.util.ArrayList<Float>();
			c.addAll(_o_.c);
			d = new java.util.HashMap<Integer, xbean.fcbean>();
			for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : _o_.d.entrySet())
				d.put(_e_.getKey(), _e_.getValue());
			e = new java.util.TreeMap<String, Short>();
			for (java.util.Map.Entry<String, Short> _e_ : _o_.e.entrySet())
				e.put(_e_.getKey(), _e_.getValue());
			f = new fxbean0.Data(_o_.f);
			g = _o_.g;
			h = java.util.Arrays.copyOf(_o_.h, _o_.h.length);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(a.size());
			for (Boolean _v_ : a) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(b.size());
			for (xbean.fcbean _v_ : b) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(c.size());
			for (Float _v_ : c) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(d.size());
			for (java.util.Map.Entry<Integer, xbean.fcbean> _e_ : d.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			_os_.compact_uint32(e.size());
			for (java.util.Map.Entry<String, Short> _e_ : e.entrySet())
			{
				_os_.marshal(_e_.getKey(), mkdb.Const.IO_CHARSET);
				_os_.marshal(_e_.getValue());
			}
			f.marshal(_os_);
			_os_.marshal(g);
			_os_.marshal(h);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				boolean _v_ = false;
				_v_ = _os_.unmarshal_boolean();
				a.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.fcbean _v_ = new xbean.fcbean();
				_v_.unmarshal(_os_);
				b.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				float _v_ = 0.0f;
				_v_ = _os_.unmarshal_float();
				c.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					d = new java.util.HashMap<Integer, xbean.fcbean>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.fcbean _v_ = new xbean.fcbean();
					_v_.unmarshal(_os_);
					d.put(_k_, _v_);
				}
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size)
			{
				String _k_ = "";
				_k_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
				short _v_ = 0;
				_v_ = _os_.unmarshal_short();
				e.put(_k_, _v_);
			}
			f.unmarshal(_os_);
			g = _os_.unmarshal_int();
			h = _os_.unmarshal_bytes();
			return _os_;
		}

		@Override
		public xbean.fxbean copy() {
			return new Data(this);
		}

		@Override
		public xbean.fxbean toData() {
			return new Data(this);
		}

		public xbean.fxbean toBean() {
			return new fxbean(this, null, null);
		}

		@Override
		public xbean.fxbean toDataIf() {
			return this;
		}

		public xbean.fxbean toBeanIf() {
			return new fxbean(this, null, null);
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
		public java.util.Set<Boolean> getA() { // 
			return a;
		}

		@Override
		public java.util.Set<Boolean> getAAsData() { // 
			return a;
		}

		@Override
		public java.util.List<xbean.fcbean> getB() { // 
			return b;
		}

		@Override
		public java.util.List<xbean.fcbean> getBAsData() { // 
			return b;
		}

		@Override
		public java.util.List<Float> getC() { // 
			return c;
		}

		@Override
		public java.util.List<Float> getCAsData() { // 
			return c;
		}

		@Override
		public java.util.Map<Integer, xbean.fcbean> getD() { // 
			return d;
		}

		@Override
		public java.util.Map<Integer, xbean.fcbean> getDAsData() { // 
			return d;
		}

		@Override
		public java.util.NavigableMap<String, Short> getE() { // 
			return e;
		}

		@Override
		public java.util.NavigableMap<String, Short> getEAsData() { // 
			return e;
		}

		@Override
		public xbean.fxbean0 getF() { // 
			return f;
		}

		@Override
		public int getG() { // 
			return g;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getH(T _v_) { // 
			try {
				_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(h)));
				return _v_;
			} catch (MarshalException _e_) {
				throw new mkio.MarshalError();
			}
		}

		@Override
		public boolean isHEmpty() { // 
			return h.length == 0;
		}

		@Override
		public byte[] getHCopy() { // 
			return java.util.Arrays.copyOf(h, h.length);
		}

		@Override
		public void setG(int _v_) { // 
			g = _v_;
		}

		@Override
		public void setH(com.locojoy.base.Marshal.Marshal _v_) { // 
			h = _v_.marshal(new OctetsStream()).getBytes();
		}

		@Override
		public void setHCopy(byte[] _v_) { // 
			h = java.util.Arrays.copyOf(_v_, _v_.length);
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof fxbean.Data)) return false;
			fxbean.Data _o_ = (fxbean.Data) _o1_;
			if (!a.equals(_o_.a)) return false;
			if (!b.equals(_o_.b)) return false;
			if (!c.equals(_o_.c)) return false;
			if (!d.equals(_o_.d)) return false;
			if (!e.equals(_o_.e)) return false;
			if (!f.equals(_o_.f)) return false;
			if (g != _o_.g) return false;
			if (!java.util.Arrays.equals(h, _o_.h)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += a.hashCode();
			_h_ += b.hashCode();
			_h_ += c.hashCode();
			_h_ += d.hashCode();
			_h_ += e.hashCode();
			_h_ += f.hashCode();
			_h_ += g;
			_h_ += java.util.Arrays.hashCode(h);
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(a);
			_sb_.append(",");
			_sb_.append(b);
			_sb_.append(",");
			_sb_.append(c);
			_sb_.append(",");
			_sb_.append(d);
			_sb_.append(",");
			_sb_.append(e);
			_sb_.append(",");
			_sb_.append(f);
			_sb_.append(",");
			_sb_.append(g);
			_sb_.append(",");
			_sb_.append('B').append(h.length);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
