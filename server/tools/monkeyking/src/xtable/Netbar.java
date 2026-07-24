package xtable;

// typed table access point
public class Netbar {
	Netbar() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().netbar.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.NetBar value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.NetBar get(Long key) {
		return _Tables_.getInstance().netbar.get(key);
	}

	public static xbean.NetBar get(Long key, xbean.NetBar value) {
		return _Tables_.getInstance().netbar.get(key, value);
	}

	public static void insert(Long key, xbean.NetBar value) {
		_Tables_.getInstance().netbar.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().netbar.delete(key);
	}

	public static boolean add(Long key, xbean.NetBar value) {
		return _Tables_.getInstance().netbar.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().netbar.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.NetBar> getCache() {
		return _Tables_.getInstance().netbar.getCache();
	}

	public static mkdb.TTable<Long, xbean.NetBar> getTable() {
		return _Tables_.getInstance().netbar;
	}

	public static xbean.NetBar select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.NetBar, xbean.NetBar>() {
			public xbean.NetBar get(xbean.NetBar v) { return v.toData(); }
		});
	}

	public static Integer selectId(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.NetBar, Integer>() {
				public Integer get(xbean.NetBar v) { return v.getId(); }
			});
	}

	public static String selectBarname(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.NetBar, String>() {
				public String get(xbean.NetBar v) { return v.getBarname(); }
			});
	}

	public static Integer selectLevel(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.NetBar, Integer>() {
				public Integer get(xbean.NetBar v) { return v.getLevel(); }
			});
	}

}
