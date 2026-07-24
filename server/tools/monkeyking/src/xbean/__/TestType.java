
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class TestType extends mkdb.XBean implements xbean.TestType {
	private int id; // test
	private java.util.HashMap<Integer, xbean.Second> vmap; // test

	@Override
	public void _reset_unsafe_() {
		id = 0;
		vmap.clear();
	}

	TestType(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		vmap = new java.util.HashMap<Integer, xbean.Second>();
	}

	public TestType() {
		this(0, null, null);
	}

	public TestType(TestType _o_) {
		this(_o_, null, null);
	}

	TestType(xbean.TestType _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof TestType) assign((TestType)_o1_);
		else if (_o1_ instanceof TestType.Data) assign((TestType.Data)_o1_);
		else if (_o1_ instanceof TestType.Const) assign(((TestType.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(TestType _o_) {
		id = _o_.id;
		vmap = new java.util.HashMap<Integer, xbean.Second>();
		for (java.util.Map.Entry<Integer, xbean.Second> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), new Second(_e_.getValue(), this, "vmap"));
	}

	private void assign(TestType.Data _o_) {
		id = _o_.id;
		vmap = new java.util.HashMap<Integer, xbean.Second>();
		for (java.util.Map.Entry<Integer, xbean.Second> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), new Second(_e_.getValue(), this, "vmap"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		_os_.compact_uint32(vmap.size());
		for (java.util.Map.Entry<Integer, xbean.Second> _e_ : vmap.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				vmap = new java.util.HashMap<Integer, xbean.Second>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.Second _v_ = new Second(0, this, "vmap");
				_v_.unmarshal(_os_);
				vmap.put(_k_, _v_);
			}
		}
		return _os_;
	}

	@Override
	public xbean.TestType copy() {
		return new TestType(this);
	}

	@Override
	public xbean.TestType toData() {
		return new Data(this);
	}

	public xbean.TestType toBean() {
		return new TestType(this); // same as copy()
	}

	@Override
	public xbean.TestType toDataIf() {
		return new Data(this);
	}

	public xbean.TestType toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // test
		return id;
	}

	@Override
	public java.util.Map<Integer, xbean.Second> getVmap() { // test
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "vmap"), vmap);
	}

	@Override
	public java.util.Map<Integer, xbean.Second> getVmapAsData() { // test
		java.util.Map<Integer, xbean.Second> vmap;
		TestType _o_ = this;
		vmap = new java.util.HashMap<Integer, xbean.Second>();
		for (java.util.Map.Entry<Integer, xbean.Second> _e_ : _o_.vmap.entrySet())
			vmap.put(_e_.getKey(), new Second.Data(_e_.getValue()));
		return vmap;
	}

	@Override
	public void setId(int _v_) { // test
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		TestType _o_ = null;
		if ( _o1_ instanceof TestType ) _o_ = (TestType)_o1_;
		else if ( _o1_ instanceof TestType.Const ) _o_ = ((TestType.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (!vmap.equals(_o_.vmap)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		_h_ += vmap.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(vmap);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("vmap"));
		return lb;
	}

	private class Const implements xbean.TestType {
		TestType nThis() {
			return TestType.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.TestType copy() {
			return TestType.this.copy();
		}

		@Override
		public xbean.TestType toData() {
			return TestType.this.toData();
		}

		public xbean.TestType toBean() {
			return TestType.this.toBean();
		}

		@Override
		public xbean.TestType toDataIf() {
			return TestType.this.toDataIf();
		}

		public xbean.TestType toBeanIf() {
			return TestType.this.toBeanIf();
		}

		@Override
		public int getId() { // test
			return id;
		}

		@Override
		public java.util.Map<Integer, xbean.Second> getVmap() { // test
			return mkdb.Consts.constMap(vmap);
		}

		@Override
		public java.util.Map<Integer, xbean.Second> getVmapAsData() { // test
			java.util.Map<Integer, xbean.Second> vmap;
			TestType _o_ = TestType.this;
			vmap = new java.util.HashMap<Integer, xbean.Second>();
			for (java.util.Map.Entry<Integer, xbean.Second> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), new Second.Data(_e_.getValue()));
			return vmap;
		}

		@Override
		public void setId(int _v_) { // test
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
			return TestType.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return TestType.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return TestType.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return TestType.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return TestType.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return TestType.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return TestType.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return TestType.this.hashCode();
		}

		@Override
		public String toString() {
			return TestType.this.toString();
		}

	}

	public static final class Data implements xbean.TestType {
		private int id; // test
		private java.util.HashMap<Integer, xbean.Second> vmap; // test

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			vmap = new java.util.HashMap<Integer, xbean.Second>();
		}

		Data(xbean.TestType _o1_) {
			if (_o1_ instanceof TestType) assign((TestType)_o1_);
			else if (_o1_ instanceof TestType.Data) assign((TestType.Data)_o1_);
			else if (_o1_ instanceof TestType.Const) assign(((TestType.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(TestType _o_) {
			id = _o_.id;
			vmap = new java.util.HashMap<Integer, xbean.Second>();
			for (java.util.Map.Entry<Integer, xbean.Second> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), new Second.Data(_e_.getValue()));
		}

		private void assign(TestType.Data _o_) {
			id = _o_.id;
			vmap = new java.util.HashMap<Integer, xbean.Second>();
			for (java.util.Map.Entry<Integer, xbean.Second> _e_ : _o_.vmap.entrySet())
				vmap.put(_e_.getKey(), new Second.Data(_e_.getValue()));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.compact_uint32(vmap.size());
			for (java.util.Map.Entry<Integer, xbean.Second> _e_ : vmap.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					vmap = new java.util.HashMap<Integer, xbean.Second>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.Second _v_ = xbean.Pod.newSecondData();
					_v_.unmarshal(_os_);
					vmap.put(_k_, _v_);
				}
			}
			return _os_;
		}

		@Override
		public xbean.TestType copy() {
			return new Data(this);
		}

		@Override
		public xbean.TestType toData() {
			return new Data(this);
		}

		public xbean.TestType toBean() {
			return new TestType(this, null, null);
		}

		@Override
		public xbean.TestType toDataIf() {
			return this;
		}

		public xbean.TestType toBeanIf() {
			return new TestType(this, null, null);
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
		public int getId() { // test
			return id;
		}

		@Override
		public java.util.Map<Integer, xbean.Second> getVmap() { // test
			return vmap;
		}

		@Override
		public java.util.Map<Integer, xbean.Second> getVmapAsData() { // test
			return vmap;
		}

		@Override
		public void setId(int _v_) { // test
			id = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof TestType.Data)) return false;
			TestType.Data _o_ = (TestType.Data) _o1_;
			if (id != _o_.id) return false;
			if (!vmap.equals(_o_.vmap)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += vmap.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(vmap);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
