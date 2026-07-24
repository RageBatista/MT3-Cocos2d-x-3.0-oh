package xtable;

// 类型化表访问入口
public class Dailyrecharge {
	Dailyrecharge() {
	}

	public static xbean.DailyInfo get(Long key) {
		return _Tables_.getInstance().dailyrecharge.get(key);
	}

	public static xbean.DailyInfo get(Long key, xbean.DailyInfo value) {
		return _Tables_.getInstance().dailyrecharge.get(key, value);
	}

	public static void insert(Long key, xbean.DailyInfo value) {
		_Tables_.getInstance().dailyrecharge.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().dailyrecharge.delete(key);
	}

	public static boolean add(Long key, xbean.DailyInfo value) {
		return _Tables_.getInstance().dailyrecharge.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().dailyrecharge.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.DailyInfo> getCache() {
		return _Tables_.getInstance().dailyrecharge.getCache();
	}

	public static mkdb.TTable<Long, xbean.DailyInfo> getTable() {
		return _Tables_.getInstance().dailyrecharge;
	}

	public static xbean.DailyInfo select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.DailyInfo, xbean.DailyInfo>() {
			public xbean.DailyInfo get(xbean.DailyInfo v) { return v.toData(); }
		});
	}

	public static Long selectPaynum(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.DailyInfo, Long>() {
				public Long get(xbean.DailyInfo v) { return v.getPaynum(); }
			});
	}

	public static Long selectTime(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.DailyInfo, Long>() {
				public Long get(xbean.DailyInfo v) { return v.getTime(); }
			});
	}

	public static java.util.Map<Integer, Long> selectDayrewardmap(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.DailyInfo, java.util.Map<Integer, Long>>() {
				public java.util.Map<Integer, Long> get(xbean.DailyInfo v) { return v.getDayrewardmapAsData(); }
			});
	}

}
