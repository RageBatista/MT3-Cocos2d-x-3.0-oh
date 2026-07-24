package xtable;

// typed table access point
public class Table_int {
	Table_int() {
	}

	public static Integer get(Integer key) {
		return _Tables_.getInstance().table_int.get(key);
	}

	public static Integer get(Integer key, Integer value) {
		return _Tables_.getInstance().table_int.get(key, value);
	}

	public static void insert(Integer key, Integer value) {
		_Tables_.getInstance().table_int.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().table_int.delete(key);
	}

	public static boolean add(Integer key, Integer value) {
		return _Tables_.getInstance().table_int.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().table_int.remove(key);
	}

	public static mkdb.TTableCache<Integer, Integer> getCache() {
		return _Tables_.getInstance().table_int.getCache();
	}

	public static mkdb.TTable<Integer, Integer> getTable() {
		return _Tables_.getInstance().table_int;
	}

	public static Integer select(Integer key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
