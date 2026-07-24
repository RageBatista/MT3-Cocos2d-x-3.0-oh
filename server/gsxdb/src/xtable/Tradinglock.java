package xtable;

// 类型化表访问入口
public class Tradinglock {
	Tradinglock() {
	}

	public static xbean.TradingLock get(Long key) {
		return _Tables_.getInstance().tradinglock.get(key);
	}

	public static xbean.TradingLock get(Long key, xbean.TradingLock value) {
		return _Tables_.getInstance().tradinglock.get(key, value);
	}

	public static void insert(Long key, xbean.TradingLock value) {
		_Tables_.getInstance().tradinglock.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().tradinglock.delete(key);
	}

	public static boolean add(Long key, xbean.TradingLock value) {
		return _Tables_.getInstance().tradinglock.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().tradinglock.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.TradingLock> getCache() {
		return _Tables_.getInstance().tradinglock.getCache();
	}

	public static mkdb.TTable<Long, xbean.TradingLock> getTable() {
		return _Tables_.getInstance().tradinglock;
	}

	public static xbean.TradingLock select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, xbean.TradingLock>() {
			public xbean.TradingLock get(xbean.TradingLock v) { return v.toData(); }
		});
	}

	public static Long selectTradingid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Long>() {
				public Long get(xbean.TradingLock v) { return v.getTradingid(); }
			});
	}

	public static Long selectRoleid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Long>() {
				public Long get(xbean.TradingLock v) { return v.getRoleid(); }
			});
	}

	public static Integer selectItemid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Integer>() {
				public Integer get(xbean.TradingLock v) { return v.getItemid(); }
			});
	}

	public static Integer selectItemkey(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Integer>() {
				public Integer get(xbean.TradingLock v) { return v.getItemkey(); }
			});
	}

	public static Long selectPetid(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Long>() {
				public Long get(xbean.TradingLock v) { return v.getPetid(); }
			});
	}

	public static Long selectLocktime(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Long>() {
				public Long get(xbean.TradingLock v) { return v.getLocktime(); }
			});
	}

	public static Integer selectLocktype(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.TradingLock, Integer>() {
				public Integer get(xbean.TradingLock v) { return v.getLocktype(); }
			});
	}

}
