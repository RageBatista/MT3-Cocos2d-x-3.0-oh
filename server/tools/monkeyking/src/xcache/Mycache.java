package xcache;

// 用户指定的cache名字作为最外层类的名字。cache的访问入口。
public class Mycache {
	////////////////////////////////////////////////////////////////
	// define cached valuetype
	public static class Valuetype {
		// define valuetype
		private volatile First first;
		private volatile Integer t2;
		private volatile Family family;
		private volatile Cachetest cachetest;

		public First getFirst() {
			return first;
		}

		public Integer getT2() {
			return t2;
		}

		public Family getFamily() {
			return family;
		}

		public Cachetest getCachetest() {
			return cachetest;
		}


		// declare valuetype
		public static class First {
			First() {
			}

			private volatile int i;
			private volatile long l;
			private volatile java.util.Set<String> sets;
			private volatile byte [] marshal;

			public int getI() {
				return i;
			}

			public long getL() {
				return l;
			}

			public java.util.Set<String> getSets() {
				return sets;
			}

			public byte [] getMarshal() {
				return marshal;
			}

		}

		public static class Family {
			private volatile int id;
			private volatile int level;
			private volatile int contribution;
			private volatile int leaderid;
			private volatile int creatorid;
			private volatile String name;
			private volatile String aim;
			private volatile String pub;
			private volatile java.util.Map<Integer, xbean.MemberInfo> memebers;
			private volatile int status;
			private volatile long create_time;
			private volatile int well_known;

			Family() {
			}

			public int getId() {
				return id;
			}

			public int getLevel() {
				return level;
			}

			public int getContribution() {
				return contribution;
			}

			public int getLeaderid() {
				return leaderid;
			}

			public int getCreatorid() {
				return creatorid;
			}

			public String getName() {
				return name;
			}

			public String getAim() {
				return aim;
			}

			public String getPub() {
				return pub;
			}

			public java.util.Map<Integer, xbean.MemberInfo> getMemebers() {
				return memebers;
			}

			public int getStatus() {
				return status;
			}

			public long getCreate_time() {
				return create_time;
			}

			public int getWell_known() {
				return well_known;
			}

		}

		public static class Cachetest {
			Cachetest() {
			}

			private volatile int i;
			private Rb rb = new Rb();

			public static class Rb {
				Rb() {
				}

				private volatile int i;

				public int getI() {
					return i;
				}

			}

			public int getI() {
				return i;
			}

			public Rb getRb() {
				return rb;
			}

		}

	}

	///////////////////////////////////////////////////////////////
	// cache define
	// 外层公开的接口，得到的是Cache类型是基类的。基类只公开get和existInCache(不是必要的)。
	public static mkdb.util.ConcurrentCache<Long, Valuetype> getCache() {
		return CacheImpl.instance;
	}

	public static Valuetype get(Long key) {
		return CacheImpl.instance.get(key);
	}

	public static class CacheImpl extends mkdb.util.ConcurrentCache<Long, Valuetype> {
		CacheImpl() {
			super("mycache");
		}

		// 暂时先不公开。需要的时候在基类添加接口并调整这里代码。
		// @Override
		mkdb.Lockey[] realGetLocks(Long key) {
			return new mkdb.Lockey[]{
					mkdb.Lockeys.get(xtable.First.getTable(), key),
					mkdb.Lockeys.get(xtable.T2.getTable(), key),
					mkdb.Lockeys.get(xtable.Family.getTable(), key),
					mkdb.Lockeys.get(xtable.Cachetest.getTable(), key),
			};
		}

		private static class RealGet extends mkdb.Procedure {
			private mkdb.Lockey[] locks;
			private Long key;
			private Valuetype value = new Valuetype();
			
			@Override
			protected boolean process() throws Exception {
				// 先把记录锁排序并锁上，减少死锁可能。
				mkdb.Lockeys.lock(locks);

				value.first = deepcopy(xtable.First.get(key));
				value.t2 = (xtable.T2.get(key));
				value.family = deepcopy(xtable.Family.get(key));
				value.cachetest = deepcopy(xtable.Cachetest.get(key));
				return true;
			}

			Valuetype get(mkdb.Lockey[] locks, Long key) {
				this.locks = locks;
				this.key = key;
				if (false == this.call())
					throw new RuntimeException("readGet fail.", this.getException());
				return this.value;
			}
		}

		@Override
		protected Valuetype realGet(Long key) {
			return new RealGet().get(realGetLocks(key), key);
		}

		static CacheImpl instance = new CacheImpl();
	}

	////////////////////////////////////////////////////////////////////////////////
	// deepcopy helper
	public static java.util.Map<Integer, xbean.MemberInfo> deepcopy(java.util.Map<Integer, xbean.MemberInfo> _o_) {
		java.util.Map<Integer, xbean.MemberInfo> _r_ = new java.util.HashMap<Integer, xbean.MemberInfo>();
		for (java.util.Map.Entry<Integer, xbean.MemberInfo> _e_ : _o_.entrySet())
			_r_.put(_e_.getKey(), _e_.getValue().toDataIf());
		return _r_;
	}

	public static java.util.Set<String> deepcopy(java.util.Set<String> _o_) {
		java.util.Set<String> _r_ = new java.util.HashSet<String>();
		_r_.addAll(_o_);
		return _r_;
	}

