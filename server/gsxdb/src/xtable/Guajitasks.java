package xtable;

// 类型化表访问入口
public class Guajitasks {
	Guajitasks() {
	}

	public static xbean.GuajiTaskState get(Long key) {
		return _Tables_.getInstance().guajitasks.get(key);
	}

	public static xbean.GuajiTaskState get(Long key, xbean.GuajiTaskState value) {
		return _Tables_.getInstance().guajitasks.get(key, value);
	}

	public static void insert(Long key, xbean.GuajiTaskState value) {
		_Tables_.getInstance().guajitasks.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().guajitasks.delete(key);
	}

	public static boolean add(Long key, xbean.GuajiTaskState value) {
		return _Tables_.getInstance().guajitasks.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().guajitasks.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.GuajiTaskState> getCache() {
		return _Tables_.getInstance().guajitasks.getCache();
	}

	public static mkdb.TTable<Long, xbean.GuajiTaskState> getTable() {
		return _Tables_.getInstance().guajitasks;
	}

	public static xbean.GuajiTaskState select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, xbean.GuajiTaskState>() {
			public xbean.GuajiTaskState get(xbean.GuajiTaskState v) { return v.toData(); }
		});
	}

	public static java.util.List<Integer> selectGuajitypeids(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, java.util.List<Integer>>() {
				public java.util.List<Integer> get(xbean.GuajiTaskState v) { return v.getGuajitypeidsAsData(); }
			});
	}

	public static Integer selectInitialmapid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, Integer>() {
				public Integer get(xbean.GuajiTaskState v) { return v.getInitialmapid(); }
			});
	}

	public static Integer selectGuajitypeindex(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, Integer>() {
				public Integer get(xbean.GuajiTaskState v) { return v.getGuajitypeindex(); }
			});
	}

	public static Integer selectMapidindex(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, Integer>() {
				public Integer get(xbean.GuajiTaskState v) { return v.getMapidindex(); }
			});
	}

	public static Long selectLastruntimestamp(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, Long>() {
				public Long get(xbean.GuajiTaskState v) { return v.getLastruntimestamp(); }
			});
	}

	public static Long selectStarttime(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, Long>() {
				public Long get(xbean.GuajiTaskState v) { return v.getStarttime(); }
			});
	}

	public static String selectSource(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, String>() {
				public String get(xbean.GuajiTaskState v) { return v.getSource(); }
			});
	}

	public static Integer selectStatus(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.GuajiTaskState, Integer>() {
				public Integer get(xbean.GuajiTaskState v) { return v.getStatus(); }
			});
	}

}
