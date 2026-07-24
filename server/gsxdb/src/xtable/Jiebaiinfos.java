package xtable;

// 类型化表访问入口
public class Jiebaiinfos {
	Jiebaiinfos() {
	}

	public static xbean.jiebaiAskInfo get(Long key) {
		return _Tables_.getInstance().jiebaiinfos.get(key);
	}

	public static xbean.jiebaiAskInfo get(Long key, xbean.jiebaiAskInfo value) {
		return _Tables_.getInstance().jiebaiinfos.get(key, value);
	}

	public static void insert(Long key, xbean.jiebaiAskInfo value) {
		_Tables_.getInstance().jiebaiinfos.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().jiebaiinfos.delete(key);
	}

	public static boolean add(Long key, xbean.jiebaiAskInfo value) {
		return _Tables_.getInstance().jiebaiinfos.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().jiebaiinfos.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.jiebaiAskInfo> getCache() {
		return _Tables_.getInstance().jiebaiinfos.getCache();
	}

	public static mkdb.TTable<Long, xbean.jiebaiAskInfo> getTable() {
		return _Tables_.getInstance().jiebaiinfos;
	}

	public static xbean.jiebaiAskInfo select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.jiebaiAskInfo, xbean.jiebaiAskInfo>() {
			public xbean.jiebaiAskInfo get(xbean.jiebaiAskInfo v) { return v.toData(); }
		});
	}

	public static String selectTitlename(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.jiebaiAskInfo, String>() {
				public String get(xbean.jiebaiAskInfo v) { return v.getTitlename(); }
			});
	}

	public static java.util.Map<Long, String> selectJiebaiinfo(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.jiebaiAskInfo, java.util.Map<Long, String>>() {
				public java.util.Map<Long, String> get(xbean.jiebaiAskInfo v) { return v.getJiebaiinfoAsData(); }
			});
	}

}
