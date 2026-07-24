
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Cacheb2 extends mkdb.XBean implements xbean.Cacheb2 {
	private int i; // 
	private long l; // 
	private byte [] marshal; // binary
	private mkdb.util.SetX<Integer> seti; // 

	@Override
	public void _reset_unsafe_() {
		i = 0;
		l = 0L;
		marshal = new byte[0];
		seti.clear();
	}

	Cacheb2(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		marshal = new byte[0];
		seti = new mkdb.util.SetX<Integer>();
	}

	public Cacheb2() {
		this(0, null, null);
	}

	public Cacheb2(Cacheb2 _o_) {
		this(_o_, null, null);
	}

	Cacheb2(xbean.Cacheb2 _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Cacheb2) assign((Cacheb2)_o1_);
		else if (_o1_ instanceof Cacheb2.Data) assign((Cacheb2.Data)_o1_);
		else if (_o1_ instanceof Cacheb2.Const) assign(((Cacheb2.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Cacheb2 _o_) {
		i = _o_.i;
		l = _o_.l;
		marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
	}

	private void assign(Cacheb2.Data _o_) {
		i = _o_.i;
		l = _o_.l;
		marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
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
		return _os_;
	}

	@Override
	public xbean.Cacheb2 copy() {
		return new Cacheb2(this);
	}

	@Override
	public xbean.Cacheb2 toData() {
		return new Data(this);
	}

	public xbean.Cacheb2 toBean() {
		return new Cacheb2(this); // same as copy()
	}

	@Override
	public xbean.Cacheb2 toDataIf() {
		return new Data(this);
	}

	public xbean.Cacheb2 toBeanIf() {
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
		Cacheb2 _o_ = this;
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		return seti;
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
		Cacheb2 _o_ = null;
		if ( _o1_ instanceof Cacheb2 ) _o_ = (Cacheb2)_o1_;
		else if ( _o1_ instanceof Cacheb2.Const ) _o_ = ((Cacheb2.Const)_o1_).nThis();
		else return false;
		if (i != _o_.i) return false;
		if (l != _o_.l) return false;
		if (!java.util.Arrays.equals(marshal, _o_.marshal)) return false;
		if (!seti.equals(_o_.seti)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += i;
		_h_ += l;
		_h_ += java.util.Arrays.hashCode(marshal);
		_h_ += seti.hashCode();
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
		return lb;
	}

	private class Const implements xbean.Cacheb2 {
		Cacheb2 nThis() {
			return Cacheb2.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Cacheb2 copy() {
			return Cacheb2.this.copy();
		}

		@Override
		public xbean.Cacheb2 toData() {
			return Cacheb2.this.toData();
		}

		public xbean.Cacheb2 toBean() {
			return Cacheb2.this.toBean();
		}

		@Override
		public xbean.Cacheb2 toDataIf() {
			return Cacheb2.this.toDataIf();
		}

		public xbean.Cacheb2 toBeanIf() {
			return Cacheb2.this.toBeanIf();
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
			return Cacheb2.this.getMarshal(_v_);
		}

		@Override
		public boolean isMarshalEmpty() { // binary
			return Cacheb2.this.isMarshalEmpty();
		}

		@Override
		public byte[] getMarshalCopy() { // binary
			return Cacheb2.this.getMarshalCopy();
		}

		@Override
		public java.util.Set<Integer> getSeti() { // 
			return mkdb.Consts.constSet(seti);
		}

		public java.util.Set<Integer> getSetiAsData() { // 
			java.util.Set<Integer> seti;
			Cacheb2 _o_ = Cacheb2.this;
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
			return seti;
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
			return Cacheb2.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Cacheb2.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Cacheb2.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Cacheb2.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Cacheb2.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Cacheb2.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Cacheb2.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Cacheb2.this.hashCode();
		}

		@Override
		public String toString() {
			return Cacheb2.this.toString();
		}

	}

	public static final class Data implements xbean.Cacheb2 {
		private int i; // 
		private long l; // 
		private byte [] marshal; // binary
		private java.util.HashSet<Integer> seti; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			marshal = new byte[0];
			seti = new java.util.HashSet<Integer>();
		}

		Data(xbean.Cacheb2 _o1_) {
			if (_o1_ instanceof Cacheb2) assign((Cacheb2)_o1_);
			else if (_o1_ instanceof Cacheb2.Data) assign((Cacheb2.Data)_o1_);
			else if (_o1_ instanceof Cacheb2.Const) assign(((Cacheb2.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Cacheb2 _o_) {
			i = _o_.i;
			l = _o_.l;
			marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
			seti = new java.util.HashSet<Integer>();
			seti.addAll(_o_.seti);
		}

		private void assign(Cacheb2.Data _o_) {
			i = _o_.i;
			l = _o_.l;
			marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
			seti = new java.util.HashSet<Integer>();
			seti.addAll(_o_.seti);
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
			return _os_;
		}

		@Override
		public xbean.Cacheb2 copy() {
			return new Data(this);
		}

		@Override
		public xbean.Cacheb2 toData() {
			return new Data(this);
		}

		public xbean.Cacheb2 toBean() {
			return new Cacheb2(this, null, null);
		}

		@Override
		public xbean.Cacheb2 toDataIf() {
			return this;
		}

		public xbean.Cacheb2 toBeanIf() {
			return new Cacheb2(this, null, null);
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
			if (!(_o1_ instanceof Cacheb2.Data)) return false;
			Cacheb2.Data _o_ = (Cacheb2.Data) _o1_;
			if (i != _o_.i) return false;
			if (l != _o_.l) return false;
			if (!java.util.Arrays.equals(marshal, _o_.marshal)) return false;
			if (!seti.equals(_o_.seti)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += i;
			_h_ += l;
			_h_ += java.util.Arrays.hashCode(marshal);
			_h_ += seti.hashCode();
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
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
