
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class varMap extends mkdb.XBean implements xbean.varMap {
	private java.util.HashMap<Integer, Integer> v; // 

	@Override
	public void _reset_unsafe_() {
		v.clear();
	}

	varMap(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		v = new java.util.HashMap<Integer, Integer>();
	}

	public varMap() {
		this(0, null, null);
	}

	public varMap(varMap _o_) {
		this(_o_, null, null);
	}

	varMap(xbean.varMap _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof varMap) assign((varMap)_o1_);
		else if (_o1_ instanceof varMap.Data) assign((varMap.Data)_o1_);
		else if (_o1_ instanceof varMap.Const) assign(((varMap.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(varMap _o_) {
		v = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.v.entrySet())
			v.put(_e_.getKey(), _e_.getValue());
	}

	private void assign(varMap.Data _o_) {
		v = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.v.entrySet())
			v.put(_e_.getKey(), _e_.getValue());
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(v.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : v.entrySet())
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
				v = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				v.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.varMap copy() {
		return new varMap(this);
	}

	@Override
	public xbean.varMap toData() {
		return new Data(this);
	}

	public xbean.varMap toBean() {
		return new varMap(this); // same as copy()
	}

	@Override
	public xbean.varMap toDataIf() {
		return new Data(this);
	}

	public xbean.varMap toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.Map<Integer, Integer> getV() { // 
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "v"), v);
	}

	@Override
	public java.util.Map<Integer, Integer> getVAsData() { // 
		java.util.Map<Integer, Integer> v;
		varMap _o_ = this;
		v = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.v.entrySet())
			v.put(_e_.getKey(), _e_.getValue());
		return v;
	}

	@Override
	public final boolean equals(Object _o1_) {
		varMap _o_ = null;
		if ( _o1_ instanceof varMap ) _o_ = (varMap)_o1_;
		else if ( _o1_ instanceof varMap.Const ) _o_ = ((varMap.Const)_o1_).nThis();
		else return false;
		if (!v.equals(_o_.v)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += v.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(v);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableMap().setVarName("v"));
		return lb;
	}

	private class Const implements xbean.varMap {
		varMap nThis() {
			return varMap.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.varMap copy() {
			return varMap.this.copy();
		}

		@Override
		public xbean.varMap toData() {
			return varMap.this.toData();
		}

		public xbean.varMap toBean() {
			return varMap.this.toBean();
		}

		@Override
		public xbean.varMap toDataIf() {
			return varMap.this.toDataIf();
		}

		public xbean.varMap toBeanIf() {
			return varMap.this.toBeanIf();
		}

		@Override
		public java.util.Map<Integer, Integer> getV() { // 
			return mkdb.Consts.constMap(v);
		}

		@Override
		public java.util.Map<Integer, Integer> getVAsData() { // 
			java.util.Map<Integer, Integer> v;
			varMap _o_ = varMap.this;
			v = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.v.entrySet())
				v.put(_e_.getKey(), _e_.getValue());
			return v;
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
			return varMap.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return varMap.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return varMap.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return varMap.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return varMap.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return varMap.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return varMap.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return varMap.this.hashCode();
		}

		@Override
		public String toString() {
			return varMap.this.toString();
		}

	}

	public static final class Data implements xbean.varMap {
		private java.util.HashMap<Integer, Integer> v; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			v = new java.util.HashMap<Integer, Integer>();
		}

		Data(xbean.varMap _o1_) {
			if (_o1_ instanceof varMap) assign((varMap)_o1_);
			else if (_o1_ instanceof varMap.Data) assign((varMap.Data)_o1_);
			else if (_o1_ instanceof varMap.Const) assign(((varMap.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(varMap _o_) {
			v = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.v.entrySet())
				v.put(_e_.getKey(), _e_.getValue());
		}

		private void assign(varMap.Data _o_) {
			v = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.v.entrySet())
				v.put(_e_.getKey(), _e_.getValue());
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(v.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : v.entrySet())
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
					v = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					v.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.varMap copy() {
			return new Data(this);
		}

		@Override
		public xbean.varMap toData() {
			return new Data(this);
		}

		public xbean.varMap toBean() {
			return new varMap(this, null, null);
		}

		@Override
		public xbean.varMap toDataIf() {
			return this;
		}

		public xbean.varMap toBeanIf() {
			return new varMap(this, null, null);
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
		public java.util.Map<Integer, Integer> getV() { // 
			return v;
		}

		@Override
		public java.util.Map<Integer, Integer> getVAsData() { // 
			return v;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof varMap.Data)) return false;
			varMap.Data _o_ = (varMap.Data) _o1_;
			if (!v.equals(_o_.v)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += v.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(v);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
