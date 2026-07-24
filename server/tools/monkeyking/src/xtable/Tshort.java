package xtable;

// typed table access point
public class Tshort {
	Tshort() {
	}

	public static Short get(Integer key) {
		return _Tables_.getInstance().tshort.get(key);
	}

	public static Short get(Integer key, Short value) {
		return _Tables_.getInstance().tshort.get(key, value);
	}

	public static void insert(Integer key, Short value) {
		_Tables_.getInstance().tshort.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().tshort.delete(key);
	}

	public static boolean add(Integer key, Short value) {
		return _Tables_.getInstance().tshort.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().tshort.remove(key);
	}

	public static mkdb.TTableCache<Integer, Short> getCache() {
		return _Tables_.getInstance().tshort.getCache();
	}

	public static mkdb.TTable<Integer, Short> getTable() {
		return _Tables_.getInstance().tshort;
	}

	public static Short select(Integer key) {
		return getTable().select(key, new mkdb.TField<Short, Short>() {
			public Short get(Short v) { return v; }
		});
	}

}
