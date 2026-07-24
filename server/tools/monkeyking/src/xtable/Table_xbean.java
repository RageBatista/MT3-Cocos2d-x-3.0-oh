package xtable;

// typed table access point
public class Table_xbean {
	Table_xbean() {
	}

	public static xbean.varXBean get(Integer key) {
		return _Tables_.getInstance().table_xbean.get(key);
	}

	public static xbean.varXBean get(Integer key, xbean.varXBean value) {
		return _Tables_.getInstance().table_xbean.get(key, value);
	}

	public static void insert(Integer key, xbean.varXBean value) {
		_Tables_.getInstance().table_xbean.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().table_xbean.delete(key);
	}

	public static boolean add(Integer key, xbean.varXBean value) {
		return _Tables_.getInstance().table_xbean.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().table_xbean.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.varXBean> getCache() {
		return _Tables_.getInstance().table_xbean.getCache();
	}

	public static mkdb.TTable<Integer, xbean.varXBean> getTable() {
		return _Tables_.getInstance().table_xbean;
	}

	public static xbean.varXBean select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varXBean, xbean.varXBean>() {
			public xbean.varXBean get(xbean.varXBean v) { return v.toData(); }
		});
	}

	public static Integer selectVint(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varXBean, Integer>() {
				public Integer get(xbean.varXBean v) { return v.getVint(); }
			});
	}

	public static String selectVstring(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varXBean, String>() {
				public String get(xbean.varXBean v) { return v.getVstring(); }
			});
	}

	public static java.util.Set<Integer> selectVset(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varXBean, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.varXBean v) { return v.getVsetAsData(); }
			});
	}

	public static java.util.Map<Integer, Integer> selectVmap(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varXBean, java.util.Map<Integer, Integer>>() {
				public java.util.Map<Integer, Integer> get(xbean.varXBean v) { return v.getVmapAsData(); }
			});
	}

}
