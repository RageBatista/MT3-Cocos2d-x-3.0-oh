package xtable;

// typed table access point
public class Fint {
	Fint() {
	}

	public static Integer get(Integer key) {
		return _Tables_.getInstance().fint.get(key);
	}

	public static Integer get(Integer key, Integer value) {
		return _Tables_.getInstance().fint.get(key, value);
	}

	public static void insert(Integer key, Integer value) {
		_Tables_.getInstance().fint.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().fint.delete(key);
	}

	public static boolean add(Integer key, Integer value) {
		return _Tables_.getInstance().fint.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().fint.remove(key);
	}

	public static mkdb.TTableCache<Integer, Integer> getCache() {
		return _Tables_.getInstance().fint.getCache();
	}

	public static mkdb.TTable<Integer, Integer> getTable() {
		return _Tables_.getInstance().fint;
	}

	public static Integer select(Integer key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
