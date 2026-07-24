package xtable;

// typed table access point
public class Fshort {
	Fshort() {
	}

	public static Integer get(Short key) {
		return _Tables_.getInstance().fshort.get(key);
	}

	public static Integer get(Short key, Integer value) {
		return _Tables_.getInstance().fshort.get(key, value);
	}

	public static void insert(Short key, Integer value) {
		_Tables_.getInstance().fshort.insert(key, value);
	}

	public static void delete(Short key) {
		_Tables_.getInstance().fshort.delete(key);
	}

	public static boolean add(Short key, Integer value) {
		return _Tables_.getInstance().fshort.add(key, value);
	}

	public static boolean remove(Short key) {
		return _Tables_.getInstance().fshort.remove(key);
	}

	public static mkdb.TTableCache<Short, Integer> getCache() {
		return _Tables_.getInstance().fshort.getCache();
	}

	public static mkdb.TTable<Short, Integer> getTable() {
		return _Tables_.getInstance().fshort;
	}

	public static Integer select(Short key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
