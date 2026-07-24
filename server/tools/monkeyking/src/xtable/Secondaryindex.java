package xtable;

// typed table access point
public class Secondaryindex {
	Secondaryindex() {
	}

	public static xbean.SecondaryIndex get(Long key) {
		return _Tables_.getInstance().secondaryindex.get(key);
	}

	public static xbean.SecondaryIndex get(Long key, xbean.SecondaryIndex value) {
		return _Tables_.getInstance().secondaryindex.get(key, value);
	}

	public static void insert(Long key, xbean.SecondaryIndex value) {
		_Tables_.getInstance().secondaryindex.insert(key, value);
	}

	public static void delete(Long key) {
		_Tables_.getInstance().secondaryindex.delete(key);
	}

	public static boolean add(Long key, xbean.SecondaryIndex value) {
		return _Tables_.getInstance().secondaryindex.add(key, value);
	}

	public static boolean remove(Long key) {
		return _Tables_.getInstance().secondaryindex.remove(key);
	}

	public static mkdb.TTableCache<Long, xbean.SecondaryIndex> getCache() {
		return _Tables_.getInstance().secondaryindex.getCache();
	}

	public static mkdb.TTable<Long, xbean.SecondaryIndex> getTable() {
		return _Tables_.getInstance().secondaryindex;
	}

	public static xbean.SecondaryIndex select(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.SecondaryIndex, xbean.SecondaryIndex>() {
			public xbean.SecondaryIndex get(xbean.SecondaryIndex v) { return v.toData(); }
		});
	}

	public static Integer selectSecondaryindex(Long key) {
		return getTable().select(key, new mkdb.TField<xbean.SecondaryIndex, Integer>() {
				public Integer get(xbean.SecondaryIndex v) { return v.getSecondaryindex(); }
			});
	}

}
