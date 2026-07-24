package xtable;

// typed table access point
public class Fstring {
	Fstring() {
	}

	public static Integer get(String key) {
		return _Tables_.getInstance().fstring.get(key);
	}

	public static Integer get(String key, Integer value) {
		return _Tables_.getInstance().fstring.get(key, value);
	}

	public static void insert(String key, Integer value) {
		_Tables_.getInstance().fstring.insert(key, value);
	}

	public static void delete(String key) {
		_Tables_.getInstance().fstring.delete(key);
	}

	public static boolean add(String key, Integer value) {
		return _Tables_.getInstance().fstring.add(key, value);
	}

	public static boolean remove(String key) {
		return _Tables_.getInstance().fstring.remove(key);
	}

	public static mkdb.TTableCache<String, Integer> getCache() {
		return _Tables_.getInstance().fstring.getCache();
	}

	public static mkdb.TTable<String, Integer> getTable() {
		return _Tables_.getInstance().fstring;
	}

	public static Integer select(String key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
