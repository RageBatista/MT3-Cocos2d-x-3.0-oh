package xtable;

// typed table access point
public class Table_string {
	Table_string() {
	}

	public static String get(Integer key) {
		return _Tables_.getInstance().table_string.get(key);
	}

	public static String get(Integer key, String value) {
		return _Tables_.getInstance().table_string.get(key, value);
	}

	public static void insert(Integer key, String value) {
		_Tables_.getInstance().table_string.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().table_string.delete(key);
	}

	public static boolean add(Integer key, String value) {
		return _Tables_.getInstance().table_string.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().table_string.remove(key);
	}

	public static mkdb.TTableCache<Integer, String> getCache() {
		return _Tables_.getInstance().table_string.getCache();
	}

	public static mkdb.TTable<Integer, String> getTable() {
		return _Tables_.getInstance().table_string;
	}

	public static String select(Integer key) {
		return getTable().select(key, new mkdb.TField<String, String>() {
			public String get(String v) { return v; }
		});
	}

}
