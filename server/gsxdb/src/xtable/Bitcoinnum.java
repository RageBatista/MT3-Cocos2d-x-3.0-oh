package xtable;

// 类型化表访问入口
public class Bitcoinnum {
	Bitcoinnum() {
	}

	public static xbean.BitcoinNums get(Integer key) {
		return _Tables_.getInstance().bitcoinnum.get(key);
	}

	public static xbean.BitcoinNums get(Integer key, xbean.BitcoinNums value) {
		return _Tables_.getInstance().bitcoinnum.get(key, value);
	}

	public static void insert(Integer key, xbean.BitcoinNums value) {
		_Tables_.getInstance().bitcoinnum.insert(key, value);
	}

	public static void delete(Integer key) {
		_Tables_.getInstance().bitcoinnum.delete(key);
	}

	public static boolean add(Integer key, xbean.BitcoinNums value) {
		return _Tables_.getInstance().bitcoinnum.add(key, value);
	}

	public static boolean remove(Integer key) {
		return _Tables_.getInstance().bitcoinnum.remove(key);
	}

	public static mkdb.TTableCache<Integer, xbean.BitcoinNums> getCache() {
		return _Tables_.getInstance().bitcoinnum.getCache();
	}

	public static mkdb.TTable<Integer, xbean.BitcoinNums> getTable() {
		return _Tables_.getInstance().bitcoinnum;
	}

	public static xbean.BitcoinNums select(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.BitcoinNums, xbean.BitcoinNums>() {
			public xbean.BitcoinNums get(xbean.BitcoinNums v) { return v.toData(); }
		});
	}

	public static java.util.Map<Long, xbean.BitcoinNum> selectRolebitcoin(Integer key) {
		return getTable().select(key, new mkdb.TField<xbean.BitcoinNums, java.util.Map<Long, xbean.BitcoinNum>>() {
				public java.util.Map<Long, xbean.BitcoinNum> get(xbean.BitcoinNums v) { return v.getRolebitcoinAsData(); }
			});
	}

}
