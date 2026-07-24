package xtable;

// typed table access point
public class Table_set {
	Table_set() {
	}

	public static xbean.varSet get(Integer key) {
		return _Tables_.getInstance().table_set.get(key);
	}

	public static xbean.varSet get(Integer key, xbean.varSet value) {
		return _Tables_.getInstance().table_set.get(key, value);
	}

	public static void insert(Integer key, xbean.varSet value) {
		_Tables_.getInstance().table_set.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().table_set.delete(key);
	}

	public static boolean add(Integer key, xbean.varSet value) {
		return _Tables_.getInstance().table_set.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().table_set.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.varSet> getCache() {
		return _Tables_.getInstance().table_set.getCache();
	}

	public static mkdb.TTable<Integer, xbean.varSet> getTable() {
		return _Tables_.getInstance().table_set;
	}

	public static xbean.varSet select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varSet, xbean.varSet>() {
			public xbean.varSet get(xbean.varSet v) { return v.toData(); }
		});
	}

	public static java.util.Set<Integer> selectV(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varSet, java.util.Set<Integer>>() {
				public java.util.Set<Integer> get(xbean.varSet v) { return v.getVAsData(); }
			});
	}

}
