package xtable;

// typed table access point
public class Table_map {
	Table_map() {
	}

	public static xbean.varMap get(Integer key) {
		return _Tables_.getInstance().table_map.get(key);
	}

	public static xbean.varMap get(Integer key, xbean.varMap value) {
		return _Tables_.getInstance().table_map.get(key, value);
	}

	public static void insert(Integer key, xbean.varMap value) {
		_Tables_.getInstance().table_map.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().table_map.delete(key);
	}

	public static boolean add(Integer key, xbean.varMap value) {
		return _Tables_.getInstance().table_map.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().table_map.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.varMap> getCache() {
		return _Tables_.getInstance().table_map.getCache();
	}

	public static mkdb.TTable<Integer, xbean.varMap> getTable() {
		return _Tables_.getInstance().table_map;
	}

	public static xbean.varMap select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varMap, xbean.varMap>() {
			public xbean.varMap get(xbean.varMap v) { return v.toData(); }
		});
	}

	public static java.util.Map<Integer, Integer> selectV(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.varMap, java.util.Map<Integer, Integer>>() {
				public java.util.Map<Integer, Integer> get(xbean.varMap v) { return v.getVAsData(); }
			});
	}

}
