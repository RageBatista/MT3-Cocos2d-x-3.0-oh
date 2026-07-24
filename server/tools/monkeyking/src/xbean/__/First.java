
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class First extends mkdb.XBean implements xbean.First {
	private short s; // short test
	private int i; // int test
	private long l; // long test
	private String text; // text
	private byte [] marshal; // binary
	private mkdb.util.SetX<String> sets; // comment
	private mkdb.util.SetX<Integer> seti; // comment
	private mkdb.util.SetX<Long> setl; // comment

	@Override
	public void _reset_unsafe_() {
		s = 1;
		i = 1;
		l = 1;
		text = "123";
		marshal = new byte[0];
		sets.clear();
		seti.clear();
		setl.clear();
	}

	First(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		s = 1;
		i = 1;
		l = 1;
		text = "123";
		marshal = new byte[0];
		sets = new mkdb.util.SetX<String>();
		seti = new mkdb.util.SetX<Integer>();
		setl = new mkdb.util.SetX<Long>();
	}

	public First() {
		this(0, null, null);
	}

	public First(First _o_) {
		this(_o_, null, null);
	}

	First(xbean.First _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof First) assign((First)_o1_);
		else if (_o1_ instanceof First.Data) assign((First.Data)_o1_);
		else if (_o1_ instanceof First.Const) assign(((First.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(First _o_) {
		s = _o_.s;
		i = _o_.i;
		l = _o_.l;
		text = _o_.text;
		marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
		sets = new mkdb.util.SetX<String>();
		sets.addAll(_o_.sets);
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		setl = new mkdb.util.SetX<Long>();
		setl.addAll(_o_.setl);
	}

	private void assign(First.Data _o_) {
		s = _o_.s;
		i = _o_.i;
		l = _o_.l;
		text = _o_.text;
		marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
		sets = new mkdb.util.SetX<String>();
		sets.addAll(_o_.sets);
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		setl = new mkdb.util.SetX<Long>();
		setl.addAll(_o_.setl);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(s);
		_os_.marshal(i);
		_os_.marshal(l);
		_os_.marshal(text, mkdb.Const.IO_CHARSET);
		_os_.marshal(marshal);
		_os_.compact_uint32(sets.size());
		for (String _v_ : sets) {
			_os_.marshal(_v_, mkdb.Const.IO_CHARSET);
		}
		_os_.compact_uint32(seti.size());
		for (Integer _v_ : seti) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(setl.size());
		for (Long _v_ : setl) {
			_os_.marshal(_v_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		s = _os_.unmarshal_short();
		i = _os_.unmarshal_int();
		l = _os_.unmarshal_long();
		text = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
		marshal = _os_.unmarshal_bytes();
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			String _v_ = "";
			_v_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			sets.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			seti.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			long _v_ = 0;
			_v_ = _os_.unmarshal_long();
			setl.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.First copy() {
		return new First(this);
	}

	@Override
	public xbean.First toData() {
		return new Data(this);
	}

	public xbean.First toBean() {
		return new First(this); // same as copy()
	}

	@Override
	public xbean.First toDataIf() {
		return new Data(this);
	}

	public xbean.First toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public short getS() { // short test
		return s;
	}

	@Override
	public int getI() { // int test
		return i;
	}

	@Override
	public long getL() { // long test
		return l;
	}

	@Override
	public String getText() { // text
		return text;
	}

	@Override
	public com.locojoy.base.Octets getTextOctets() { // text
		return com.locojoy.base.Octets.wrap(getText(), mkdb.Const.IO_CHARSET);
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
	public java.util.Set<String> getSets() { // comment
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "sets"), sets);
	}

	public java.util.Set<String> getSetsAsData() { // comment
		java.util.Set<String> sets;
		First _o_ = this;
		sets = new mkdb.util.SetX<String>();
		sets.addAll(_o_.sets);
		return sets;
	}

	@Override
	public java.util.Set<Integer> getSeti() { // comment
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "seti"), seti);
	}

	public java.util.Set<Integer> getSetiAsData() { // comment
		java.util.Set<Integer> seti;
		First _o_ = this;
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
		return seti;
	}

	@Override
	public java.util.Set<Long> getSetl() { // comment
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "setl"), setl);
	}

	public java.util.Set<Long> getSetlAsData() { // comment
		java.util.Set<Long> setl;
		First _o_ = this;
		setl = new mkdb.util.SetX<Long>();
		setl.addAll(_o_.setl);
		return setl;
	}

	@Override
	public void setS(short _v_) { // short test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "s") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogShort(this, s) {
					public void rollback() { s = _xdb_saved; }
				};}});
		s = _v_;
	}

	@Override
	public void setI(int _v_) { // int test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "i") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, i) {
					public void rollback() { i = _xdb_saved; }
				};}});
		i = _v_;
	}

	@Override
	public void setL(long _v_) { // long test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "l") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogLong(this, l) {
					public void rollback() { l = _xdb_saved; }
				};}});
		l = _v_;
	}

	@Override
	public void setText(String _v_) { // text
		if (null == _v_)
			throw new NullPointerException();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "text") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogString(this, text) {
					public void rollback() { text = _xdb_saved; }
				};}});
		text = _v_;
	}

	@Override
	public void setTextOctets(com.locojoy.base.Octets _v_) { // text
		this.setText(_v_.getString(mkdb.Const.IO_CHARSET));
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
		First _o_ = null;
		if ( _o1_ instanceof First ) _o_ = (First)_o1_;
		else if ( _o1_ instanceof First.Const ) _o_ = ((First.Const)_o1_).nThis();
		else return false;
		if (s != _o_.s) return false;
		if (i != _o_.i) return false;
		if (l != _o_.l) return false;
		if (!text.equals(_o_.text)) return false;
		if (!java.util.Arrays.equals(marshal, _o_.marshal)) return false;
		if (!sets.equals(_o_.sets)) return false;
		if (!seti.equals(_o_.seti)) return false;
		if (!setl.equals(_o_.setl)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += s;
		_h_ += i;
		_h_ += l;
		_h_ += text.hashCode();
		_h_ += java.util.Arrays.hashCode(marshal);
		_h_ += sets.hashCode();
		_h_ += seti.hashCode();
		_h_ += setl.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(s);
		_sb_.append(",");
		_sb_.append(i);
		_sb_.append(",");
		_sb_.append(l);
		_sb_.append(",");
		_sb_.append("'").append(text).append("'");
		_sb_.append(",");
		_sb_.append('B').append(marshal.length);
		_sb_.append(",");
		_sb_.append(sets);
		_sb_.append(",");
		_sb_.append(seti);
		_sb_.append(",");
		_sb_.append(setl);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("s"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("i"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("l"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("text"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("marshal"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("sets"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("seti"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("setl"));
		return lb;
	}

	private class Const implements xbean.First {
		First nThis() {
			return First.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.First copy() {
			return First.this.copy();
		}

		@Override
		public xbean.First toData() {
			return First.this.toData();
		}

		public xbean.First toBean() {
			return First.this.toBean();
		}

		@Override
		public xbean.First toDataIf() {
			return First.this.toDataIf();
		}

		public xbean.First toBeanIf() {
			return First.this.toBeanIf();
		}

		@Override
		public short getS() { // short test
			return s;
		}

		@Override
		public int getI() { // int test
			return i;
		}

		@Override
		public long getL() { // long test
			return l;
		}

		@Override
		public String getText() { // text
			return text;
		}

		@Override
		public com.locojoy.base.Octets getTextOctets() { // text
			return First.this.getTextOctets();
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_) { // binary
			return First.this.getMarshal(_v_);
		}

		@Override
		public boolean isMarshalEmpty() { // binary
			return First.this.isMarshalEmpty();
		}

		@Override
		public byte[] getMarshalCopy() { // binary
			return First.this.getMarshalCopy();
		}

		@Override
		public java.util.Set<String> getSets() { // comment
			return mkdb.Consts.constSet(sets);
		}

		public java.util.Set<String> getSetsAsData() { // comment
			java.util.Set<String> sets;
			First _o_ = First.this;
		sets = new mkdb.util.SetX<String>();
		sets.addAll(_o_.sets);
			return sets;
		}

		@Override
		public java.util.Set<Integer> getSeti() { // comment
			return mkdb.Consts.constSet(seti);
		}

		public java.util.Set<Integer> getSetiAsData() { // comment
			java.util.Set<Integer> seti;
			First _o_ = First.this;
		seti = new mkdb.util.SetX<Integer>();
		seti.addAll(_o_.seti);
			return seti;
		}

		@Override
		public java.util.Set<Long> getSetl() { // comment
			return mkdb.Consts.constSet(setl);
		}

		public java.util.Set<Long> getSetlAsData() { // comment
			java.util.Set<Long> setl;
			First _o_ = First.this;
		setl = new mkdb.util.SetX<Long>();
		setl.addAll(_o_.setl);
			return setl;
		}

		@Override
		public void setS(short _v_) { // short test
			throw new UnsupportedOperationException();
		}

		@Override
		public void setI(int _v_) { // int test
			throw new UnsupportedOperationException();
		}

		@Override
		public void setL(long _v_) { // long test
			throw new UnsupportedOperationException();
		}

		@Override
		public void setText(String _v_) { // text
			throw new UnsupportedOperationException();
		}

		@Override
		public void setTextOctets(com.locojoy.base.Octets _v_) { // text
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
			return First.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return First.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return First.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return First.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return First.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return First.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return First.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return First.this.hashCode();
		}

		@Override
		public String toString() {
			return First.this.toString();
		}

	}

	public static final class Data implements xbean.First {
		private short s; // short test
		private int i; // int test
		private long l; // long test
		private String text; // text
		private byte [] marshal; // binary
		private java.util.HashSet<String> sets; // comment
		private java.util.HashSet<Integer> seti; // comment
		private java.util.HashSet<Long> setl; // comment

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			s = 1;
			i = 1;
			l = 1;
			text = "123";
			marshal = new byte[0];
			sets = new java.util.HashSet<String>();
			seti = new java.util.HashSet<Integer>();
			setl = new java.util.HashSet<Long>();
		}

		Data(xbean.First _o1_) {
			if (_o1_ instanceof First) assign((First)_o1_);
			else if (_o1_ instanceof First.Data) assign((First.Data)_o1_);
			else if (_o1_ instanceof First.Const) assign(((First.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(First _o_) {
			s = _o_.s;
			i = _o_.i;
			l = _o_.l;
			text = _o_.text;
			marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
			sets = new java.util.HashSet<String>();
			sets.addAll(_o_.sets);
			seti = new java.util.HashSet<Integer>();
			seti.addAll(_o_.seti);
			setl = new java.util.HashSet<Long>();
			setl.addAll(_o_.setl);
		}

		private void assign(First.Data _o_) {
			s = _o_.s;
			i = _o_.i;
			l = _o_.l;
			text = _o_.text;
			marshal = java.util.Arrays.copyOf(_o_.marshal, _o_.marshal.length);
			sets = new java.util.HashSet<String>();
			sets.addAll(_o_.sets);
			seti = new java.util.HashSet<Integer>();
			seti.addAll(_o_.seti);
			setl = new java.util.HashSet<Long>();
			setl.addAll(_o_.setl);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(s);
			_os_.marshal(i);
			_os_.marshal(l);
			_os_.marshal(text, mkdb.Const.IO_CHARSET);
			_os_.marshal(marshal);
			_os_.compact_uint32(sets.size());
			for (String _v_ : sets) {
				_os_.marshal(_v_, mkdb.Const.IO_CHARSET);
			}
			_os_.compact_uint32(seti.size());
			for (Integer _v_ : seti) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(setl.size());
			for (Long _v_ : setl) {
				_os_.marshal(_v_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			s = _os_.unmarshal_short();
			i = _os_.unmarshal_int();
			l = _os_.unmarshal_long();
			text = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			marshal = _os_.unmarshal_bytes();
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				String _v_ = "";
				_v_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
				sets.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				seti.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				long _v_ = 0;
				_v_ = _os_.unmarshal_long();
				setl.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.First copy() {
			return new Data(this);
		}

		@Override
		public xbean.First toData() {
			return new Data(this);
		}

		public xbean.First toBean() {
			return new First(this, null, null);
		}

		@Override
		public xbean.First toDataIf() {
			return this;
		}

		public xbean.First toBeanIf() {
			return new First(this, null, null);
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
		public short getS() { // short test
			return s;
		}

		@Override
		public int getI() { // int test
			return i;
		}

		@Override
		public long getL() { // long test
			return l;
		}

		@Override
		public String getText() { // text
			return text;
		}

		@Override
		public com.locojoy.base.Octets getTextOctets() { // text
			return com.locojoy.base.Octets.wrap(getText(), mkdb.Const.IO_CHARSET);
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
		public java.util.Set<String> getSets() { // comment
			return sets;
		}

		@Override
		public java.util.Set<String> getSetsAsData() { // comment
			return sets;
		}

		@Override
		public java.util.Set<Integer> getSeti() { // comment
			return seti;
		}

		@Override
		public java.util.Set<Integer> getSetiAsData() { // comment
			return seti;
		}

		@Override
		public java.util.Set<Long> getSetl() { // comment
			return setl;
		}

		@Override
		public java.util.Set<Long> getSetlAsData() { // comment
			return setl;
		}

		@Override
		public void setS(short _v_) { // short test
			s = _v_;
		}

		@Override
		public void setI(int _v_) { // int test
			i = _v_;
		}

		@Override
		public void setL(long _v_) { // long test
			l = _v_;
		}

		@Override
		public void setText(String _v_) { // text
			if (null == _v_)
				throw new NullPointerException();
			text = _v_;
		}

		@Override
		public void setTextOctets(com.locojoy.base.Octets _v_) { // text
			this.setText(_v_.getString(mkdb.Const.IO_CHARSET));
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
			if (!(_o1_ instanceof First.Data)) return false;
			First.Data _o_ = (First.Data) _o1_;
			if (s != _o_.s) return false;
			if (i != _o_.i) return false;
			if (l != _o_.l) return false;
			if (!text.equals(_o_.text)) return false;
			if (!java.util.Arrays.equals(marshal, _o_.marshal)) return false;
			if (!sets.equals(_o_.sets)) return false;
			if (!seti.equals(_o_.seti)) return false;
			if (!setl.equals(_o_.setl)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += s;
			_h_ += i;
			_h_ += l;
			_h_ += text.hashCode();
			_h_ += java.util.Arrays.hashCode(marshal);
			_h_ += sets.hashCode();
			_h_ += seti.hashCode();
			_h_ += setl.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(s);
			_sb_.append(",");
			_sb_.append(i);
			_sb_.append(",");
			_sb_.append(l);
			_sb_.append(",");
			_sb_.append("'").append(text).append("'");
			_sb_.append(",");
			_sb_.append('B').append(marshal.length);
			_sb_.append(",");
			_sb_.append(sets);
			_sb_.append(",");
			_sb_.append(seti);
			_sb_.append(",");
			_sb_.append(setl);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
