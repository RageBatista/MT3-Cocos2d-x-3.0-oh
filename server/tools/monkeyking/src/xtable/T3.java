package xtable;

// typed table access point
public class T3 {
	T3() {
	}

	public static String get(Integer key) {
		return _Tables_.getInstance().t3.get(key);
	}

	public static String get(Integer key, String value) {
		return _Tables_.getInstance().t3.get(key, value);
	}

	public static void insert(Integer key, String value) {
		_Tables_.getInstance().t3.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().t3.delete(key);
	}

	public static boolean add(Integer key, String value) {
		return _Tables_.getInstance().t3.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().t3.remove(key);
	}

	public static mkdb.TTableCache<Integer, String> getCache() {
		return _Tables_.getInstance().t3.getCache();
	}

	public static mkdb.TTable<Integer, String> getTable() {
		return _Tables_.getInstance().t3;
	}

	public static String select(Integer key) {
		return getTable().select(key, new mkdb.TField<String, String>() {
			public String get(String v) { return v; }
		});
	}

}
