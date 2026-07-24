package xtable;

// typed table access point
public class Fboolean {
	Fboolean() {
	}

	public static Integer get(Boolean key) {
		return _Tables_.getInstance().fboolean.get(key);
	}

	public static Integer get(Boolean key, Integer value) {
		return _Tables_.getInstance().fboolean.get(key, value);
	}

	public static void insert(Boolean key, Integer value) {
		_Tables_.getInstance().fboolean.insert(key, value);
	}

	public static void delete(Boolean key) {
		_Tables_.getInstance().fboolean.delete(key);
	}

	public static boolean add(Boolean key, Integer value) {
		return _Tables_.getInstance().fboolean.add(key, value);
	}

	public static boolean remove(Boolean key) {
		return _Tables_.getInstance().fboolean.remove(key);
	}

	public static mkdb.TTableCache<Boolean, Integer> getCache() {
		return _Tables_.getInstance().fboolean.getCache();
	}

	public static mkdb.TTable<Boolean, Integer> getTable() {
		return _Tables_.getInstance().fboolean;
	}

	public static Integer select(Boolean key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
