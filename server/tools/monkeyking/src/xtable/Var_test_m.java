package xtable;

// typed table access point
public class Var_test_m {
	Var_test_m() {
	}

	public static xbean.varValue get(Long key) {
		return _Tables_.getInstance().var_test_m.get(key);
	}

	public static xbean.varValue get(Long key, xbean.varValue value) {
		return _Tables_.getInstance().var_test_m.get(key, value);
	}

	public static void insert(Long key, xbean.varValue value) {
		_Tables_.getInstance().var_test_m.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().var_test_m.delete(key);
	}

	public static boolean add(Long key, xbean.varValue value) {
		return _Tables_.getInstance().var_test_m.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().var_test_m.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.varValue> getCache() {
		return _Tables_.getInstance().var_test_m.getCache();
	}

	public static mkdb.TTable<Long, xbean.varValue> getTable() {
		return _Tables_.getInstance().var_test_m;
	}

	public static xbean.varValue select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, xbean.varValue>() {
			public xbean.varValue get(xbean.varValue v) { return v.toData(); }
		});
	}

	public static Integer selectVint(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Integer>() {
				public Integer get(xbean.varValue v) { return v.getVint(); }
			});
	}

	public static String selectVstring(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, String>() {
				public String get(xbean.varValue v) { return v.getVstring(); }
			});
	}

	public static Short selectVshort(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Short>() {
				public Short get(xbean.varValue v) { return v.getVshort(); }
			});
	}

	public static Boolean selectVbool(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Boolean>() {
				public Boolean get(xbean.varValue v) { return v.getVbool(); }
			});
	}

	public static Long selectVlong(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, Long>() {
				public Long get(xbean.varValue v) { return v.getVlong(); }
			});
	}

	public static byte [] selectVbinary(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, byte []>() {
				public byte [] get(xbean.varValue v) { return v.getVbinaryCopy(); }
			});
	}

	public static xbean.xxx selectVxxx(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, xbean.xxx>() {
				public xbean.xxx get(xbean.varValue v) { return v.getVxxx(); }
			});
	}

	public static xbean.xxx selectVyyy(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, xbean.xxx>() {
				public xbean.xxx get(xbean.varValue v) { return v.getVyyy(); }
			});
	}

	public static java.util.Map<Integer, String> selectVmap(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.Map<Integer, String>>() {
				public java.util.Map<Integer, String> get(xbean.varValue v) { return v.getVmapAsData(); }
			});
	}

	public static java.util.Set<xbean.xxx> selectVset(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.Set<xbean.xxx>>() {
				public java.util.Set<xbean.xxx> get(xbean.varValue v) { return v.getVsetAsData(); }
			});
	}

	public static java.util.List<xbean.yyy> selectVlist(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.List<xbean.yyy>>() {
				public java.util.List<xbean.yyy> get(xbean.varValue v) { return v.getVlistAsData(); }
			});
	}

	public static java.util.List<Short> selectVvector(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.varValue, java.util.List<Short>>() {
				public java.util.List<Short> get(xbean.varValue v) { return v.getVvectorAsData(); }
			});
	}

}
