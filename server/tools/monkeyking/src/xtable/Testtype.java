package xtable;

// typed table access point
public class Testtype {
	Testtype() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().testtype.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.TestType value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.TestType get(Long key) {
		return _Tables_.getInstance().testtype.get(key);
	}

	public static xbean.TestType get(Long key, xbean.TestType value) {
		return _Tables_.getInstance().testtype.get(key, value);
	}

	public static void insert(Long key, xbean.TestType value) {
		_Tables_.getInstance().testtype.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().testtype.delete(key);
	}

	public static boolean add(Long key, xbean.TestType value) {
		return _Tables_.getInstance().testtype.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().testtype.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.TestType> getCache() {
		return _Tables_.getInstance().testtype.getCache();
	}

	public static mkdb.TTable<Long, xbean.TestType> getTable() {
		return _Tables_.getInstance().testtype;
	}

	public static xbean.TestType select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestType, xbean.TestType>() {
			public xbean.TestType get(xbean.TestType v) { return v.toData(); }
		});
	}

	public static Integer selectId(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestType, Integer>() {
				public Integer get(xbean.TestType v) { return v.getId(); }
			});
	}

	public static java.util.Map<Integer, xbean.Second> selectVmap(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TestType, java.util.Map<Integer, xbean.Second>>() {
				public java.util.Map<Integer, xbean.Second> get(xbean.TestType v) { return v.getVmapAsData(); }
			});
	}

}
