package xtable;

// typed table access point
public class F1 {
	F1() {
	}

	public static xbean.fcbean get(Integer key) {
		return _Tables_.getInstance().f1.get(key);
	}

	public static xbean.fcbean get(Integer key, xbean.fcbean value) {
		return _Tables_.getInstance().f1.get(key, value);
	}

	public static void insert(Integer key, xbean.fcbean value) {
		_Tables_.getInstance().f1.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().f1.delete(key);
	}

	public static boolean add(Integer key, xbean.fcbean value) {
		return _Tables_.getInstance().f1.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().f1.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.fcbean> getCache() {
		return _Tables_.getInstance().f1.getCache();
	}

	public static mkdb.TTable<Integer, xbean.fcbean> getTable() {
		return _Tables_.getInstance().f1;
	}

	public static xbean.fcbean select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.fcbean, xbean.fcbean>() {
			public xbean.fcbean get(xbean.fcbean v) { return v; }
		});
	}

}
