
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class Diskdbh extends mkdb.XBean implements xbean.Diskdbh {
	private byte [] data; // 

	@Override
	public void _reset_unsafe_() {
		data = new byte[0];
	}

	Diskdbh(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		data = new byte[0];
	}

	public Diskdbh() {
		this(0, null, null);
	}

	public Diskdbh(Diskdbh _o_) {
		this(_o_, null, null);
	}

	Diskdbh(xbean.Diskdbh _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof Diskdbh) assign((Diskdbh)_o1_);
		else if (_o1_ instanceof Diskdbh.Data) assign((Diskdbh.Data)_o1_);
		else if (_o1_ instanceof Diskdbh.Const) assign(((Diskdbh.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(Diskdbh _o_) {
		data = java.util.Arrays.copyOf(_o_.data, _o_.data.length);
	}

	private void assign(Diskdbh.Data _o_) {
		data = java.util.Arrays.copyOf(_o_.data, _o_.data.length);
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(data);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		data = _os_.unmarshal_bytes();
		return _os_;
	}

	@Override
	public xbean.Diskdbh copy() {
		return new Diskdbh(this);
	}

	@Override
	public xbean.Diskdbh toData() {
		return new Data(this);
	}

	public xbean.Diskdbh toBean() {
		return new Diskdbh(this); // same as copy()
	}

	@Override
	public xbean.Diskdbh toDataIf() {
		return new Data(this);
	}

	public xbean.Diskdbh toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public <T extends com.locojoy.base.Marshal.Marshal> T getData(T _v_) { // 
		try {
			_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(data)));
			return _v_;
		} catch (MarshalException _e_) {
			throw new mkio.MarshalError();
		}
	}

	@Override
	public boolean isDataEmpty() { // 
		return data.length == 0;
	}

	@Override
	public byte[] getDataCopy() { // 
		return java.util.Arrays.copyOf(data, data.length);
	}

	@Override
	public void setData(com.locojoy.base.Marshal.Marshal _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "data") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, data) {
					public void rollback() { data = _xdb_saved; }
			}; }});
		data = _v_.marshal(new OctetsStream()).getBytes();
	}

	@Override
	public void setDataCopy(byte[] _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "data") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogObject<byte []>(this, data) {
					public void rollback() { data = _xdb_saved; }
			}; }});
		data = java.util.Arrays.copyOf(_v_, _v_.length);
	}

	@Override
	public final boolean equals(Object _o1_) {
		Diskdbh _o_ = null;
		if ( _o1_ instanceof Diskdbh ) _o_ = (Diskdbh)_o1_;
		else if ( _o1_ instanceof Diskdbh.Const ) _o_ = ((Diskdbh.Const)_o1_).nThis();
		else return false;
		if (!java.util.Arrays.equals(data, _o_.data)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += java.util.Arrays.hashCode(data);
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append('B').append(data.length);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("data"));
		return lb;
	}

	private class Const implements xbean.Diskdbh {
		Diskdbh nThis() {
			return Diskdbh.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.Diskdbh copy() {
			return Diskdbh.this.copy();
		}

		@Override
		public xbean.Diskdbh toData() {
			return Diskdbh.this.toData();
		}

		public xbean.Diskdbh toBean() {
			return Diskdbh.this.toBean();
		}

		@Override
		public xbean.Diskdbh toDataIf() {
			return Diskdbh.this.toDataIf();
		}

		public xbean.Diskdbh toBeanIf() {
			return Diskdbh.this.toBeanIf();
		}

		@Override
		public <T extends com.locojoy.base.Marshal.Marshal> T getData(T _v_) { // 
			return Diskdbh.this.getData(_v_);
		}

		@Override
		public boolean isDataEmpty() { // 
			return Diskdbh.this.isDataEmpty();
		}

		@Override
		public byte[] getDataCopy() { // 
			return Diskdbh.this.getDataCopy();
		}

		@Override
		public void setData(com.locojoy.base.Marshal.Marshal _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setDataCopy(byte[] _v_) { // 
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
			return Diskdbh.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return Diskdbh.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return Diskdbh.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return Diskdbh.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return Diskdbh.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return Diskdbh.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return Diskdbh.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return Diskdbh.this.hashCode();
		}

		@Override
		public String toString() {
			return Diskdbh.this.toString();
		}

	}

	public static final class Data implements xbean.Diskdbh {
		private byte [] data; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			data = new byte[0];
		}

		Data(xbean.Diskdbh _o1_) {
			if (_o1_ instanceof Diskdbh) assign((Diskdbh)_o1_);
			else if (_o1_ instanceof Diskdbh.Data) assign((Diskdbh.Data)_o1_);
			else if (_o1_ instanceof Diskdbh.Const) assign(((Diskdbh.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(Diskdbh _o_) {
			data = java.util.Arrays.copyOf(_o_.data, _o_.data.length);
		}

		private void assign(Diskdbh.Data _o_) {
			data = java.util.Arrays.copyOf(_o_.data, _o_.data.length);
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(data);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			data = _os_.unmarshal_bytes();
			return _os_;
		}

		@Override
		public xbean.Diskdbh copy() {
			return new Data(this);
		}

		@Override
		public xbean.Diskdbh toData() {
			return new Data(this);
		}

		public xbean.Diskdbh toBean() {
			return new Diskdbh(this, null, null);
		}

		@Override
		public xbean.Diskdbh toDataIf() {
			return this;
		}

		public xbean.Diskdbh toBeanIf() {
			return new Diskdbh(this, null, null);
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
		public <T extends com.locojoy.base.Marshal.Marshal> T getData(T _v_) { // 
			try {
				_v_.unmarshal(OctetsStream.wrap(com.locojoy.base.Octets.wrap(data)));
				return _v_;
			} catch (MarshalException _e_) {
				throw new mkio.MarshalError();
			}
		}

		@Override
		public boolean isDataEmpty() { // 
			return data.length == 0;
		}

		@Override
		public byte[] getDataCopy() { // 
			return java.util.Arrays.copyOf(data, data.length);
		}

		@Override
		public void setData(com.locojoy.base.Marshal.Marshal _v_) { // 
			data = _v_.marshal(new OctetsStream()).getBytes();
		}

		@Override
		public void setDataCopy(byte[] _v_) { // 
			data = java.util.Arrays.copyOf(_v_, _v_.length);
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof Diskdbh.Data)) return false;
			Diskdbh.Data _o_ = (Diskdbh.Data) _o1_;
			if (!java.util.Arrays.equals(data, _o_.data)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += java.util.Arrays.hashCode(data);
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append('B').append(data.length);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
