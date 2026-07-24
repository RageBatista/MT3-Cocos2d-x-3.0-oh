package xtable;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public class _Tables_ extends mkdb.Tables {
	static volatile boolean isExplicitLockCheck = false;

	public static void startExplicitLockCheck() {
		isExplicitLockCheck = true;
	}

	public static _Tables_ getInstance() {
		return (_Tables_)mkdb.Mkdb.getInstance().getTables();
	}

	public _Tables_() {
		add(t4);
		add(table_int);
		add(testmerge);
		add(fcbean);
		add(memory);
		add(cachenull);
		add(fshort);
		add(listlistenertest);
		add(keyisxcompare2);
		add(anyfake);
		add(f1);
		add(f2);
		add(f3);
		add(tany);
		add(second);
		add(table_set);
		add(diskdbh);
		add(fboolean);
		add(mem);
		add(table_map);
		add(table_xbean);
		add(table_int_int);
		add(flush3);
		add(flush2);
		add(secondaryindex);
		add(flush1);
		add(cachetest);
		add(table_string);
		add(at2);
		add(tlong);
		add(fint);
		add(fstring);
		add(ffloat);
		add(var_test_s);
		add(netbar);
		add(t4cache);
		add(any);
		add(var_test_m);
		add(flong);
		add(testtype);
		add(afirst);
		add(family);
		add(lperform);
		add(first);
		add(t2);
		add(t3);
		add(tshort);
	}

	// visible in package
	mkdb.TTable<String, xbean.First> t4 = new mkdb.TTable<String, xbean.First>() {
		@Override
		public String getName() {
			return "t4";
		}

		@Override
		public OctetsStream marshalKey(String key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.First value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public String unmarshalKey(OctetsStream _os_) throws MarshalException {
			String key = "";
			key = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return key;
		}

		@Override
		public xbean.First unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.First value = xbean.Pod.newFirst();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.First newValue() {
			xbean.First value = xbean.Pod.newFirst();
			return value;
		}

	};

	mkdb.TTable<Integer, Integer> table_int = new mkdb.TTable<Integer, Integer>() {
		@Override
		public String getName() {
			return "table_int";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Long, xbean.RBTest> testmerge = new mkdb.TTable<Long, xbean.RBTest>() {
		@Override
		public String getName() {
			return "testmerge";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.RBTest value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.RBTest unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.RBTest value = xbean.Pod.newRBTest();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.RBTest newValue() {
			xbean.RBTest value = xbean.Pod.newRBTest();
			return value;
		}

	};

	mkdb.TTable<xbean.fcbean, Integer> fcbean = new mkdb.TTable<xbean.fcbean, Integer>() {
		@Override
		public String getName() {
			return "fcbean";
		}

		@Override
		public OctetsStream marshalKey(xbean.fcbean key) {
			OctetsStream _os_ = new OctetsStream();
			key.marshal(_os_);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public xbean.fcbean unmarshalKey(OctetsStream _os_) throws MarshalException {
			xbean.fcbean key = new xbean.fcbean();
			key.unmarshal(_os_);
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, Integer> memory = new mkdb.TTable<Integer, Integer>() {
		@Override
		public String getName() {
			return "memory";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Family> cachenull = new mkdb.TTable<Integer, xbean.Family>() {
		@Override
		public String getName() {
			return "cachenull";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Family value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Family unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Family value = xbean.Pod.newFamily();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Family newValue() {
			xbean.Family value = xbean.Pod.newFamily();
			return value;
		}

	};

	mkdb.TTable<Short, Integer> fshort = new mkdb.TTable<Short, Integer>() {
		@Override
		public String getName() {
			return "fshort";
		}

		@Override
		public OctetsStream marshalKey(Short key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Short unmarshalKey(OctetsStream _os_) throws MarshalException {
			short key = 0;
			key = _os_.unmarshal_short();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Long, xbean.ListListenerTestEffects> listlistenertest = new mkdb.TTable<Long, xbean.ListListenerTestEffects>() {
		@Override
		public String getName() {
			return "listlistenertest";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.ListListenerTestEffects value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.ListListenerTestEffects unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.ListListenerTestEffects value = xbean.Pod.newListListenerTestEffects();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.ListListenerTestEffects newValue() {
			xbean.ListListenerTestEffects value = xbean.Pod.newListListenerTestEffects();
			return value;
		}

	};

	mkdb.TTable<xbean.xcompare2, xbean.xbeanwithcbean> keyisxcompare2 = new mkdb.TTable<xbean.xcompare2, xbean.xbeanwithcbean>() {
		@Override
		public String getName() {
			return "keyisxcompare2";
		}

		@Override
		public OctetsStream marshalKey(xbean.xcompare2 key) {
			OctetsStream _os_ = new OctetsStream();
			key.marshal(_os_);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.xbeanwithcbean value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public xbean.xcompare2 unmarshalKey(OctetsStream _os_) throws MarshalException {
			xbean.xcompare2 key = new xbean.xcompare2();
			key.unmarshal(_os_);
			return key;
		}

		@Override
		public xbean.xbeanwithcbean unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.xbeanwithcbean value = xbean.Pod.newxbeanwithcbean();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.xbeanwithcbean newValue() {
			xbean.xbeanwithcbean value = xbean.Pod.newxbeanwithcbean();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.AnyFake> anyfake = new mkdb.TTable<Integer, xbean.AnyFake>() {
		@Override
		public String getName() {
			return "anyfake";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.AnyFake value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.AnyFake unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.AnyFake value = xbean.Pod.newAnyFake();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.AnyFake newValue() {
			xbean.AnyFake value = xbean.Pod.newAnyFake();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.fcbean> f1 = new mkdb.TTable<Integer, xbean.fcbean>() {
		@Override
		public String getName() {
			return "f1";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.fcbean value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.fcbean unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.fcbean value = new xbean.fcbean();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.fcbean newValue() {
			xbean.fcbean value = new xbean.fcbean();
			return value;
		}

	};

	mkdb.TTable<String, xbean.fxbean> f2 = new mkdb.TTable<String, xbean.fxbean>() {
		@Override
		public String getName() {
			return "f2";
		}

		@Override
		public OctetsStream marshalKey(String key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.fxbean value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public String unmarshalKey(OctetsStream _os_) throws MarshalException {
			String key = "";
			key = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return key;
		}

		@Override
		public xbean.fxbean unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.fxbean value = xbean.Pod.newfxbean();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.fxbean newValue() {
			xbean.fxbean value = xbean.Pod.newfxbean();
			return value;
		}

	};

	mkdb.TTable<String, xbean.fxbean> f3 = new mkdb.TTable<String, xbean.fxbean>() {
		@Override
		public String getName() {
			return "f3";
		}

		@Override
		public OctetsStream marshalKey(String key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.fxbean value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public String unmarshalKey(OctetsStream _os_) throws MarshalException {
			String key = "";
			key = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return key;
		}

		@Override
		public xbean.fxbean unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.fxbean value = xbean.Pod.newfxbean();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.fxbean newValue() {
			xbean.fxbean value = xbean.Pod.newfxbean();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Any> tany = new mkdb.TTable<Integer, xbean.Any>() {
		@Override
		public String getName() {
			return "tany";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Any value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Any unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Any value = xbean.Pod.newAny();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Any newValue() {
			xbean.Any value = xbean.Pod.newAny();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Second> second = new mkdb.TTable<Integer, xbean.Second>() {
		@Override
		public String getName() {
			return "second";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Second value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Second unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Second value = xbean.Pod.newSecond();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Second newValue() {
			xbean.Second value = xbean.Pod.newSecond();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.varSet> table_set = new mkdb.TTable<Integer, xbean.varSet>() {
		@Override
		public String getName() {
			return "table_set";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.varSet value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.varSet unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.varSet value = xbean.Pod.newvarSet();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.varSet newValue() {
			xbean.varSet value = xbean.Pod.newvarSet();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.Diskdbh> diskdbh = new mkdb.TTable<Long, xbean.Diskdbh>() {
		@Override
		public String getName() {
			return "diskdbh";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Diskdbh value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.Diskdbh unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Diskdbh value = xbean.Pod.newDiskdbh();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Diskdbh newValue() {
			xbean.Diskdbh value = xbean.Pod.newDiskdbh();
			return value;
		}

	};

	mkdb.TTable<Boolean, Integer> fboolean = new mkdb.TTable<Boolean, Integer>() {
		@Override
		public String getName() {
			return "fboolean";
		}

		@Override
		public OctetsStream marshalKey(Boolean key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Boolean unmarshalKey(OctetsStream _os_) throws MarshalException {
			boolean key = false;
			key = _os_.unmarshal_boolean();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.DataType> mem = new mkdb.TTable<Integer, xbean.DataType>() {
		@Override
		public String getName() {
			return "mem";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.DataType value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.DataType unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.DataType value = xbean.Pod.newDataType();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.DataType newValue() {
			xbean.DataType value = xbean.Pod.newDataType();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.varMap> table_map = new mkdb.TTable<Integer, xbean.varMap>() {
		@Override
		public String getName() {
			return "table_map";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.varMap value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.varMap unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.varMap value = xbean.Pod.newvarMap();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.varMap newValue() {
			xbean.varMap value = xbean.Pod.newvarMap();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.varXBean> table_xbean = new mkdb.TTable<Integer, xbean.varXBean>() {
		@Override
		public String getName() {
			return "table_xbean";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.varXBean value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.varXBean unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.varXBean value = xbean.Pod.newvarXBean();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.varXBean newValue() {
			xbean.varXBean value = xbean.Pod.newvarXBean();
			return value;
		}

	};

	mkdb.TTable<Integer, Integer> table_int_int = new mkdb.TTable<Integer, Integer>() {
		@Override
		public String getName() {
			return "table_int_int";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Flush> flush3 = new mkdb.TTable<Integer, xbean.Flush>() {
		@Override
		public String getName() {
			return "flush3";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Flush value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Flush unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Flush value = xbean.Pod.newFlush();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Flush newValue() {
			xbean.Flush value = xbean.Pod.newFlush();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Flush> flush2 = new mkdb.TTable<Integer, xbean.Flush>() {
		@Override
		public String getName() {
			return "flush2";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Flush value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Flush unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Flush value = xbean.Pod.newFlush();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Flush newValue() {
			xbean.Flush value = xbean.Pod.newFlush();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.SecondaryIndex> secondaryindex = new mkdb.TTable<Long, xbean.SecondaryIndex>() {
		@Override
		public String getName() {
			return "secondaryindex";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.SecondaryIndex value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.SecondaryIndex unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.SecondaryIndex value = xbean.Pod.newSecondaryIndex();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.SecondaryIndex newValue() {
			xbean.SecondaryIndex value = xbean.Pod.newSecondaryIndex();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Flush> flush1 = new mkdb.TTable<Integer, xbean.Flush>() {
		@Override
		public String getName() {
			return "flush1";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Flush value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Flush unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Flush value = xbean.Pod.newFlush();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Flush newValue() {
			xbean.Flush value = xbean.Pod.newFlush();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.RBTest> cachetest = new mkdb.TTable<Long, xbean.RBTest>() {
		@Override
		public String getName() {
			return "cachetest";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.RBTest value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.RBTest unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.RBTest value = xbean.Pod.newRBTest();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.RBTest newValue() {
			xbean.RBTest value = xbean.Pod.newRBTest();
			return value;
		}

	};

	mkdb.TTable<Integer, String> table_string = new mkdb.TTable<Integer, String>() {
		@Override
		public String getName() {
			return "table_string";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(String value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public String unmarshalValue(OctetsStream _os_) throws MarshalException {
			String value = "";
			value = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return value;
		}

		@Override
		public String newValue() {
			String value = "";
			return value;
		}

	};

	mkdb.TTable<Long, Integer> at2 = new mkdb.TTable<Long, Integer>() {
		@Override
		public String getName() {
			return "at2";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, Long> tlong = new mkdb.TTable<Integer, Long>() {
		@Override
		public String getName() {
			return "tlong";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Long value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public Long unmarshalValue(OctetsStream _os_) throws MarshalException {
			long value = 0;
			value = _os_.unmarshal_long();
			return value;
		}

		@Override
		public Long newValue() {
			long value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, Integer> fint = new mkdb.TTable<Integer, Integer>() {
		@Override
		public String getName() {
			return "fint";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<String, Integer> fstring = new mkdb.TTable<String, Integer>() {
		@Override
		public String getName() {
			return "fstring";
		}

		@Override
		public OctetsStream marshalKey(String key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public String unmarshalKey(OctetsStream _os_) throws MarshalException {
			String key = "";
			key = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Float, Integer> ffloat = new mkdb.TTable<Float, Integer>() {
		@Override
		public String getName() {
			return "ffloat";
		}

		@Override
		public OctetsStream marshalKey(Float key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Float unmarshalKey(OctetsStream _os_) throws MarshalException {
			float key = 0.0f;
			key = _os_.unmarshal_float();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<String, xbean.varValue> var_test_s = new mkdb.TTable<String, xbean.varValue>() {
		@Override
		public String getName() {
			return "var_test_s";
		}

		@Override
		public OctetsStream marshalKey(String key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.varValue value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public String unmarshalKey(OctetsStream _os_) throws MarshalException {
			String key = "";
			key = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return key;
		}

		@Override
		public xbean.varValue unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.varValue value = xbean.Pod.newvarValue();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.varValue newValue() {
			xbean.varValue value = xbean.Pod.newvarValue();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.NetBar> netbar = new mkdb.TTable<Long, xbean.NetBar>() {
		@Override
		public String getName() {
			return "netbar";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.NetBar value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.NetBar unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.NetBar value = xbean.Pod.newNetBar();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.NetBar newValue() {
			xbean.NetBar value = xbean.Pod.newNetBar();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.Cacheb0> t4cache = new mkdb.TTable<Long, xbean.Cacheb0>() {
		@Override
		public String getName() {
			return "t4cache";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Cacheb0 value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.Cacheb0 unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Cacheb0 value = xbean.Pod.newCacheb0();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Cacheb0 newValue() {
			xbean.Cacheb0 value = xbean.Pod.newCacheb0();
			return value;
		}

	};

	mkdb.TTable<Integer, xbean.Any> any = new mkdb.TTable<Integer, xbean.Any>() {
		@Override
		public String getName() {
			return "any";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Any value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public xbean.Any unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Any value = xbean.Pod.newAny();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Any newValue() {
			xbean.Any value = xbean.Pod.newAny();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.varValue> var_test_m = new mkdb.TTable<Long, xbean.varValue>() {
		@Override
		public String getName() {
			return "var_test_m";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.varValue value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.varValue unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.varValue value = xbean.Pod.newvarValue();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.varValue newValue() {
			xbean.varValue value = xbean.Pod.newvarValue();
			return value;
		}

	};

	mkdb.TTable<Long, Integer> flong = new mkdb.TTable<Long, Integer>() {
		@Override
		public String getName() {
			return "flong";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Long, xbean.TestType> testtype = new mkdb.TTable<Long, xbean.TestType>() {
		@Override
		public String getName() {
			return "testtype";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.TestType value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.TestType unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.TestType value = xbean.Pod.newTestType();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.TestType newValue() {
			xbean.TestType value = xbean.Pod.newTestType();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.First> afirst = new mkdb.TTable<Long, xbean.First>() {
		@Override
		public String getName() {
			return "afirst";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.First value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.First unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.First value = xbean.Pod.newFirst();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.First newValue() {
			xbean.First value = xbean.Pod.newFirst();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.Family> family = new mkdb.TTable<Long, xbean.Family>() {
		@Override
		public String getName() {
			return "family";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.Family value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.Family unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.Family value = xbean.Pod.newFamily();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.Family newValue() {
			xbean.Family value = xbean.Pod.newFamily();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.TestLP> lperform = new mkdb.TTable<Long, xbean.TestLP>() {
		@Override
		public String getName() {
			return "lperform";
		}

		@Override
		protected mkdb.util.AutoKey<Long> bindAutoKey() {
			return getInstance().getTableSys().getAutoKeys().getAutoKeyLong(getName());
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.TestLP value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.TestLP unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.TestLP value = xbean.Pod.newTestLP();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.TestLP newValue() {
			xbean.TestLP value = xbean.Pod.newTestLP();
			return value;
		}

	};

	mkdb.TTable<Long, xbean.First> first = new mkdb.TTable<Long, xbean.First>() {
		@Override
		public String getName() {
			return "first";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(xbean.First value) {
			OctetsStream _os_ = new OctetsStream();
			value.marshal(_os_);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public xbean.First unmarshalValue(OctetsStream _os_) throws MarshalException {
			xbean.First value = xbean.Pod.newFirst();
			value.unmarshal(_os_);
			return value;
		}

		@Override
		public xbean.First newValue() {
			xbean.First value = xbean.Pod.newFirst();
			return value;
		}

	};

	mkdb.TTable<Long, Integer> t2 = new mkdb.TTable<Long, Integer>() {
		@Override
		public String getName() {
			return "t2";
		}

		@Override
		public OctetsStream marshalKey(Long key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Integer value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Long unmarshalKey(OctetsStream _os_) throws MarshalException {
			long key = 0;
			key = _os_.unmarshal_long();
			return key;
		}

		@Override
		public Integer unmarshalValue(OctetsStream _os_) throws MarshalException {
			int value = 0;
			value = _os_.unmarshal_int();
			return value;
		}

		@Override
		public Integer newValue() {
			int value = 0;
			return value;
		}

	};

	mkdb.TTable<Integer, String> t3 = new mkdb.TTable<Integer, String>() {
		@Override
		public String getName() {
			return "t3";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(String value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value, mkdb.Const.IO_CHARSET);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public String unmarshalValue(OctetsStream _os_) throws MarshalException {
			String value = "";
			value = _os_.unmarshal_String(mkdb.Const.IO_CHARSET);
			return value;
		}

		@Override
		public String newValue() {
			String value = "";
			return value;
		}

	};

	mkdb.TTable<Integer, Short> tshort = new mkdb.TTable<Integer, Short>() {
		@Override
		public String getName() {
			return "tshort";
		}

		@Override
		public OctetsStream marshalKey(Integer key) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(key);
			return _os_;
		}

		@Override
		public OctetsStream marshalValue(Short value) {
			OctetsStream _os_ = new OctetsStream();
			_os_.marshal(value);
			return _os_;
		}

		@Override
		public Integer unmarshalKey(OctetsStream _os_) throws MarshalException {
			int key = 0;
			key = _os_.unmarshal_int();
			return key;
		}

		@Override
		public Short unmarshalValue(OctetsStream _os_) throws MarshalException {
			short value = 0;
			value = _os_.unmarshal_short();
			return value;
		}

		@Override
		public Short newValue() {
			short value = 0;
			return value;
		}

	};


}
