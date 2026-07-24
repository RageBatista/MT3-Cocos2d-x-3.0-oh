package xtable;

// typed table access point
public class Tlong {
	Tlong() {
	}

	public static Long get(Integer key) {
		return _Tables_.getInstance().tlong.get(key);
	}

	public static Long get(Integer key, Long value) {
		return _Tables_.getInstance().tlong.get(key, value);
	}

	public static void insert(Integer key, Long value) {
		_Tables_.getInstance().tlong.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().tlong.delete(key);
	}

	public static boolean add(Integer key, Long value) {
		return _Tables_.getInstance().tlong.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().tlong.remove(key);
	}

	public static mkdb.TTableCache<Integer, Long> getCache() {
		return _Tables_.getInstance().tlong.getCache();
	}

	public static mkdb.TTable<Integer, Long> getTable() {
		return _Tables_.getInstance().tlong;
	}

	public static Long select(Integer key) {
		return getTable().select(key, new mkdb.TField<Long, Long>() {
			public Long get(Long v) { return v; }
		});
	}

}
