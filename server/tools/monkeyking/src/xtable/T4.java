package xtable;

// typed table access point
public class T4 {
	T4() {
	}

	public static xbean.First get(String key) {
		return _Tables_.getInstance().t4.get(key);
	}

	public static xbean.First get(String key, xbean.First value) {
		return _Tables_.getInstance().t4.get(key, value);
	}

	public static void insert(String key, xbean.First value) {
		_Tables_.getInstance().t4.insert(key, value);
	}

	public static void delete(String key) {
		_Tables_.getInstance().t4.delete(key);
	}

	public static boolean add(String key, xbean.First value) {
		return _Tables_.getInstance().t4.add(key, value);
	}

	public static boolean remove(String key) {
		return _Tables_.getInstance().t4.remove(key);
	}

	public static mkdb.TTableCache<String, xbean.First> getCache() {
		return _Tables_.getInstance().t4.getCache();
	}

	public static mkdb.TTable<String, xbean.First> getTable() {
		return _Tables_.getInstance().t4;
	}

	public static xbean.First select(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, xbean.First>() {
			public xbean.First get(xbean.First v) { return v.toData(); }
		});
	}

	public static Short selectS(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, Short>() {
				public Short get(xbean.First v) { return v.getS(); }
			});
	}

	public static Integer selectI(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, Integer>() {
				public Integer get(xbean.First v) { return v.getI(); }
			});
	}

	public static Long selectL(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, Long>() {
				public Long get(xbean.First v) { return v.getL(); }
			});
	}

	public static String selectText(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, String>() {
				public String get(xbean.First v) { return v.getText(); }
			});
	}

	public static byte [] selectMarshal(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, byte []>() {
				public byte [] get(xbean.First v) { return v.getMarshalCopy(); }
			});
	}

	public static java.util.Set<String> selectSets(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, java.util.Set<String>>() {
				public java.util.Set<String> get(xbean.First v) { return v.getSetsAsData(); }
			});
	}

	public static java.util.Set<Integer> selectSeti(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.First v) { return v.getSetiAsData(); }
			});
	}

	public static java.util.Set<Long> selectSetl(String key) {
		return getTable().select(key, new mkdb.TField<xbean.First, java.util.Set<Long>>() {
				public java.util.Set<Long> get(xbean.First v) { return v.getSetlAsData(); }
			});
	}

}
