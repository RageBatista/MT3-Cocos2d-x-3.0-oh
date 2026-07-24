package xtable;

// typed table access point
public class Any {
	Any() {
	}

	public static xbean.Any get(Integer key) {
		return _Tables_.getInstance().any.get(key);
	}

	public static xbean.Any get(Integer key, xbean.Any value) {
		return _Tables_.getInstance().any.get(key, value);
	}

	public static void insert(Integer key, xbean.Any value) {
		_Tables_.getInstance().any.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().any.delete(key);
	}

	public static boolean add(Integer key, xbean.Any value) {
		return _Tables_.getInstance().any.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().any.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.Any> getCache() {
		return _Tables_.getInstance().any.getCache();
	}

	public static mkdb.TTable<Integer, xbean.Any> getTable() {
		return _Tables_.getInstance().any;
	}

	public static Boolean selectBool(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.Any, Boolean>() {
				public Boolean get(xbean.Any v) { return v.getBool(); }
			});
	}

}
