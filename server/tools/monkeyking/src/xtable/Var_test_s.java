package xtable;

// typed table access point
public class Var_test_s {
	Var_test_s() {
	}

	public static xbean.varValue get(String key) {
		return _Tables_.getInstance().var_test_s.get(key);
	}

	public static xbean.varValue get(String key, xbean.varValue value) {
		return _Tables_.getInstance().var_test_s.get(key, value);
	}

	public static void insert(String key, xbean.varValue value) {
		_Tables_.getInstance().var_test_s.insert(key, value);
	}

	public static void delete(String key) {
		_Tables_.getInstance().var_test_s.delete(key);
	}

	public static boolean add(String key, xbean.varValue value) {
		return _Tables_.getInstance().var_test_s.add(key, value);
	}

	public static boolean remove(String key) {
		return _Tables_.getInstance().var_test_s.remove(key);
	}

	public static mkdb.TTableCache<String, xbean.varValue> getCache() {
		return _Tables_.getInstance().var_test_s.getCache();
	}

	public static mkdb.TTable<String, xbean.varValue> getTable() {
		return _Tables_.getInstance().var_test_s;
	}

	public static xbean.varValue select(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, xbean.varValue>() {
			public xbean.varValue get(xbean.varValue v) { return v.toData(); }
		});
	}

	public static Integer selectVint(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Integer>() {
				public Integer get(xbean.varValue v) { return v.getVint(); }
			});
	}

	public static String selectVstring(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, String>() {
				public String get(xbean.varValue v) { return v.getVstring(); }
			});
	}

	public static Short selectVshort(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Short>() {
				public Short get(xbean.varValue v) { return v.getVshort(); }
			});
	}

	public static Boolean selectVbool(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Boolean>() {
				public Boolean get(xbean.varValue v) { return v.getVbool(); }
			});
	}

	public static Long selectVlong(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Long>() {
				public Long get(xbean.varValue v) { return v.getVlong(); }
			});
	}

	public static byte [] selectVbinary(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, byte []>() {
				public byte [] get(xbean.varValue v) { return v.getVbinaryCopy(); }
			});
	}

	public static xbean.xxx selectVxxx(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, xbean.xxx>() {
				public xbean.xxx get(xbean.varValue v) { return v.getVxxx(); }
			});
	}

	public static xbean.xxx selectVyyy(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, xbean.xxx>() {
				public xbean.xxx get(xbean.varValue v) { return v.getVyyy(); }
			});
	}

	public static java.util.Map<Integer, String> selectVmap(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.Map<Integer, String>>() {
				public java.util.Map<Integer, String> get(xbean.varValue v) { return v.getVmapAsData(); }
			});
	}

	public static java.util.Set<xbean.xxx> selectVset(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.Set<xbean.xxx>>() {
				public java.util.Set<xbean.xxx> get(xbean.varValue v) { return v.getVsetAsData(); }
			});
	}

	public static java.util.List<xbean.yyy> selectVlist(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.List<xbean.yyy>>() {
				public java.util.List<xbean.yyy> get(xbean.varValue v) { return v.getVlistAsData(); }
			});
	}

	public static java.util.List<Short> selectVvector(String key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.List<Short>>() {
				public java.util.List<Short> get(xbean.varValue v) { return v.getVvectorAsData(); }
			});
	}

}
