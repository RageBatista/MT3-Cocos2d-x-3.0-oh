package xtable;

// typed table access point
public class At2 {
	At2() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().at2.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(Integer value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static Integer get(Long key) {
		return _Tables_.getInstance().at2.get(key);
	}

	public static Integer get(Long key, Integer value) {
		return _Tables_.getInstance().at2.get(key, value);
	}

	public static void insert(Long key, Integer value) {
		_Tables_.getInstance().at2.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().at2.delete(key);
	}

	public static boolean add(Long key, Integer value) {
		return _Tables_.getInstance().at2.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().at2.remove(key);
	}

	public static mkdb.TTableCache<Long, Integer> getCache() {
		return _Tables_.getInstance().at2.getCache();
	}

	public static mkdb.TTable<Long, Integer> getTable() {
		return _Tables_.getInstance().at2;
	}

	public static Integer select(Long key) {
		return getTable().select(key, new mkdb.TField<Integer, Integer>() {
			public Integer get(Integer v) { return v; }
		});
	}

}
