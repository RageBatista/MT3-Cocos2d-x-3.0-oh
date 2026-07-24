
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Cacheb0 extends mkdb.XBean implements xbean.Cacheb0 {
	private int i; // 
	private long l; // 
	private byte [] marshal; // binary
	private mkdb.util.SetX<Integer> seti; // 
	private xbean.Cacheb1 cacheb1; // 

	@Override
	public void _reset_unsafe_() {
		i = 0;
		l = 0L;
		marshal = new byte[0];
		seti.clear();
		cacheb1._reset_unsafe_();
	}

	Cacheb0(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		marshal = new byte[0];
		seti = new mkdb.util.SetX<Integer>();
		cacheb1 = new Cacheb1(0, this, "cacheb1");
	}

	public Cacheb0() {
		this(0, null, null);
	}

	public Cacheb0(Cacheb0 _o_) {
		this(_o_, null, null);
	}

	Cacheb0(xbean.Cacheb0 _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Cacheb0) assign((Cacheb0)_o1_);
		else if (_o1_ instanceof Cacheb0.Data) assign((Cacheb0.Data)_o1_);
		else if (_o1_ instanceof Cacheb0.Const) assign(((Cacheb0.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Cacheb0 _o_) {
		i = _o_.i;
		l = _o_.l;
		marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		cacheb1 = new Cacheb1(_o_.cacheb1, this, "cacheb1");
	}

	private void assign(Cacheb0.Data _o_) {
		i = _o_.i;
		l = _o_.l;
		marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		cacheb1 = new Cacheb1(_o_.cacheb1, this, "cacheb1");
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(i);
		_os_.marshal(l);
		_os_.marshal(marshal);
		_os_.compact_uint32(seti.size());
		for (Integer _v_ : seti) {
			_os_.marshal(_v_);
		}
		cacheb1.marshal(_os_);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		i = _os_.unmarshal_int();
		l = _os_.unmarshal_long();
		marshal = _os_.unmarshal_bytes();
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			seti.add(_v_);
		}
		cacheb1.unmarshal(_os_);
		return _os_;
	}

	@Override
	public xbean.Cacheb0 copy() {
		return new Cacheb0(this);
	}

	@Override
	public xbean.Cacheb0 toData() {
		return new Data(this);
	}

	public xbean.Cacheb0 toBean() {
		return new Cacheb0(this); // same as copy()
	}

	@Override
	public xbean.Cacheb0 toDataIf() {
		return new Data(this);
	}

	public xbean.Cacheb0 toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getI() { // 
		return i;
	}

	@Override
	public long getL() { // 
		return l;
	}

	@Override
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_) { // binary
		try {
			_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(marshal)));
			return _v_;
		} catch (MarshalException _e_) {
			throw new mkio.MarshalError();
		}
	}

	@Override
	public boolean isMarshalEmpty() { // binary
		return marshal.length == 0;
	}

	@Override
	public byte[] getMarshalCopy() { // binary
		return java.util.Arrays.copyOf(marshal, marshal.length);
	}

	@Override
	public java.util.Set<Integer> getSeti() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "seti"), seti);
	}

	public java.util.Set<Integer> getSetiAsData() { // 
		java.util.Set<Integer> seti;
		Cacheb0 _o_ = this;
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		return seti;
	}

	@Override
	public xbean.Cacheb1 getCacheb1() { // 
		return cacheb1;
	}

	@Override
	public void setI(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "i") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, i) {
					public void rollback() { i = _xdb_saved; }
				};}});
		i = _v_;
	}

	@Override
	public void setL(long _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "l") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, l) {
					public void rollback() { l = _xdb_saved; }
				};}});
		l = _v_;
	}

	@Override
	public void setMarshal(com.locojoy.base.Marshal.Marshal _v_) { // binary
		mkdb.Logs.logIf(new mkdb.LogKey(this, "marshal") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, marshal) {
					public void rollback() { marshal = _xdb_saved; }
			}; }});
		marshal = _v_.marshal(new OctetsStream()).getBytes();
	}

	@Override
	public void setMarshalCopy(byte[] _v_) { // binary
		mkdb.Logs.logIf(new mkdb.LogKey(this, "marshal") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, marshal) {
					public void rollback() { marshal = _xdb_saved; }
			}; }});
		marshal = java.util.Arrays.copyOf(_v_, _v_.length);
	}

	@Override
	public final boolean equals(Object _o1_) {
		Cacheb0 _o_ = null;
		if ( _o1_ instanceof Cacheb0 ) _o_ = (Cacheb0)_o1_;
		else if ( _o1_ instanceof Cacheb0.Const ) _o_ = ((Cacheb0.Const)_o1_).nThis();
		else return false;
		if (i != _o_.i) return false;
		if (l != _o_.l) return false;
		if (!java.util.Arrays.equals(marshal, _o_.marshal)) return false;
		if (!seti.equals(_o_.seti)) return false;
		if (!cacheb1.equals(_o_.cacheb1)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += i;
		_h_ += l;
		_h_ += java.util.Arrays.hashCode(marshal);
		_h_ += seti.hashCode();
		_h_ += cacheb1.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(i);
		_sb_.append(",");
		_sb_.append(l);
		_sb_.append(",");
		_sb_.append('B').append(marshal.length);
		_sb_.append(",");
		_sb_.append(seti);
		_sb_.append(",");
		_sb_.append(cacheb1);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("i"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("l"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("marshal"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("seti"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("cacheb1"));
		return lb;
	}

	private class Const implements xbean.Cacheb0 {
		Cacheb0 nThis() {
			return Cacheb0.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Cacheb0 copy() {
			return Cacheb0.this.copy();
		}

		@Override
		public xbean.Cacheb0 toData() {
			return Cacheb0.this.toData();
		}

		public xbean.Cacheb0 toBean() {
			return Cacheb0.this.toBean();
		}

		@Override
		public xbean.Cacheb0 toDataIf() {
			return Cacheb0.this.toDataIf();
		}

		public xbean.Cacheb0 toBeanIf() {
			return Cacheb0.this.toBeanIf();
		}

		@Override
		public int getI() { // 
			return i;
		}

		@Override
		public long getL() { // 
			return l;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_) { // binary
			return Cacheb0.this.getMarshal(_v_);
		}

		@Override
		public boolean isMarshalEmpty() { // binary
			return Cacheb0.this.isMarshalEmpty();
		}

		@Override
		public byte[] getMarshalCopy() { // binary
			return Cacheb0.this.getMarshalCopy();
		}

		@Override
		public java.util.Set<Integer> getSeti() { // 
			return mkdb.Consts.constSet(seti);
		}

		public java.util.Set<Integer> getSetiAsData() { // 
			java.util.Set<Integer> seti;
			Cacheb0 _o_ = Cacheb0.this;
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
			return seti;
		}

		@Override
		public xbean.Cacheb1 getCacheb1() { // 
			return mkdb.Consts.toConst(cacheb1);
		}

		@Override
		public void setI(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setL(long _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMarshal(com.locojoy.base.Marshal.Marshal _v_) { // binary
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMarshalCopy(byte[] _v_) { // binary
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
			return Cacheb0.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Cacheb0.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Cacheb0.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Cacheb0.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Cacheb0.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Cacheb0.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Cacheb0.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Cacheb0.this.hashCode();
		}

		@Override
		public String toString() {
			return Cacheb0.this.toString();
		}

	}

	public static final class Data implements xbean.Cacheb0 {
		private int i; // 
		private long l; // 
		private byte [] marshal; // binary
		private java.util.HashSet<Integer> seti; // 
		private xbean.Cacheb1 cacheb1; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			marshal = new byte[0];
			seti = new java.util.HashSet<Integer>();
			cacheb1 = new Cacheb1.Data();
		}

		Data(xbean.Cacheb0 _o1_) {
			if (_o1_ instanceof Cacheb0) assign((Cacheb0)_o1_);
			else if (_o1_ instanceof Cacheb0.Data) assign((Cacheb0.Data)_o1_);
			else if (_o1_ instanceof Cacheb0.Const) assign(((Cacheb0.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Cacheb0 _o_) {
			i = _o_.i;
			l = _o_.l;
			marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
			seti = new java.util.HashSet<Integer>();
			seti.addAll(_o_.seti);
			cacheb1 = new Cacheb1.Data(_o_.cacheb1);
		}

		private void assign(Cacheb0.Data _o_) {
			i = _o_.i;
			l = _o_.l;
			marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
			seti = new java.util.HashSet<Integer>();
			seti.addAll(_o_.seti);
			cacheb1 = new Cacheb1.Data(_o_.cacheb1);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(i);
			_os_.marshal(l);
			_os_.marshal(marshal);
			_os_.compact_uint32(seti.size());
			for (Integer _v_ : seti) {
				_os_.marshal(_v_);
			}
			cacheb1.marshal(_os_);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			i = _os_.unmarshal_int();
			l = _os_.unmarshal_long();
			marshal = _os_.unmarshal_bytes();
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				seti.add(_v_);
			}
			cacheb1.unmarshal(_os_);
			return _os_;
		}

		@Override
		public xbean.Cacheb0 copy() {
			return new Data(this);
		}

		@Override
		public xbean.Cacheb0 toData() {
			return new Data(this);
		}

		public xbean.Cacheb0 toBean() {
			return new Cacheb0(this, null, null);
		}

		@Override
		public xbean.Cacheb0 toDataIf() {
			return this;
		}

		public xbean.Cacheb0 toBeanIf() {
			return new Cacheb0(this, null, null);
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
		public int getI() { // 
			return i;
		}

		@Override
		public long getL() { // 
			return l;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_) { // binary
			try {
				_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(marshal)));
				return _v_;
			} catch (MarshalException _e_) {
				throw new mkio.MarshalError();
			}
		}

		@Override
		public boolean isMarshalEmpty() { // binary
			return marshal.length == 0;
		}

		@Override
		public byte[] getMarshalCopy() { // binary
			return java.util.Arrays.copyOf(marshal, marshal.length);
		}

		@Override
		public java.util.Set<Integer> getSeti() { // 
			return seti;
		}

		@Override
		public java.util.Set<Integer> getSetiAsData() { // 
			return seti;
		}

		@Override
		public xbean.Cacheb1 getCacheb1() { // 
			return cacheb1;
		}

		@Override
		public void setI(int _v_) { // 
			i = _v_;
		}

		@Override
		public void setL(long _v_) { // 
			l = _v_;
		}

		@Override
		public void setMarshal(com.locojoy.base.Marshal.Marshal _v_) { // binary
			marshal = _v_.marshal(new OctetsStream()).getBytes();
		}

		@Override
		public void setMarshalCopy(byte[] _v_) { // binary
			marshal = java.util.Arrays.copyOf(_v_, _v_.length);
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Cacheb0.Data)) return false;
			Cacheb0.Data _o_ = (Cacheb0.Data) _o1_;
			if (i != _o_.i) return false;
			if (l != _o_.l) return false;
			if (!java.util.Arrays.equals(marshal, _o_.marshal)) return false;
			if (!seti.equals(_o_.seti)) return false;
			if (!cacheb1.equals(_o_.cacheb1)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += i;
			_h_ += l;
			_h_ += java.util.Arrays.hashCode(marshal);
			_h_ += seti.hashCode();
			_h_ += cacheb1.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(i);
			_sb_.append(",");
			_sb_.append(l);
			_sb_.append(",");
			_sb_.append('B').append(marshal.length);
			_sb_.append(",");
			_sb_.append(seti);
			_sb_.append(",");
			_sb_.append(cacheb1);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
