
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class RBTest extends mkdb.XBean implements xbean.RBTest {
	private int i; // int test
	private xbean.RB rb; // int test
	private mkdb.util.SetX<xbean.RB> set; // a
	private java.util.LinkedList<xbean.RB> list; // b
	private java.util.HashMap<Integer, xbean.RB> map; // d
	private java.util.TreeMap<Integer, xbean.RB> tree; // d

	@Override
	public void _reset_unsafe_() {
		i = 1;
		rb._reset_unsafe_();
		set.clear();
		list.clear();
		map.clear();
		tree.clear();
	}

	RBTest(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		i = 1;
		rb = new RB(0, this, "rb");
		set = new mkdb.util.SetX<xbean.RB>();
		list = new java.util.LinkedList<xbean.RB>();
		map = new java.util.HashMap<Integer, xbean.RB>();
		tree = new java.util.TreeMap<Integer, xbean.RB>();
	}

	public RBTest() {
		this(0, null, null);
	}

	public RBTest(RBTest _o_) {
		this(_o_, null, null);
	}

	RBTest(xbean.RBTest _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof RBTest) assign((RBTest)_o1_);
		else if (_o1_ instanceof RBTest.Data) assign((RBTest.Data)_o1_);
		else if (_o1_ instanceof RBTest.Const) assign(((RBTest.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(RBTest _o_) {
		i = _o_.i;
		rb = new RB(_o_.rb, this, "rb");
		set = new mkdb.util.SetX<xbean.RB>();
		for (xbean.RB _v_ : _o_.set)
			set.add(new RB(_v_, this, "set"));
		list = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list)
			list.add(new RB(_v_, this, "list"));
		map = new java.util.HashMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map.entrySet())
			map.put(_e_.getKey(), new RB(_e_.getValue(), this, "map"));
		tree = new java.util.TreeMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.tree.entrySet())
			tree.put(_e_.getKey(), new RB(_e_.getValue(), this, "tree"));
	}

	private void assign(RBTest.Data _o_) {
		i = _o_.i;
		rb = new RB(_o_.rb, this, "rb");
		set = new mkdb.util.SetX<xbean.RB>();
		for (xbean.RB _v_ : _o_.set)
			set.add(new RB(_v_, this, "set"));
		list = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list)
			list.add(new RB(_v_, this, "list"));
		map = new java.util.HashMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map.entrySet())
			map.put(_e_.getKey(), new RB(_e_.getValue(), this, "map"));
		tree = new java.util.TreeMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.tree.entrySet())
			tree.put(_e_.getKey(), new RB(_e_.getValue(), this, "tree"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(i);
		rb.marshal(_os_);
		_os_.compact_uint32(set.size());
		for (xbean.RB _v_ : set) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(list.size());
		for (xbean.RB _v_ : list) {
			_v_.marshal(_os_);
		}
		_os_.compact_uint32(map.size());
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : map.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		_os_.compact_uint32(tree.size());
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : tree.entrySet())
		{
			_os_.marshal(_e_.getKey());
			_e_.getValue().marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		i = _os_.unmarshal_int();
		rb.unmarshal(_os_);
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.RB _v_ = new RB(0, this, "set");
			_v_.unmarshal(_os_);
			set.add(_v_);
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.RB _v_ = new RB(0, this, "list");
			_v_.unmarshal(_os_);
			list.add(_v_);
		}
		{
			int size = _os_.uncompact_uint32();
			if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
				map = new java.util.HashMap<Integer, xbean.RB>(size * 2);
			}
			for (; size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.RB _v_ = new RB(0, this, "map");
				_v_.unmarshal(_os_);
				map.put(_k_, _v_);
			}
		}
		for (int size = _os_.uncompact_uint32(); size > 0; --size)
		{
			int _k_ = 0;
			_k_ = _os_.unmarshal_int();
			xbean.RB _v_ = new RB(0, this, "tree");
			_v_.unmarshal(_os_);
			tree.put(_k_, _v_);
		}
		return _os_;
	}

	@Override
	public xbean.RBTest copy() {
		return new RBTest(this);
	}

	@Override
	public xbean.RBTest toData() {
		return new Data(this);
	}

	public xbean.RBTest toBean() {
		return new RBTest(this); // same as copy()
	}

	@Override
	public xbean.RBTest toDataIf() {
		return new Data(this);
	}

	public xbean.RBTest toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getI() { // int test
		return i;
	}

	@Override
	public xbean.RB getRb() { // int test
		return rb;
	}

	@Override
	public java.util.Set<xbean.RB> getSet() { // a
		return mkdb.Logs.logSet(new mkdb.LogKey(this, "set"), set);
	}

	public java.util.Set<xbean.RB> getSetAsData() { // a
		java.util.Set<xbean.RB> set;
		RBTest _o_ = this;
		set = new mkdb.util.SetX<xbean.RB>();
		for (xbean.RB _v_ : _o_.set)
			set.add(new RB.Data(_v_));
		return set;
	}

	@Override
	public java.util.List<xbean.RB> getList() { // b
		return mkdb.Logs.logList(new mkdb.LogKey(this, "list"), list);
	}

	public java.util.List<xbean.RB> getListAsData() { // b
		java.util.List<xbean.RB> list;
		RBTest _o_ = this;
		list = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list)
			list.add(new RB.Data(_v_));
		return list;
	}

	@Override
	public java.util.Map<Integer, xbean.RB> getMap() { // d
		return mkdb.Logs.logMap(new mkdb.LogKey(this, "map"), map);
	}

	@Override
	public java.util.Map<Integer, xbean.RB> getMapAsData() { // d
		java.util.Map<Integer, xbean.RB> map;
		RBTest _o_ = this;
		map = new java.util.HashMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map.entrySet())
			map.put(_e_.getKey(), new RB.Data(_e_.getValue()));
		return map;
	}

	@Override
	public java.util.NavigableMap<Integer, xbean.RB> getTree() { // d
		return mkdb.Logs.logNavigableMap(new mkdb.LogKey(this, "tree"), tree);
	}

	public java.util.NavigableMap<Integer, xbean.RB> getTreeAsData() { // d
		java.util.NavigableMap<Integer, xbean.RB> tree;
		RBTest _o_ = this;
		tree = new java.util.TreeMap<Integer, xbean.RB>();
		for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.tree.entrySet())
			tree.put(_e_.getKey(), new RB.Data(_e_.getValue()));
		return tree;
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
	public final boolean equals(Object _o1_) {
		RBTest _o_ = null;
		if ( _o1_ instanceof RBTest ) _o_ = (RBTest)_o1_;
		else if ( _o1_ instanceof RBTest.Const ) _o_ = ((RBTest.Const)_o1_).nThis();
		else return false;
		if (i != _o_.i) return false;
		if (!rb.equals(_o_.rb)) return false;
		if (!set.equals(_o_.set)) return false;
		if (!list.equals(_o_.list)) return false;
		if (!map.equals(_o_.map)) return false;
		if (!tree.equals(_o_.tree)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += i;
		_h_ += rb.hashCode();
		_h_ += set.hashCode();
		_h_ += list.hashCode();
		_h_ += map.hashCode();
		_h_ += tree.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(i);
		_sb_.append(",");
		_sb_.append(rb);
		_sb_.append(",");
		_sb_.append(set);
		_sb_.append(",");
		_sb_.append(list);
		_sb_.append(",");
		_sb_.append(map);
		_sb_.append(",");
		_sb_.append(tree);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("i"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("rb"));
		lb.add(new mkdb.logs.ListenableSet().setVarName("set"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("list"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("map"));
		lb.add(new mkdb.logs.ListenableMap().setVarName("tree"));
		return lb;
	}

	private class Const implements xbean.RBTest {
		RBTest nThis() {
			return RBTest.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.RBTest copy() {
			return RBTest.this.copy();
		}

		@Override
		public xbean.RBTest toData() {
			return RBTest.this.toData();
		}

		public xbean.RBTest toBean() {
			return RBTest.this.toBean();
		}

		@Override
		public xbean.RBTest toDataIf() {
			return RBTest.this.toDataIf();
		}

		public xbean.RBTest toBeanIf() {
			return RBTest.this.toBeanIf();
		}

		@Override
		public int getI() { // int test
			return i;
		}

		@Override
		public xbean.RB getRb() { // int test
			return mkdb.Consts.toConst(rb);
		}

		@Override
		public java.util.Set<xbean.RB> getSet() { // a
			return mkdb.Consts.constSet(set);
		}

		public java.util.Set<xbean.RB> getSetAsData() { // a
			java.util.Set<xbean.RB> set;
			RBTest _o_ = RBTest.this;
		set = new mkdb.util.SetX<xbean.RB>();
		for (xbean.RB _v_ : _o_.set)
			set.add(new RB.Data(_v_));
			return set;
		}

		@Override
		public java.util.List<xbean.RB> getList() { // b
			return mkdb.Consts.constList(list);
		}

		public java.util.List<xbean.RB> getListAsData() { // b
			java.util.List<xbean.RB> list;
			RBTest _o_ = RBTest.this;
		list = new java.util.LinkedList<xbean.RB>();
		for (xbean.RB _v_ : _o_.list)
			list.add(new RB.Data(_v_));
			return list;
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMap() { // d
			return mkdb.Consts.constMap(map);
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMapAsData() { // d
			java.util.Map<Integer, xbean.RB> map;
			RBTest _o_ = RBTest.this;
			map = new java.util.HashMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map.entrySet())
				map.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			return map;
		}

		@Override
		public java.util.NavigableMap<Integer, xbean.RB> getTree() { // d
			return mkdb.Consts.constNavigableMap(tree);
		}

		@Override
		public java.util.NavigableMap<Integer, xbean.RB> getTreeAsData() { // d
			java.util.NavigableMap<Integer, xbean.RB> tree;
			RBTest _o_ = RBTest.this;
			tree = new java.util.TreeMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.tree.entrySet())
				tree.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			return tree;
		}

		@Override
		public void setI(int _v_) { // int test
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
			return RBTest.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return RBTest.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return RBTest.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return RBTest.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return RBTest.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return RBTest.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return RBTest.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return RBTest.this.hashCode();
		}

		@Override
		public String toString() {
			return RBTest.this.toString();
		}

	}

	public static final class Data implements xbean.RBTest {
		private int i; // int test
		private xbean.RB rb; // int test
		private java.util.HashSet<xbean.RB> set; // a
		private java.util.LinkedList<xbean.RB> list; // b
		private java.util.HashMap<Integer, xbean.RB> map; // d
		private java.util.TreeMap<Integer, xbean.RB> tree; // d

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			i = 1;
			rb = new RB.Data();
			set = new java.util.HashSet<xbean.RB>();
			list = new java.util.LinkedList<xbean.RB>();
			map = new java.util.HashMap<Integer, xbean.RB>();
			tree = new java.util.TreeMap<Integer, xbean.RB>();
		}

		Data(xbean.RBTest _o1_) {
			if (_o1_ instanceof RBTest) assign((RBTest)_o1_);
			else if (_o1_ instanceof RBTest.Data) assign((RBTest.Data)_o1_);
			else if (_o1_ instanceof RBTest.Const) assign(((RBTest.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(RBTest _o_) {
			i = _o_.i;
			rb = new RB.Data(_o_.rb);
			set = new java.util.HashSet<xbean.RB>();
			for (xbean.RB _v_ : _o_.set)
				set.add(new RB.Data(_v_));
			list = new java.util.LinkedList<xbean.RB>();
			for (xbean.RB _v_ : _o_.list)
				list.add(new RB.Data(_v_));
			map = new java.util.HashMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map.entrySet())
				map.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			tree = new java.util.TreeMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.tree.entrySet())
				tree.put(_e_.getKey(), new RB.Data(_e_.getValue()));
		}

		private void assign(RBTest.Data _o_) {
			i = _o_.i;
			rb = new RB.Data(_o_.rb);
			set = new java.util.HashSet<xbean.RB>();
			for (xbean.RB _v_ : _o_.set)
				set.add(new RB.Data(_v_));
			list = new java.util.LinkedList<xbean.RB>();
			for (xbean.RB _v_ : _o_.list)
				list.add(new RB.Data(_v_));
			map = new java.util.HashMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.map.entrySet())
				map.put(_e_.getKey(), new RB.Data(_e_.getValue()));
			tree = new java.util.TreeMap<Integer, xbean.RB>();
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : _o_.tree.entrySet())
				tree.put(_e_.getKey(), new RB.Data(_e_.getValue()));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(i);
			rb.marshal(_os_);
			_os_.compact_uint32(set.size());
			for (xbean.RB _v_ : set) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(list.size());
			for (xbean.RB _v_ : list) {
				_v_.marshal(_os_);
			}
			_os_.compact_uint32(map.size());
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : map.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			_os_.compact_uint32(tree.size());
			for (java.util.Map.Entry<Integer, xbean.RB> _e_ : tree.entrySet())
			{
				_os_.marshal(_e_.getKey());
				_e_.getValue().marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			i = _os_.unmarshal_int();
			rb.unmarshal(_os_);
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.RB _v_ = xbean.Pod.newRBData();
				_v_.unmarshal(_os_);
				set.add(_v_);
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.RB _v_ = xbean.Pod.newRBData();
				_v_.unmarshal(_os_);
				list.add(_v_);
			}
			{
				int size = _os_.uncompact_uint32();
				if (size >= 12) { // {java.util.HashMap} 16 * 0.75 = 12
					map = new java.util.HashMap<Integer, xbean.RB>(size * 2);
				}
				for (; size > 0; --size)
				{
					int _k_ = 0;
					_k_ = _os_.unmarshal_int();
					xbean.RB _v_ = xbean.Pod.newRBData();
					_v_.unmarshal(_os_);
					map.put(_k_, _v_);
				}
			}
			for (int size = _os_.uncompact_uint32(); size > 0; --size)
			{
				int _k_ = 0;
				_k_ = _os_.unmarshal_int();
				xbean.RB _v_ = xbean.Pod.newRBData();
				_v_.unmarshal(_os_);
				tree.put(_k_, _v_);
			}
			return _os_;
		}

		@Override
		public xbean.RBTest copy() {
			return new Data(this);
		}

		@Override
		public xbean.RBTest toData() {
			return new Data(this);
		}

		public xbean.RBTest toBean() {
			return new RBTest(this, null, null);
		}

		@Override
		public xbean.RBTest toDataIf() {
			return this;
		}

		public xbean.RBTest toBeanIf() {
			return new RBTest(this, null, null);
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
		public int getI() { // int test
			return i;
		}

		@Override
		public xbean.RB getRb() { // int test
			return rb;
		}

		@Override
		public java.util.Set<xbean.RB> getSet() { // a
			return set;
		}

		@Override
		public java.util.Set<xbean.RB> getSetAsData() { // a
			return set;
		}

		@Override
		public java.util.List<xbean.RB> getList() { // b
			return list;
		}

		@Override
		public java.util.List<xbean.RB> getListAsData() { // b
			return list;
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMap() { // d
			return map;
		}

		@Override
		public java.util.Map<Integer, xbean.RB> getMapAsData() { // d
			return map;
		}

		@Override
		public java.util.NavigableMap<Integer, xbean.RB> getTree() { // d
			return tree;
		}

		@Override
		public java.util.NavigableMap<Integer, xbean.RB> getTreeAsData() { // d
			return tree;
		}

		@Override
		public void setI(int _v_) { // int test
			i = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof RBTest.Data)) return false;
			RBTest.Data _o_ = (RBTest.Data) _o1_;
			if (i != _o_.i) return false;
			if (!rb.equals(_o_.rb)) return false;
			if (!set.equals(_o_.set)) return false;
			if (!list.equals(_o_.list)) return false;
			if (!map.equals(_o_.map)) return false;
			if (!tree.equals(_o_.tree)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += i;
			_h_ += rb.hashCode();
			_h_ += set.hashCode();
			_h_ += list.hashCode();
			_h_ += map.hashCode();
			_h_ += tree.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(i);
			_sb_.append(",");
			_sb_.append(rb);
			_sb_.append(",");
			_sb_.append(set);
			_sb_.append(",");
			_sb_.append(list);
			_sb_.append(",");
			_sb_.append(map);
			_sb_.append(",");
			_sb_.append(tree);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
