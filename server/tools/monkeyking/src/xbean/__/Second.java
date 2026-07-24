
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Second extends mkdb.XBean implements xbean.Second {
	private mkdb.util.SetX<Integer> setfirst; // a
	private java.util.LinkedList<xbean.First> listfirst; // b
	private java.util.ArrayList<xbean.First> vectorfirst; // c
	private java.util.HashMap<Integer, xbean.First> mapfirst; // d
	private java.util.HashMap<String, xbean.First> mapxfirst; // e
	private xbean.First first; // g
	private int i; // int test
	private byte [] marshal2; // binary

	@Override
	public void _reset_unsafe_() {
		setfirst.clear();
		listfirst.clear();
		vectorfirst.clear();
		mapfirst.clear();
		mapxfirst.clear();
		first._reset_unsafe_();
		i = 1;
		marshal2 = new byte[0];
	}

	Second(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		setfirst = new mkdb.util.SetX<Integer>();
		listfirst = new java.util.LinkedList<xbean.First>();
		vectorfirst = new java.util.ArrayList<xbean.First>();
		mapfirst = new java.util.HashMap<Integer, xbean.First>();
		mapxfirst = new java.util.HashMap<String, xbean.First>();
		first = new First(0, this, "first");
		i = 1;
		marshal2 = new byte[0];
	}

	public Second() {
		this(0, null, null);
	}

	public Second(Second _o_) {
		this(_o_, null, null);
	}

	Second(xbean.Second _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Second) assign((Second)_o1_);
		else if (_o1_ instanceof Second.Data) assign((Second.Data)_o1_);
		else if (_o1_ instanceof Second.Const) assign(((Second.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Second _o_) {
		setfirst = new mkdb.util.SetX<Integer>();
		setfirst.addAll(_o_.setfirst);
		listfirst = new java.util.LinkedList<xbean.First>();
		for (xbean.First _v_ : _o_.listfirst)
			listfirst.add(new First(_v_, this, "listfirst"));
		vectorfirst = new java.util.ArrayList<xbean.First>();
		for (xbean.First _v_ : _o_.vectorfirst)
			vectorfirst.add(new First(_v_, this, "vectorfirst"));
		mapfirst = new java.util.HashMap<Integer, xbean.First>();
		for (java.util.Map.Entry<Integer, xbean.First> _e_ : _o_.mapfirst.entrySet())
			mapfirst.put(_e_.getKey(), new First(_e_.getValue(), this, "mapfirst"));
		mapxfirst = new java.util.HashMap<String, xbean.First>();
		for (java.util.Map.Entry<String, xbean.First> _e_ : _o_.mapxfirst.entrySet())
			mapxfirst.put(_e_.getKey(), new First(_e_.getValue(), this, "mapxfirst"));
		first = new First(_o_.first, this, "first");
		i = _o_.i;
		marshal2 = java.util.Arrays.copyOf(_o_.marshal2, _o_.marshal2.length);
	}

	private void assign(Second.Data _o_) {
		setfirst = new mkdb.util.SetX<Integer>();
		setfirst.addAll(_o_.setfirst);
		listfirst = new java.util.LinkedList<xbean.First>();
		for (xbean.First _v_ : _o_.listfirst)
			listfirst.add(new First(_v_, this, "listfirst"));
		vectorfirst = new java.util.ArrayList<xbean.First>();
		for (xbean.First _v_ : _o_.vectorfirst)
			vectorfirst.add(new First(_v_, this, "vectorfirst"));
		mapfirst = new java.util.HashMap<Integer, xbean.First>();
		for (java.util.Map.Entry<Integer, xbean.First> _e_ : _o_.mapfirst.entrySet())
			mapfirst.put(_e_.getKey(), new First(_e_.getValue(), this, "mapfirst"));
		mapxfirst = new java.util.HashMap<String, xbean.First>();
		for (java.util.Map.Entry<String, xbean.First> _e_ : _o_.mapxfirst.entrySet())
			mapxfirst.put(_e_.getKey(), new First(_e_.getValue(), this, "mapxfirst"));
		first = new First(_o_.first, this, "first");
		i = _o_.i;
		marshal2 = java.util.Arrays.copyOf(_o_.marshal2, _o_.marshal2.length);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(setfirst.size());
		for (Integer _v_ : setfirst) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(listfirst.size());
		for (xbean.First _v_ : listfirst) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(vectorfirst.size());
		for (xbean.First _v_ : vectorfirst) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(mapfirst.size());
		for (java.util.Map.Entry<Integer, xbean.First> _e_ : mapfirst.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		_os_.compact_uint32(mapxfirst.size());
		for (java.util.Map.Entry<String, xbean.First> _e_ : mapxfirst.entrySet())
		{
			_os_.marshal(_e_.getKey(), mkdb.Const.IO_CHARSET);
			_e_.getValue().marshal(_os_);
		}
		first.marshal(_os_);
		_os_.marshal(i);
		_os_.marshal(marshal2);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			setfirst.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.First _v_ = new First(0, this, "listfirst");
			_v_.unmarshal(_os_);
			listfirst.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.First _v_ = new First(0, this, "vectorfirst");
			_v_.unmarshal(_os_);
			vectorfirst.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				mapfirst = new java.util.HashMap<Integer, xbean.First>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.First _v_ = new First(0, this, "mapfirst");
				_v_.unmarshal(_os_);
				mapfirst.put(_k_, _v_);
			}
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				mapxfirst = new java.util.HashMap<String, xbean.First>(size * 2);
			}
			for (; size > 0; --size)
			{
				String _k_ = "";
				_k_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
				xbean.First _v_ = new First(0, this, "mapxfirst");
				_v_.unmarshal(_os_);
				mapxfirst.put(_k_, _v_);
			}
		}
		first.unmarshal(_os_);
		i = _os_.unmarshal_int();
		marshal2 = _os_.unmarshal_bytes();
		return _os_;
	}

	@Override
	public xbean.Second copy() {
		return new Second(this);
	}

	@Override
	public xbean.Second toData() {
		return new Data(this);
	}

	public xbean.Second toBean() {
		return new Second(this); // same as copy()
	}

	@Override
	public xbean.Second toDataIf() {
		return new Data(this);
	}

	public xbean.Second toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Set<Integer> getSetfirst() { // a
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "setfirst"), setfirst);
	}

	public java.util.Set<Integer> getSetfirstAsData() { // a
		java.util.Set<Integer> setfirst;
		Second _o_ = this;
		setfirst = new mkdb.util.SetX<Integer>();
		setfirst.addAll(_o_.setfirst);
		return setfirst;
	}

	@Override
	public java.util.List<xbean.First> getListfirst() { // b
		return mkdb.Logs.logList(new mkdb.LogKey(this, "listfirst"), listfirst);
	}

	public java.util.List<xbean.First> getListfirstAsData() { // b
		java.util.List<xbean.First> listfirst;
		Second _o_ = this;
		listfirst = new java.util.LinkedList<xbean.First>();
		for (xbean.First _v_ : _o_.listfirst)
			listfirst.add(new First.Data(_v_));
		return listfirst;
	}

	@Override
	public java.util.List<xbean.First> getVectorfirst() { // c
		return mkdb.Logs.logList(new mkdb.LogKey(this, "vectorfirst"), vectorfirst);
	}

	public java.util.List<xbean.First> getVectorfirstAsData() { // c
		java.util.List<xbean.First> vectorfirst;
		Second _o_ = this;
		vectorfirst = new java.util.ArrayList<xbean.First>();
		for (xbean.First _v_ : _o_.vectorfirst)
			vectorfirst.add(new First.Data(_v_));
		return vectorfirst;
	}

	@Override
	public java.util.Map<Integer, xbean.First> getMapfirst() { // d
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "mapfirst"), mapfirst);
	}

	@Override
	public java.util.Map<Integer, xbean.First> getMapfirstAsData() { // d
		java.util.Map<Integer, xbean.First> mapfirst;
		Second _o_ = this;
		mapfirst = new java.util.HashMap<Integer, xbean.First>();
		for (java.util.Map.Entry<Integer, xbean.First> _e_ : _o_.mapfirst.entrySet())
			mapfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
		return mapfirst;
	}

	@Override
	public java.util.Map<String, xbean.First> getMapxfirst() { // e
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "mapxfirst"), mapxfirst);
	}

	@Override
	public java.util.Map<String, xbean.First> getMapxfirstAsData() { // e
		java.util.Map<String, xbean.First> mapxfirst;
		Second _o_ = this;
		mapxfirst = new java.util.HashMap<String, xbean.First>();
		for (java.util.Map.Entry<String, xbean.First> _e_ : _o_.mapxfirst.entrySet())
			mapxfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
		return mapxfirst;
	}

	@Override
	public xbean.First getFirst() { // g
		return first;
	}

	@Override
	public int getI() { // int test
		return i;
	}

	@Override
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal2(T _v_) { // binary
		try {
			_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(marshal2)));
			return _v_;
		} catch (MarshalException _e_) {
			throw new mkio.MarshalError();
		}
	}

	@Override
	public boolean isMarshal2Empty() { // binary
		return marshal2.length == 0;
	}

	@Override
	public byte[] getMarshal2Copy() { // binary
		return java.util.Arrays.copyOf(marshal2, marshal2.length);
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
	public void setMarshal2(com.locojoy.base.Marshal.Marshal _v_) { // binary
		mkdb.Logs.logIf(new mkdb.LogKey(this, "marshal2") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, marshal2) {
					public void rollback() { marshal2 = _xdb_saved; }
			}; }});
		marshal2 = _v_.marshal(new OctetsStream()).getBytes();
	}

	@Override
	public void setMarshal2Copy(byte[] _v_) { // binary
		mkdb.Logs.logIf(new mkdb.LogKey(this, "marshal2") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, marshal2) {
					public void rollback() { marshal2 = _xdb_saved; }
			}; }});
		marshal2 = java.util.Arrays.copyOf(_v_, _v_.length);
	}

	@Override
	public final boolean equals(Object _o1_) {
		Second _o_ = null;
		if ( _o1_ instanceof Second ) _o_ = (Second)_o1_;
		else if ( _o1_ instanceof Second.Const ) _o_ = ((Second.Const)_o1_).nThis();
		else return false;
		if (!setfirst.equals(_o_.setfirst)) return false;
		if (!listfirst.equals(_o_.listfirst)) return false;
		if (!vectorfirst.equals(_o_.vectorfirst)) return false;
		if (!mapfirst.equals(_o_.mapfirst)) return false;
		if (!mapxfirst.equals(_o_.mapxfirst)) return false;
		if (!first.equals(_o_.first)) return false;
		if (i != _o_.i) return false;
		if (!java.util.Arrays.equals(marshal2, _o_.marshal2)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += setfirst.hashCode();
		_h_ += listfirst.hashCode();
		_h_ += vectorfirst.hashCode();
		_h_ += mapfirst.hashCode();
		_h_ += mapxfirst.hashCode();
		_h_ += first.hashCode();
		_h_ += i;
		_h_ += java.util.Arrays.hashCode(marshal2);
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(setfirst);
		_sb_.append(",");
		_sb_.append(listfirst);
		_sb_.append(",");
		_sb_.append(vectorfirst);
		_sb_.append(",");
		_sb_.append(mapfirst);
		_sb_.append(",");
		_sb_.append(mapxfirst);
		_sb_.append(",");
		_sb_.append(first);
		_sb_.append(",");
		_sb_.append(i);
		_sb_.append(",");
		_sb_.append('B').append(marshal2.length);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableSet().setVarName("setfirst"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("listfirst"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("vectorfirst"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("mapfirst"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("mapxfirst"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("first"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("i"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("marshal2"));
		return lb;
	}

	private class Const implements xbean.Second {
		Second nThis() {
			return Second.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Second copy() {
			return Second.this.copy();
		}

		@Override
		public xbean.Second toData() {
			return Second.this.toData();
		}

		public xbean.Second toBean() {
			return Second.this.toBean();
		}

		@Override
		public xbean.Second toDataIf() {
			return Second.this.toDataIf();
		}

		public xbean.Second toBeanIf() {
			return Second.this.toBeanIf();
		}

		@Override
		public java.util.Set<Integer> getSetfirst() { // a
			return mkdb.Consts.constSet(setfirst);
		}

		public java.util.Set<Integer> getSetfirstAsData() { // a
			java.util.Set<Integer> setfirst;
			Second _o_ = Second.this;
		setfirst = new mkdb.util.SetX<Integer>();
		setfirst.addAll(_o_.setfirst);
			return setfirst;
		}

		@Override
		public java.util.List<xbean.First> getListfirst() { // b
			return mkdb.Consts.constList(listfirst);
		}

		public java.util.List<xbean.First> getListfirstAsData() { // b
			java.util.List<xbean.First> listfirst;
			Second _o_ = Second.this;
		listfirst = new java.util.LinkedList<xbean.First>();
		for (xbean.First _v_ : _o_.listfirst)
			listfirst.add(new First.Data(_v_));
			return listfirst;
		}

		@Override
		public java.util.List<xbean.First> getVectorfirst() { // c
			return mkdb.Consts.constList(vectorfirst);
		}

		public java.util.List<xbean.First> getVectorfirstAsData() { // c
			java.util.List<xbean.First> vectorfirst;
			Second _o_ = Second.this;
		vectorfirst = new java.util.ArrayList<xbean.First>();
		for (xbean.First _v_ : _o_.vectorfirst)
			vectorfirst.add(new First.Data(_v_));
			return vectorfirst;
		}

		@Override
		public java.util.Map<Integer, xbean.First> getMapfirst() { // d
			return mkdb.Consts.constMap(mapfirst);
		}

		@Override
		public java.util.Map<Integer, xbean.First> getMapfirstAsData() { // d
			java.util.Map<Integer, xbean.First> mapfirst;
			Second _o_ = Second.this;
			mapfirst = new java.util.HashMap<Integer, xbean.First>();
			for (java.util.Map.Entry<Integer, xbean.First> _e_ : _o_.mapfirst.entrySet())
				mapfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
			return mapfirst;
		}

		@Override
		public java.util.Map<String, xbean.First> getMapxfirst() { // e
			return mkdb.Consts.constMap(mapxfirst);
		}

		@Override
		public java.util.Map<String, xbean.First> getMapxfirstAsData() { // e
			java.util.Map<String, xbean.First> mapxfirst;
			Second _o_ = Second.this;
			mapxfirst = new java.util.HashMap<String, xbean.First>();
			for (java.util.Map.Entry<String, xbean.First> _e_ : _o_.mapxfirst.entrySet())
				mapxfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
			return mapxfirst;
		}

		@Override
		public xbean.First getFirst() { // g
			return mkdb.Consts.toConst(first);
		}

		@Override
		public int getI() { // int test
			return i;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal2(T _v_) { // binary
			return Second.this.getMarshal2(_v_);
		}

		@Override
		public boolean isMarshal2Empty() { // binary
			return Second.this.isMarshal2Empty();
		}

		@Override
		public byte[] getMarshal2Copy() { // binary
			return Second.this.getMarshal2Copy();
		}

		@Override
		public void setI(int _v_) { // int test
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMarshal2(com.locojoy.base.Marshal.Marshal _v_) { // binary
			throw new UnsupportedOperationException();
		}

		@Override
		public void setMarshal2Copy(byte[] _v_) { // binary
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
			return Second.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Second.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Second.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Second.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Second.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Second.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Second.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Second.this.hashCode();
		}

		@Override
		public String toString() {
			return Second.this.toString();
		}

	}

	public static final class Data implements xbean.Second {
		private java.util.HashSet<Integer> setfirst; // a
		private java.util.LinkedList<xbean.First> listfirst; // b
		private java.util.ArrayList<xbean.First> vectorfirst; // c
		private java.util.HashMap<Integer, xbean.First> mapfirst; // d
		private java.util.HashMap<String, xbean.First> mapxfirst; // e
		private xbean.First first; // g
		private int i; // int test
		private byte [] marshal2; // binary

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			setfirst = new java.util.HashSet<Integer>();
			listfirst = new java.util.LinkedList<xbean.First>();
			vectorfirst = new java.util.ArrayList<xbean.First>();
			mapfirst = new java.util.HashMap<Integer, xbean.First>();
			mapxfirst = new java.util.HashMap<String, xbean.First>();
			first = new First.Data();
			i = 1;
			marshal2 = new byte[0];
		}

		Data(xbean.Second _o1_) {
			if (_o1_ instanceof Second) assign((Second)_o1_);
			else if (_o1_ instanceof Second.Data) assign((Second.Data)_o1_);
			else if (_o1_ instanceof Second.Const) assign(((Second.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Second _o_) {
			setfirst = new java.util.HashSet<Integer>();
			setfirst.addAll(_o_.setfirst);
			listfirst = new java.util.LinkedList<xbean.First>();
			for (xbean.First _v_ : _o_.listfirst)
				listfirst.add(new First.Data(_v_));
			vectorfirst = new java.util.ArrayList<xbean.First>();
			for (xbean.First _v_ : _o_.vectorfirst)
				vectorfirst.add(new First.Data(_v_));
			mapfirst = new java.util.HashMap<Integer, xbean.First>();
			for (java.util.Map.Entry<Integer, xbean.First> _e_ : _o_.mapfirst.entrySet())
				mapfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
			mapxfirst = new java.util.HashMap<String, xbean.First>();
			for (java.util.Map.Entry<String, xbean.First> _e_ : _o_.mapxfirst.entrySet())
				mapxfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
			first = new First.Data(_o_.first);
			i = _o_.i;
			marshal2 = java.util.Arrays.copyOf(_o_.marshal2, _o_.marshal2.length);
		}

		private void assign(Second.Data _o_) {
			setfirst = new java.util.HashSet<Integer>();
			setfirst.addAll(_o_.setfirst);
			listfirst = new java.util.LinkedList<xbean.First>();
			for (xbean.First _v_ : _o_.listfirst)
				listfirst.add(new First.Data(_v_));
			vectorfirst = new java.util.ArrayList<xbean.First>();
			for (xbean.First _v_ : _o_.vectorfirst)
				vectorfirst.add(new First.Data(_v_));
			mapfirst = new java.util.HashMap<Integer, xbean.First>();
			for (java.util.Map.Entry<Integer, xbean.First> _e_ : _o_.mapfirst.entrySet())
				mapfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
			mapxfirst = new java.util.HashMap<String, xbean.First>();
			for (java.util.Map.Entry<String, xbean.First> _e_ : _o_.mapxfirst.entrySet())
				mapxfirst.put(_e_.getKey(), new First.Data(_e_.getValue()));
			first = new First.Data(_o_.first);
			i = _o_.i;
			marshal2 = java.util.Arrays.copyOf(_o_.marshal2, _o_.marshal2.length);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(setfirst.size());
			for (Integer _v_ : setfirst) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(listfirst.size());
			for (xbean.First _v_ : listfirst) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(vectorfirst.size());
			for (xbean.First _v_ : vectorfirst) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(mapfirst.size());
			for (java.util.Map.Entry<Integer, xbean.First> _e_ : mapfirst.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			_os_.compact_uint32(mapxfirst.size());
			for (java.util.Map.Entry<String, xbean.First> _e_ : mapxfirst.entrySet())
			{
				_os_.marshal(_e_.getKey(), mkdb.Const.IO_CHARSET);
				_e_.getValue().marshal(_os_);
			}
			first.marshal(_os_);
			_os_.marshal(i);
			_os_.marshal(marshal2);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				setfirst.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.First _v_ = xbean.Pod.newFirstData();
				_v_.unmarshal(_os_);
				listfirst.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.First _v_ = xbean.Pod.newFirstData();
				_v_.unmarshal(_os_);
				vectorfirst.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					mapfirst = new java.util.HashMap<Integer, xbean.First>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.First _v_ = xbean.Pod.newFirstData();
					_v_.unmarshal(_os_);
					mapfirst.put(_k_, _v_);
				}
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					mapxfirst = new java.util.HashMap<String, xbean.First>(size * 2);
				}
				for (; size > 0; --size)
				{
					String _k_ = "";
					_k_ = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
					xbean.First _v_ = xbean.Pod.newFirstData();
					_v_.unmarshal(_os_);
					mapxfirst.put(_k_, _v_);
				}
			}
			first.unmarshal(_os_);
			i = _os_.unmarshal_int();
			marshal2 = _os_.unmarshal_bytes();
			return _os_;
		}

		@Override
		public xbean.Second copy() {
			return new Data(this);
		}

		@Override
		public xbean.Second toData() {
			return new Data(this);
		}

		public xbean.Second toBean() {
			return new Second(this, null, null);
		}

		@Override
		public xbean.Second toDataIf() {
			return this;
		}

		public xbean.Second toBeanIf() {
			return new Second(this, null, null);
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
		public java.util.Set<Integer> getSetfirst() { // a
			return setfirst;
		}

		@Override
		public java.util.Set<Integer> getSetfirstAsData() { // a
			return setfirst;
		}

		@Override
		public java.util.List<xbean.First> getListfirst() { // b
			return listfirst;
		}

		@Override
		public java.util.List<xbean.First> getListfirstAsData() { // b
			return listfirst;
		}

		@Override
		public java.util.List<xbean.First> getVectorfirst() { // c
			return vectorfirst;
		}

		@Override
		public java.util.List<xbean.First> getVectorfirstAsData() { // c
			return vectorfirst;
		}

		@Override
		public java.util.Map<Integer, xbean.First> getMapfirst() { // d
			return mapfirst;
		}

		@Override
		public java.util.Map<Integer, xbean.First> getMapfirstAsData() { // d
			return mapfirst;
		}

		@Override
		public java.util.Map<String, xbean.First> getMapxfirst() { // e
			return mapxfirst;
		}

		@Override
		public java.util.Map<String, xbean.First> getMapxfirstAsData() { // e
			return mapxfirst;
		}

		@Override
		public xbean.First getFirst() { // g
			return first;
		}

		@Override
		public int getI() { // int test
			return i;
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal2(T _v_) { // binary
			try {
				_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(marshal2)));
				return _v_;
			} catch (MarshalException _e_) {
				throw new mkio.MarshalError();
			}
		}

		@Override
		public boolean isMarshal2Empty() { // binary
			return marshal2.length == 0;
		}

		@Override
		public byte[] getMarshal2Copy() { // binary
			return java.util.Arrays.copyOf(marshal2, marshal2.length);
		}

		@Override
		public void setI(int _v_) { // int test
			i = _v_;
		}

		@Override
		public void setMarshal2(com.locojoy.base.Marshal.Marshal _v_) { // binary
			marshal2 = _v_.marshal(new OctetsStream()).getBytes();
		}

		@Override
		public void setMarshal2Copy(byte[] _v_) { // binary
			marshal2 = java.util.Arrays.copyOf(_v_, _v_.length);
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Second.Data)) return false;
			Second.Data _o_ = (Second.Data) _o1_;
			if (!setfirst.equals(_o_.setfirst)) return false;
			if (!listfirst.equals(_o_.listfirst)) return false;
			if (!vectorfirst.equals(_o_.vectorfirst)) return false;
			if (!mapfirst.equals(_o_.mapfirst)) return false;
			if (!mapxfirst.equals(_o_.mapxfirst)) return false;
			if (!first.equals(_o_.first)) return false;
			if (i != _o_.i) return false;
			if (!java.util.Arrays.equals(marshal2, _o_.marshal2)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += setfirst.hashCode();
			_h_ += listfirst.hashCode();
			_h_ += vectorfirst.hashCode();
			_h_ += mapfirst.hashCode();
			_h_ += mapxfirst.hashCode();
			_h_ += first.hashCode();
			_h_ += i;
			_h_ += java.util.Arrays.hashCode(marshal2);
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(setfirst);
			_sb_.append(",");
			_sb_.append(listfirst);
			_sb_.append(",");
			_sb_.append(vectorfirst);
			_sb_.append(",");
			_sb_.append(mapfirst);
			_sb_.append(",");
			_sb_.append(mapxfirst);
			_sb_.append(",");
			_sb_.append(first);
			_sb_.append(",");
			_sb_.append(i);
			_sb_.append(",");
			_sb_.append('B').append(marshal2.length);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
