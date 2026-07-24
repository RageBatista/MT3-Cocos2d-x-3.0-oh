package xtable;

// 类型化表访问入口
public class Totalrecharge {
	Totalrecharge() {
	}

	public static xbean.TotalInfo get(Long key) {
		return _Tables_.getInstance().totalrecharge.get(key);
	}

	public static xbean.TotalInfo get(Long key, xbean.TotalInfo value) {
		return _Tables_.getInstance().totalrecharge.get(key, value);
	}

	public static void insert(Long key, xbean.TotalInfo value) {
		_Tables_.getInstance().totalrecharge.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().totalrecharge.delete(key);
	}

	public static boolean add(Long key, xbean.TotalInfo value) {
		return _Tables_.getInstance().totalrecharge.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().totalrecharge.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.TotalInfo> getCache() {
		return _Tables_.getInstance().totalrecharge.getCache();
	}

	public static mkdb.TTable<Long, xbean.TotalInfo> getTable() {
		return _Tables_.getInstance().totalrecharge;
	}

	public static xbean.TotalInfo select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TotalInfo, xbean.TotalInfo>() {
			public xbean.TotalInfo get(xbean.TotalInfo v) { return v.toData(); }
		});
	}

	public static Long selectTotal(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TotalInfo, Long>() {
				public Long get(xbean.TotalInfo v) { return v.getTotal(); }
			});
	}

	public static java.util.Map<Integer, Long> selectTotalrewardmap(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TotalInfo, java.util.Map<Integer, Long>>() {
				public java.util.Map<Integer, Long> get(xbean.TotalInfo v) { return v.getTotalrewardmapAsData(); }
			});
	}

}