	public static Valuetype.First deepcopy(xbean.First b) {
		if (null == b) return null;

		Valuetype.First r = new Valuetype.First();
		r.i = b.getI();
		r.l = b.getL();
		r.sets = deepcopy(b.getSets());
		r.marshal = b.getMarshalCopy();
		return r;
	}

	public static Valuetype.Family deepcopy(xbean.Family b) {
		if (null == b) return null;

		Valuetype.Family r = new Valuetype.Family();
		r.id = b.getId();
		r.level = b.getLevel();
		r.contribution = b.getContribution();
		r.leaderid = b.getLeaderid();
		r.creatorid = b.getCreatorid();
		r.name = b.getName();
		r.aim = b.getAim();
		r.pub = b.getPub();
		r.memebers = deepcopy(b.getMemebers());
		r.status = b.getStatus();
		r.create_time = b.getCreate_time();
		r.well_known = b.getWell_known();
		return r;
	}

	public static Valuetype.Cachetest deepcopy(xbean.RBTest b) {
		if (null == b) return null;

		Valuetype.Cachetest r = new Valuetype.Cachetest();
		r.i = b.getI();
		r.rb.i = b.getRb().getI();
		return r;
	}

	/////////////////////////////////////////////////////////////////////////////////
	// Listener
	static void registryTableListener() {
		xtable.Cachetest.getTable().addListener(_Cachetest_i_Listener.instance, "value", "i");
		xtable.Cachetest.getTable().addListener(_Cachetest_rb_Listener.instance, "value", "rb");
		xtable.Family.getTable().addListener(_Family_Listener.instance, "value");
		xtable.First.getTable().addListener(_First_i_Listener.instance, "value", "i");
		xtable.First.getTable().addListener(_First_l_Listener.instance, "value", "l");
		xtable.First.getTable().addListener(_First_marshal_Listener.instance, "value", "marshal");
		xtable.First.getTable().addListener(_First_sets_Listener.instance, "value", "sets");
		xtable.T2.getTable().addListener(_T2_Listener.instance, "value");
	}

	static void unregistryTableListener() {
		xtable.Cachetest.getTable().removeListener(_Cachetest_i_Listener.instance, "value", "i");
		xtable.Cachetest.getTable().removeListener(_Cachetest_rb_Listener.instance, "value", "rb");
		xtable.Family.getTable().removeListener(_Family_Listener.instance, "value");
		xtable.First.getTable().removeListener(_First_i_Listener.instance, "value", "i");
		xtable.First.getTable().removeListener(_First_l_Listener.instance, "value", "l");
		xtable.First.getTable().removeListener(_First_marshal_Listener.instance, "value", "marshal");
		xtable.First.getTable().removeListener(_First_sets_Listener.instance, "value", "sets");
		xtable.T2.getTable().removeListener(_T2_Listener.instance, "value");
	}

	static class _Cachetest_i_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.RBTest value = xtable.Cachetest.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.cachetest  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.RBTest value = xtable.Cachetest.get(key);
			cv.cachetest.i = value.getI();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.cachetest = null;
		}

		static _Cachetest_i_Listener instance = new _Cachetest_i_Listener();
	}

	static class _Cachetest_rb_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.RBTest value = xtable.Cachetest.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.cachetest  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.RBTest value = xtable.Cachetest.get(key);
			cv.cachetest.rb.i = value.getRb().getI();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.cachetest = null;
		}

		static _Cachetest_rb_Listener instance = new _Cachetest_rb_Listener();
	}

	static class _Family_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Family value = xtable.Family.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.family  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.Family value = xtable.Family.get(key);
			cv.family  = deepcopy(value);
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.family = null;
		}

		static _Family_Listener instance = new _Family_Listener();
	}

	static class _First_i_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.first  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			cv.first.i = value.getI();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.first = null;
		}

		static _First_i_Listener instance = new _First_i_Listener();
	}

	static class _First_l_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.first  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			cv.first.l = value.getL();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.first = null;
		}

		static _First_l_Listener instance = new _First_l_Listener();
	}

	static class _First_marshal_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.first  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			cv.first.marshal = value.getMarshalCopy();
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.first = null;
		}

		static _First_marshal_Listener instance = new _First_marshal_Listener();
	}

	static class _First_sets_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.first  = deepcopy(value);
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final xbean.First value = xtable.First.get(key);
			cv.first.sets = deepcopy(value.getSets());
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.first = null;
		}

		static _First_sets_Listener instance = new _First_sets_Listener();
	}

	static class _T2_Listener implements mkdb.logs.Listener {
		@Override
		public void onChanged(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final Integer value = xtable.T2.get(key);
			// 增加或者覆盖记录，更新所有提取的数据
			cv.t2  = value;
		}

		@Override
		public void onChanged(Object _key, String fullVarName, mkdb.logs.Note note) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			final Integer value = xtable.T2.get(key);
			cv.t2  = value;
		}

		@Override
		public void onRemoved(Object _key) {
			final Long key = (Long)_key;
			final Valuetype cv = CacheImpl.instance.get(key);
			if (null == cv)
				return;
			cv.t2 = null;
		}

		static _T2_Listener instance = new _T2_Listener();
	}

}
