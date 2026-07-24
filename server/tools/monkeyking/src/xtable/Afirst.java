package xtable;

// typed table access point
public class Afirst {
	Afirst() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().afirst.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.First value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.First get(Long key) {
		return _Tables_.getInstance().afirst.get(key);
	}

	public static xbean.First get(Long key, xbean.First value) {
		return _Tables_.getInstance().afirst.get(key, value);
	}

	public static void insert(Long key, xbean.First value) {
		_Tables_.getInstance().afirst.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().afirst.delete(key);
	}

	public static boolean add(Long key, xbean.First value) {
		return _Tables_.getInstance().afirst.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().afirst.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.First> getCache() {
		return _Tables_.getInstance().afirst.getCache();
	}

	public static mkdb.TTable<Long, xbean.First> getTable() {
		return _Tables_.getInstance().afirst;
	}

	public static xbean.First select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, xbean.First>() {
			public xbean.First get(xbean.First v) { return v.toData(); }
		});
	}

	public static Short selectS(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, Short>() {
				public Short get(xbean.First v) { return v.getS(); }
			});
	}

	public static Integer selectI(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, Integer>() {
				public Integer get(xbean.First v) { return v.getI(); }
			});
	}

	public static Long selectL(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, Long>() {
				public Long get(xbean.First v) { return v.getL(); }
			});
	}

	public static String selectText(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, String>() {
				public String get(xbean.First v) { return v.getText(); }
			});
	}

	public static byte [] selectMarshal(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, byte []>() {
				public byte [] get(xbean.First v) { return v.getMarshalCopy(); }
			});
	}

	public static java.util.Set<String> selectSets(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, java.util.Set<String>>() {
				public java.util.Set<String> get(xbean.First v) { return v.getSetsAsData(); }
			});
	}

	public static java.util.Set<Integer> selectSeti(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.First v) { return v.getSetiAsData(); }
			});
	}

	public static java.util.Set<Long> selectSetl(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.First, java.util.Set<Long>>() {
				public java.util.Set<Long> get(xbean.First v) { return v.getSetlAsData(); }
			});
	}

}
