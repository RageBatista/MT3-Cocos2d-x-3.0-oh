
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class TestLP extends mkdb.XBean implements xbean.TestLP {
	private int i; // test Listener Performance
	private mkdb.util.SetX<Integer> set1; // 
	private java.util.HashMap<Integer, Integer> map1; // 
	private java.util.LinkedList<Integer> list1; // 
	private java.util.HashMap<Integer, xbean.RB> map2; // test update
	private java.util.LinkedList<xbean.RB> list2; // test update

	@Override
	public void _reset_unsafe_() {
		i = 0;
		set1.clear();
		map1.clear();
		list1.clear();
		map2.clear();
		list2.clear();
	}

	TestLP(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		set1 = new mkdb.util.SetX<Integer>();
		map1 = new java.util.HashMap<Integer, Integer>();
		list1 = new java.util.LinkedList<Integer>();
		map2 = new java.util.HashMap<Integer, xbean.RB>();
		list2 = new java.util.LinkedList<xbean.RB>();
	}

	public TestLP() {
		this(0, null, null);
	}

	public TestLP(TestLP _o_) {
		this(_o_, null, null);
	}

	TestLP(xbean.TestLP _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof TestLP) assign((TestLP)_o1_);
		else if (_o1_ instanceof TestLP.Data) assign((TestLP.Data)_o1_);
		else if (_o1_ instanceof TestLP.Const) assign(((TestLP.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(TestLP _o_) {
		i = _o_.i;
		set1 = new mkdb.util.SetX<Integer>();
		set1.addAll(_o_.set1);
		map1 = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.map1.entrySet())
			map1.put(_e_.getKey(), _e_.getValue());
		list1 = new java.util.LinkedList<Integer>();
		list1.addAll(_o_.list1);
		map2 = new java.util.HashMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map2.entrySet())
			map2.put(_e_.getKey(), new RB(_e_.getValue(), this, "map2"));
		list2 = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list2)
			list2.add(new RB(_v_, this, "list2"));
	}

	private void assign(TestLP.Data _o_) {
		i = _o_.i;
		set1 = new mkdb.util.SetX<Integer>();
		set1.addAll(_o_.set1);
		map1 = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.map1.entrySet())
			map1.put(_e_.getKey(), _e_.getValue());
		list1 = new java.util.LinkedList<Integer>();
		list1.addAll(_o_.list1);
		map2 = new java.util.HashMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map2.entrySet())
			map2.put(_e_.getKey(), new RB(_e_.getValue(), this, "map2"));
		list2 = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list2)
			list2.add(new RB(_v_, this, "list2"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(i);
		_os_.compact_uint32(set1.size());
		for (Integer _v_ : set1) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(map1.size());
		for (java.util.Map.Entry<Integer, Integer> _e_ : map1.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_os_.marshal(_e_.getValue());
		}
		_os_.compact_uint32(list1.size());
		for (Integer _v_ : list1) {
			_os_.marshal(_v_);
		}
		_os_.compact_uint32(map2.size());
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : map2.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		_os_.compact_uint32(list2.size());
		for (xbean.RB _v_ : list2) {
			_v_.marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		i = _os_.unmarshal_int();
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			set1.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				map1 = new java.util.HashMap<Integer, Integer>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				map1.put(_k_, _v_);
			}
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			int _v_ = 0;
			_v_ = _os_.unmarshal_int();
			list1.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				map2 = new java.util.HashMap<Integer, xbean.RB>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.RB _v_ = new RB(0, this, "map2");
				_v_.unmarshal(_os_);
				map2.put(_k_, _v_);
			}
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.RB _v_ = new RB(0, this, "list2");
			_v_.unmarshal(_os_);
			list2.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.TestLP copy() {
		return new TestLP(this);
	}

	@Override
	public xbean.TestLP toData() {
		return new Data(this);
	}

	public xbean.TestLP toBean() {
		return new TestLP(this); // same as copy()
	}

	@Override
	public xbean.TestLP toDataIf() {
		return new Data(this);
	}

	public xbean.TestLP toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getI() { // test Listener Performance
		return i;
	}

	@Override
	public java.util.Set<Integer> getSet1() { // 
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "set1"), set1);
	}

	public java.util.Set<Integer> getSet1AsData() { // 
		java.util.Set<Integer> set1;
		TestLP _o_ = this;
		set1 = new mkdb.util.SetX<Integer>();
		set1.addAll(_o_.set1);
		return set1;
	}

	@Override
	public java.util.Map<Integer, Integer> getMap1() { // 
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "map1"), map1);
	}

	@Override
	public java.util.Map<Integer, Integer> getMap1AsData() { // 
		java.util.Map<Integer, Integer> map1;
		TestLP _o_ = this;
		map1 = new java.util.HashMap<Integer, Integer>();
		for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.map1.entrySet())
			map1.put(_e_.getKey(), _e_.getValue());
		return map1;
	}

	@Override
	public java.util.List<Integer> getList1() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "list1"), list1);
	}

	public java.util.List<Integer> getList1AsData() { // 
		java.util.List<Integer> list1;
		TestLP _o_ = this;
		list1 = new java.util.LinkedList<Integer>();
		list1.addAll(_o_.list1);
		return list1;
	}

	@Override
	public java.util.Map<Integer, xbean.RB> getMap2() { // test update
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "map2"), map2);
	}

	@Override
	public java.util.Map<Integer, xbean.RB> getMap2AsData() { // test update
		java.util.Map<Integer, xbean.RB> map2;
		TestLP _o_ = this;
		map2 = new java.util.HashMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map2.entrySet())
			map2.put(_e_.getKey(), new RB.Data(_e_.getValue()));
		return map2;
	}

	@Override
	public java.util.List<xbean.RB> getList2() { // test update
		return mkdb.Logs.logList(new mkdb.LogKey(this, "list2"), list2);
	}

	public java.util.List<xbean.RB> getList2AsData() { // test update
		java.util.List<xbean.RB> list2;
		TestLP _o_ = this;
		list2 = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list2)
			list2.add(new RB.Data(_v_));
		return list2;
	}

	@Override
	public void setI(int _v_) { // test Listener Performance
		mkdb.Logs.logIf(new mkdb.LogKey(this, "i") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, i) {
					public void rollback() { i = _xdb_saved; }
				};}});
		i = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		TestLP _o_ = null;
		if ( _o1_ instanceof TestLP ) _o_ = (TestLP)_o1_;
		else if ( _o1_ instanceof TestLP.Const ) _o_ = ((TestLP.Const)_o1_).nThis();
		else return false;
		if (i != _o_.i) return false;
		if (!set1.equals(_o_.set1)) return false;
		if (!map1.equals(_o_.map1)) return false;
		if (!list1.equals(_o_.list1)) return false;
		if (!map2.equals(_o_.map2)) return false;
		if (!list2.equals(_o_.list2)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += i;
		_h_ += set1.hashCode();
		_h_ += map1.hashCode();
		_h_ += list1.hashCode();
		_h_ += map2.hashCode();
		_h_ += list2.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(i);
		_sb_.append(",");
		_sb_.append(set1);
		_sb_.append(",");
		_sb_.append(map1);
		_sb_.append(",");
		_sb_.append(list1);
		_sb_.append(",");
		_sb_.append(map2);
		_sb_.append(",");
		_sb_.append(list2);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("i"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("set1"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("map1"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("list1"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("map2"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("list2"));
		return lb;
	}

	private class Const implements xbean.TestLP {
		TestLP nThis() {
			return TestLP.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.TestLP copy() {
			return TestLP.this.copy();
		}

		@Override
		public xbean.TestLP toData() {
			return TestLP.this.toData();
		}

		public xbean.TestLP toBean() {
			return TestLP.this.toBean();
		}

		@Override
		public xbean.TestLP toDataIf() {
			return TestLP.this.toDataIf();
		}

		public xbean.TestLP toBeanIf() {
			return TestLP.this.toBeanIf();
		}

		@Override
		public int getI() { // test Listener Performance
			return i;
		}

		@Override
		public java.util.Set<Integer> getSet1() { // 
			return mkdb.Consts.constSet(set1);
		}

		public java.util.Set<Integer> getSet1AsData() { // 
			java.util.Set<Integer> set1;
			TestLP _o_ = TestLP.this;
		set1 = new mkdb.util.SetX<Integer>();
		set1.addAll(_o_.set1);
			return set1;
		}

		@Override
		public java.util.Map<Integer, Integer> getMap1() { // 
			return mkdb.Consts.constMap(map1);
		}

		@Override
		public java.util.Map<Integer, Integer> getMap1AsData() { // 
			java.util.Map<Integer, Integer> map1;
			TestLP _o_ = TestLP.this;
			map1 = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.map1.entrySet())
				map1.put(_e_.getKey(), _e_.getValue());
			return map1;
		}

		@Override
		public java.util.List<Integer> getList1() { // 
			return mkdb.Consts.constList(list1);
		}

		public java.util.List<Integer> getList1AsData() { // 
			java.util.List<Integer> list1;
			TestLP _o_ = TestLP.this;
		list1 = new java.util.LinkedList<Integer>();
		list1.addAll(_o_.list1);
			return list1;
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMap2() { // test update
			return mkdb.Consts.constMap(map2);
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMap2AsData() { // test update
			java.util.Map<Integer, xbean.RB> map2;
			TestLP _o_ = TestLP.this;
			map2 = new java.util.HashMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map2.entrySet())
				map2.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			return map2;
		}

		@Override
		public java.util.List<xbean.RB> getList2() { // test update
			return mkdb.Consts.constList(list2);
		}

		public java.util.List<xbean.RB> getList2AsData() { // test update
			java.util.List<xbean.RB> list2;
			TestLP _o_ = TestLP.this;
		list2 = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list2)
			list2.add(new RB.Data(_v_));
			return list2;
		}

		@Override
		public void setI(int _v_) { // test Listener Performance
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
			return TestLP.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return TestLP.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return TestLP.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return TestLP.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return TestLP.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return TestLP.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return TestLP.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return TestLP.this.hashCode();
		}

		@Override
		public String toString() {
			return TestLP.this.toString();
		}

	}

	public static final class Data implements xbean.TestLP {
		private int i; // test Listener Performance
		private java.util.HashSet<Integer> set1; // 
		private java.util.HashMap<Integer, Integer> map1; // 
		private java.util.LinkedList<Integer> list1; // 
		private java.util.HashMap<Integer, xbean.RB> map2; // test update
		private java.util.LinkedList<xbean.RB> list2; // test update

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			set1 = new java.util.HashSet<Integer>();
			map1 = new java.util.HashMap<Integer, Integer>();
			list1 = new java.util.LinkedList<Integer>();
			map2 = new java.util.HashMap<Integer, xbean.RB>();
			list2 = new java.util.LinkedList<xbean.RB>();
		}

		Data(xbean.TestLP _o1_) {
			if (_o1_ instanceof TestLP) assign((TestLP)_o1_);
			else if (_o1_ instanceof TestLP.Data) assign((TestLP.Data)_o1_);
			else if (_o1_ instanceof TestLP.Const) assign(((TestLP.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(TestLP _o_) {
			i = _o_.i;
			set1 = new java.util.HashSet<Integer>();
			set1.addAll(_o_.set1);
			map1 = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.map1.entrySet())
				map1.put(_e_.getKey(), _e_.getValue());
			list1 = new java.util.LinkedList<Integer>();
			list1.addAll(_o_.list1);
			map2 = new java.util.HashMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map2.entrySet())
				map2.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			list2 = new java.util.LinkedList<xbean.RB>();
			for (xbean.RB _v_ : _o_.list2)
				list2.add(new RB.Data(_v_));
		}

		private void assign(TestLP.Data _o_) {
			i = _o_.i;
			set1 = new java.util.HashSet<Integer>();
			set1.addAll(_o_.set1);
			map1 = new java.util.HashMap<Integer, Integer>();
			for (java.util.Map.Entry<Integer, Integer> _e_ : _o_.map1.entrySet())
				map1.put(_e_.getKey(), _e_.getValue());
			list1 = new java.util.LinkedList<Integer>();
			list1.addAll(_o_.list1);
			map2 = new java.util.HashMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map2.entrySet())
				map2.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			list2 = new java.util.LinkedList<xbean.RB>();
			for (xbean.RB _v_ : _o_.list2)
				list2.add(new RB.Data(_v_));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(i);
			_os_.compact_uint32(set1.size());
			for (Integer _v_ : set1) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(map1.size());
			for (java.util.Map.Entry<Integer, Integer> _e_ : map1.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_os_.marshal(_e_.getValue());
			}
			_os_.compact_uint32(list1.size());
			for (Integer _v_ : list1) {
				_os_.marshal(_v_);
			}
			_os_.compact_uint32(map2.size());
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : map2.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			_os_.compact_uint32(list2.size());
			for (xbean.RB _v_ : list2) {
				_v_.marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			i = _os_.unmarshal_int();
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				set1.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					map1 = new java.util.HashMap<Integer, Integer>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					int _v_ = 0;
					_v_ = _os_.unmarshal_int();
					map1.put(_k_, _v_);
				}
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				int _v_ = 0;
				_v_ = _os_.unmarshal_int();
				list1.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					map2 = new java.util.HashMap<Integer, xbean.RB>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.RB _v_ = xbean.Pod.newRBData();
					_v_.unmarshal(_os_);
					map2.put(_k_, _v_);
				}
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.RB _v_ = xbean.Pod.newRBData();
				_v_.unmarshal(_os_);
				list2.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.TestLP copy() {
			return new Data(this);
		}

		@Override
		public xbean.TestLP toData() {
			return new Data(this);
		}

		public xbean.TestLP toBean() {
			return new TestLP(this, null, null);
		}

		@Override
		public xbean.TestLP toDataIf() {
			return this;
		}

		public xbean.TestLP toBeanIf() {
			return new TestLP(this, null, null);
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
		public int getI() { // test Listener Performance
			return i;
		}

		@Override
		public java.util.Set<Integer> getSet1() { // 
			return set1;
		}

		@Override
		public java.util.Set<Integer> getSet1AsData() { // 
			return set1;
		}

		@Override
		public java.util.Map<Integer, Integer> getMap1() { // 
			return map1;
		}

		@Override
		public java.util.Map<Integer, Integer> getMap1AsData() { // 
			return map1;
		}

		@Override
		public java.util.List<Integer> getList1() { // 
			return list1;
		}

		@Override
		public java.util.List<Integer> getList1AsData() { // 
			return list1;
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMap2() { // test update
			return map2;
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMap2AsData() { // test update
			return map2;
		}

		@Override
		public java.util.List<xbean.RB> getList2() { // test update
			return list2;
		}

		@Override
		public java.util.List<xbean.RB> getList2AsData() { // test update
			return list2;
		}

		@Override
		public void setI(int _v_) { // test Listener Performance
			i = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof TestLP.Data)) return false;
			TestLP.Data _o_ = (TestLP.Data) _o1_;
			if (i != _o_.i) return false;
			if (!set1.equals(_o_.set1)) return false;
			if (!map1.equals(_o_.map1)) return false;
			if (!list1.equals(_o_.list1)) return false;
			if (!map2.equals(_o_.map2)) return false;
			if (!list2.equals(_o_.list2)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += i;
			_h_ += set1.hashCode();
			_h_ += map1.hashCode();
			_h_ += list1.hashCode();
			_h_ += map2.hashCode();
			_h_ += list2.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(i);
			_sb_.append(",");
			_sb_.append(set1);
			_sb_.append(",");
			_sb_.append(map1);
			_sb_.append(",");
			_sb_.append(list1);
			_sb_.append(",");
			_sb_.append(map2);
			_sb_.append(",");
			_sb_.append(list2);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
