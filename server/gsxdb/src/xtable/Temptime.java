package xtable;

// 类型化表访问入口
public class Temptime {
	Temptime() {
	}

	public static xbean.TempTime get(Long key) {
		return _Tables_.getInstance().temptime.get(key);
	}

	public static xbean.TempTime get(Long key, xbean.TempTime value) {
		return _Tables_.getInstance().temptime.get(key, value);
	}

	public static void insert(Long key, xbean.TempTime value) {
		_Tables_.getInstance().temptime.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().temptime.delete(key);
	}

	public static boolean add(Long key, xbean.TempTime value) {
		return _Tables_.getInstance().temptime.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().temptime.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.TempTime> getCache() {
		return _Tables_.getInstance().temptime.getCache();
	}

	public static mkdb.TTable<Long, xbean.TempTime> getTable() {
		return _Tables_.getInstance().temptime;
	}

	public static xbean.TempTime select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TempTime, xbean.TempTime>() {
			public xbean.TempTime get(xbean.TempTime v) { return v.toData(); }
		});
	}

	public static java.util.Map<Integer, Long> selectItems(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TempTime, java.util.Map<Integer, Long>>() {
				public java.util.Map<Integer, Long> get(xbean.TempTime v) { return v.getItemsAsData(); }
			});
	}

}
