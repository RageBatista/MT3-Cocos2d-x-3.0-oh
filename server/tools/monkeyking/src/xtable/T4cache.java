package xtable;

// typed table access point
public class T4cache {
	T4cache() {
	}

	public static xbean.Cacheb0 get(Long key) {
		return _Tables_.getInstance().t4cache.get(key);
	}

	public static xbean.Cacheb0 get(Long key, xbean.Cacheb0 value) {
		return _Tables_.getInstance().t4cache.get(key, value);
	}

	public static void insert(Long key, xbean.Cacheb0 value) {
		_Tables_.getInstance().t4cache.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().t4cache.delete(key);
	}

	public static boolean add(Long key, xbean.Cacheb0 value) {
		return _Tables_.getInstance().t4cache.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().t4cache.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.Cacheb0> getCache() {
		return _Tables_.getInstance().t4cache.getCache();
	}

	public static mkdb.TTable<Long, xbean.Cacheb0> getTable() {
		return _Tables_.getInstance().t4cache;
	}

	public static xbean.Cacheb0 select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Cacheb0, xbean.Cacheb0>() {
			public xbean.Cacheb0 get(xbean.Cacheb0 v) { return v.toData(); }
		});
	}

	public static Integer selectI(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Cacheb0, Integer>() {
				public Integer get(xbean.Cacheb0 v) { return v.getI(); }
			});
	}

	public static Long selectL(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Cacheb0, Long>() {
				public Long get(xbean.Cacheb0 v) { return v.getL(); }
			});
	}

	public static byte [] selectMarshal(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Cacheb0, byte []>() {
				public byte [] get(xbean.Cacheb0 v) { return v.getMarshalCopy(); }
			});
	}

	public static java.util.Set<Integer> selectSeti(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Cacheb0, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.Cacheb0 v) { return v.getSetiAsData(); }
			});
	}

	public static xbean.Cacheb1 selectCacheb1(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.Cacheb0, xbean.Cacheb1>() {
				public xbean.Cacheb1 get(xbean.Cacheb0 v) { return v.getCacheb1(); }
			});
	}

}
