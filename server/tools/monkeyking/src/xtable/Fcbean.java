package xtable;

// typed table access point
public class Fcbean {
	Fcbean() {
	}

	public static Integer get(xbean.fcbean key) {
		return _Tables_.getInstance().fcbean.get(key);
	}

	public static Integer get(xbean.fcbean key, Integer value) {
		return _Tables_.getInstance().fcbean.get(key, value);
	}

	public static void insert(xbean.fcbean key, Integer value) {
		_Tables_.getInstance().fcbean.insert(key, value);
	}

	public static void delete(xbean.fcbean key) {
		_Tables_.getInstance().fcbean.delete(key);
	}

	public static boolean add(xbean.fcbean key, Integer value) {
		return _Tables_.getInstance().fcbean.add(key, value);
	}

	public static boolean remove(xbean.fcbean key) {
		return _Tables_.getInstance().fcbean.remove(key);
	}

	public static mkdb.TTableCache<xbean.fcbean, Integer> getCache() {
		return _Tables_.getInstance().fcbean.getCache();
	}

	public static mkdb.TTable<xbean.fcbean, Integer> getTable() {
		return _Tables_.getInstance().fcbean;
	}

	public static Integer select(xbean.fcbean key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
