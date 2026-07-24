package xtable;

// 类型化表访问入口
public class Daycounter {
	Daycounter() {
	}

	public static mkdb.util.AutoKey<Long> getAutoKey() {
		return _Tables_.getInstance().daycounter.getAutoKey();
	}

	public static Long nextKey() {
		return getAutoKey().next();
	}

	public static Long insert(xbean.DayCounter value) {
		Long next = nextKey();
		insert(next, value);
		return next;
	}

	public static xbean.DayCounter get(Long key) {
		return _Tables_.getInstance().daycounter.get(key);
	}

	public static xbean.DayCounter get(Long key, xbean.DayCounter value) {
		return _Tables_.getInstance().daycounter.get(key, value);
	}

	public static void insert(Long key, xbean.DayCounter value) {
		_Tables_.getInstance().daycounter.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().daycounter.delete(key);
	}

	public static boolean add(Long key, xbean.DayCounter value) {
		return _Tables_.getInstance().daycounter.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().daycounter.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.DayCounter> getCache() {
		return _Tables_.getInstance().daycounter.getCache();
	}

	public static mkdb.TTable<Long, xbean.DayCounter> getTable() {
		return _Tables_.getInstance().daycounter;
	}

	public static xbean.DayCounter select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.DayCounter, xbean.DayCounter>() {
			public xbean.DayCounter get(xbean.DayCounter v) { return v.toData(); }
		});
	}

	public static java.util.Map<Integer, xbean.DayCount> selectCountermap(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.DayCounter, java.util.Map<Integer, xbean.DayCount>>() {
				public java.util.Map<Integer, xbean.DayCount> get(xbean.DayCounter v) { return v.getCountermapAsData(); }
			});
	}

}
