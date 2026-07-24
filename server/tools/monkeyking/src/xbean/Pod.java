
package xbean;

/**
 * bean factory
 */
public final class Pod {
	public static mkdb.util.BeanPool<ListListenerTestEffect> poolListListenerTestEffect = new mkdb.util.BeanPool<ListListenerTestEffect>() {
		@Override
		protected ListListenerTestEffect newBean() {
			return new xbean.__.ListListenerTestEffect();
		}
	};

	public static ListListenerTestEffect newListListenerTestEffect() {
		return poolListListenerTestEffect.get();
	}

	public static void _reset_unsafe_add_(ListListenerTestEffect bean) {
		poolListListenerTestEffect._reset_unsafe_add_(bean);
	}

	public static void padd(ListListenerTestEffect bean) {
		mkdb.Procedure.padd(bean, poolListListenerTestEffect);
	}

	public static ListListenerTestEffect newListListenerTestEffectData() {
		return new xbean.__.ListListenerTestEffect.Data();
	}

	public static mkdb.util.BeanPool<ListListenerTestEffects> poolListListenerTestEffects = new mkdb.util.BeanPool<ListListenerTestEffects>() {
		@Override
		protected ListListenerTestEffects newBean() {
			return new xbean.__.ListListenerTestEffects();
		}
	};

	public static ListListenerTestEffects newListListenerTestEffects() {
		return poolListListenerTestEffects.get();
	}

	public static void _reset_unsafe_add_(ListListenerTestEffects bean) {
		poolListListenerTestEffects._reset_unsafe_add_(bean);
	}

	public static void padd(ListListenerTestEffects bean) {
		mkdb.Procedure.padd(bean, poolListListenerTestEffects);
	}

	public static ListListenerTestEffects newListListenerTestEffectsData() {
		return new xbean.__.ListListenerTestEffects.Data();
	}

	public static mkdb.util.BeanPool<Cacheb0> poolCacheb0 = new mkdb.util.BeanPool<Cacheb0>() {
		@Override
		protected Cacheb0 newBean() {
			return new xbean.__.Cacheb0();
		}
	};

	public static Cacheb0 newCacheb0() {
		return poolCacheb0.get();
	}

	public static void _reset_unsafe_add_(Cacheb0 bean) {
		poolCacheb0._reset_unsafe_add_(bean);
	}

	public static void padd(Cacheb0 bean) {
		mkdb.Procedure.padd(bean, poolCacheb0);
	}

	public static Cacheb0 newCacheb0Data() {
		return new xbean.__.Cacheb0.Data();
	}

	public static mkdb.util.BeanPool<Cacheb1> poolCacheb1 = new mkdb.util.BeanPool<Cacheb1>() {
		@Override
		protected Cacheb1 newBean() {
			return new xbean.__.Cacheb1();
		}
	};

	public static Cacheb1 newCacheb1() {
		return poolCacheb1.get();
	}

	public static void _reset_unsafe_add_(Cacheb1 bean) {
		poolCacheb1._reset_unsafe_add_(bean);
	}

	public static void padd(Cacheb1 bean) {
		mkdb.Procedure.padd(bean, poolCacheb1);
	}

	public static Cacheb1 newCacheb1Data() {
		return new xbean.__.Cacheb1.Data();
	}

	public static mkdb.util.BeanPool<Cacheb2> poolCacheb2 = new mkdb.util.BeanPool<Cacheb2>() {
		@Override
		protected Cacheb2 newBean() {
			return new xbean.__.Cacheb2();
		}
	};

	public static Cacheb2 newCacheb2() {
		return poolCacheb2.get();
	}

	public static void _reset_unsafe_add_(Cacheb2 bean) {
		poolCacheb2._reset_unsafe_add_(bean);
	}

	public static void padd(Cacheb2 bean) {
		mkdb.Procedure.padd(bean, poolCacheb2);
	}

	public static Cacheb2 newCacheb2Data() {
		return new xbean.__.Cacheb2.Data();
	}

	public static mkdb.util.BeanPool<xbeanwithcbean> poolxbeanwithcbean = new mkdb.util.BeanPool<xbeanwithcbean>() {
		@Override
		protected xbeanwithcbean newBean() {
			return new xbean.__.xbeanwithcbean();
		}
	};

	public static xbeanwithcbean newxbeanwithcbean() {
		return poolxbeanwithcbean.get();
	}

	public static void _reset_unsafe_add_(xbeanwithcbean bean) {
		poolxbeanwithcbean._reset_unsafe_add_(bean);
	}

	public static void padd(xbeanwithcbean bean) {
		mkdb.Procedure.padd(bean, poolxbeanwithcbean);
	}

	public static xbeanwithcbean newxbeanwithcbeanData() {
		return new xbean.__.xbeanwithcbean.Data();
	}

	public static mkdb.util.BeanPool<First> poolFirst = new mkdb.util.BeanPool<First>() {
		@Override
		protected First newBean() {
			return new xbean.__.First();
		}
	};

	public static First newFirst() {
		return poolFirst.get();
	}

	public static void _reset_unsafe_add_(First bean) {
		poolFirst._reset_unsafe_add_(bean);
	}

	public static void padd(First bean) {
		mkdb.Procedure.padd(bean, poolFirst);
	}

	public static First newFirstData() {
		return new xbean.__.First.Data();
	}

	public static mkdb.util.BeanPool<Second> poolSecond = new mkdb.util.BeanPool<Second>() {
		@Override
		protected Second newBean() {
			return new xbean.__.Second();
		}
	};

	public static Second newSecond() {
		return poolSecond.get();
	}

	public static void _reset_unsafe_add_(Second bean) {
		poolSecond._reset_unsafe_add_(bean);
	}

	public static void padd(Second bean) {
		mkdb.Procedure.padd(bean, poolSecond);
	}

	public static Second newSecondData() {
		return new xbean.__.Second.Data();
	}

	public static mkdb.util.BeanPool<RB> poolRB = new mkdb.util.BeanPool<RB>() {
		@Override
		protected RB newBean() {
			return new xbean.__.RB();
		}
	};

	public static RB newRB() {
		return poolRB.get();
	}

	public static void _reset_unsafe_add_(RB bean) {
		poolRB._reset_unsafe_add_(bean);
	}

	public static void padd(RB bean) {
		mkdb.Procedure.padd(bean, poolRB);
	}

	public static RB newRBData() {
		return new xbean.__.RB.Data();
	}

	public static mkdb.util.BeanPool<RBTest> poolRBTest = new mkdb.util.BeanPool<RBTest>() {
		@Override
		protected RBTest newBean() {
			return new xbean.__.RBTest();
		}
	};

	public static RBTest newRBTest() {
		return poolRBTest.get();
	}

	public static void _reset_unsafe_add_(RBTest bean) {
		poolRBTest._reset_unsafe_add_(bean);
	}

	public static void padd(RBTest bean) {
		mkdb.Procedure.padd(bean, poolRBTest);
	}

	public static RBTest newRBTestData() {
		return new xbean.__.RBTest.Data();
	}

	public static mkdb.util.BeanPool<Family> poolFamily = new mkdb.util.BeanPool<Family>() {
		@Override
		protected Family newBean() {
			return new xbean.__.Family();
		}
	};

	public static Family newFamily() {
		return poolFamily.get();
	}

	public static void _reset_unsafe_add_(Family bean) {
		poolFamily._reset_unsafe_add_(bean);
	}

	public static void padd(Family bean) {
		mkdb.Procedure.padd(bean, poolFamily);
	}

	public static Family newFamilyData() {
		return new xbean.__.Family.Data();
	}

	public static mkdb.util.BeanPool<MemberInfo> poolMemberInfo = new mkdb.util.BeanPool<MemberInfo>() {
		@Override
		protected MemberInfo newBean() {
			return new xbean.__.MemberInfo();
		}
	};

	public static MemberInfo newMemberInfo() {
		return poolMemberInfo.get();
	}

	public static void _reset_unsafe_add_(MemberInfo bean) {
		poolMemberInfo._reset_unsafe_add_(bean);
	}

	public static void padd(MemberInfo bean) {
		mkdb.Procedure.padd(bean, poolMemberInfo);
	}

	public static MemberInfo newMemberInfoData() {
		return new xbean.__.MemberInfo.Data();
	}

	public static mkdb.util.BeanPool<Any> poolAny = new mkdb.util.BeanPool<Any>() {
		@Override
		protected Any newBean() {
			return new xbean.__.Any();
		}
	};

	public static Any newAny() {
		return poolAny.get();
	}

	public static void _reset_unsafe_add_(Any bean) {
		poolAny._reset_unsafe_add_(bean);
	}

	public static void padd(Any bean) {
		mkdb.Procedure.padd(bean, poolAny);
	}

	public static Any newAnyData() {
		return new xbean.__.Any.Data();
	}

	public static mkdb.util.BeanPool<Any2> poolAny2 = new mkdb.util.BeanPool<Any2>() {
		@Override
		protected Any2 newBean() {
			return new xbean.__.Any2();
		}
	};

	public static Any2 newAny2() {
		return poolAny2.get();
	}

	public static void _reset_unsafe_add_(Any2 bean) {
		poolAny2._reset_unsafe_add_(bean);
	}

	public static void padd(Any2 bean) {
		mkdb.Procedure.padd(bean, poolAny2);
	}

	public static Any2 newAny2Data() {
		return new xbean.__.Any2.Data();
	}

	public static mkdb.util.BeanPool<AnyFake> poolAnyFake = new mkdb.util.BeanPool<AnyFake>() {
		@Override
		protected AnyFake newBean() {
			return new xbean.__.AnyFake();
		}
	};

	public static AnyFake newAnyFake() {
		return poolAnyFake.get();
	}

	public static void _reset_unsafe_add_(AnyFake bean) {
		poolAnyFake._reset_unsafe_add_(bean);
	}

	public static void padd(AnyFake bean) {
		mkdb.Procedure.padd(bean, poolAnyFake);
	}

	public static AnyFake newAnyFakeData() {
		return new xbean.__.AnyFake.Data();
	}

	public static mkdb.util.BeanPool<TestLP> poolTestLP = new mkdb.util.BeanPool<TestLP>() {
		@Override
		protected TestLP newBean() {
			return new xbean.__.TestLP();
		}
	};

	public static TestLP newTestLP() {
		return poolTestLP.get();
	}

	public static void _reset_unsafe_add_(TestLP bean) {
		poolTestLP._reset_unsafe_add_(bean);
	}

	public static void padd(TestLP bean) {
		mkdb.Procedure.padd(bean, poolTestLP);
	}

	public static TestLP newTestLPData() {
		return new xbean.__.TestLP.Data();
	}

	public static mkdb.util.BeanPool<Set2> poolSet2 = new mkdb.util.BeanPool<Set2>() {
		@Override
		protected Set2 newBean() {
			return new xbean.__.Set2();
		}
	};

	public static Set2 newSet2() {
		return poolSet2.get();
	}

	public static void _reset_unsafe_add_(Set2 bean) {
		poolSet2._reset_unsafe_add_(bean);
	}

	public static void padd(Set2 bean) {
		mkdb.Procedure.padd(bean, poolSet2);
	}

	public static Set2 newSet2Data() {
		return new xbean.__.Set2.Data();
	}

	public static mkdb.util.BeanPool<TestType> poolTestType = new mkdb.util.BeanPool<TestType>() {
		@Override
		protected TestType newBean() {
			return new xbean.__.TestType();
		}
	};

	public static TestType newTestType() {
		return poolTestType.get();
	}

	public static void _reset_unsafe_add_(TestType bean) {
		poolTestType._reset_unsafe_add_(bean);
	}

	public static void padd(TestType bean) {
		mkdb.Procedure.padd(bean, poolTestType);
	}

	public static TestType newTestTypeData() {
		return new xbean.__.TestType.Data();
	}

	public static mkdb.util.BeanPool<NetBar> poolNetBar = new mkdb.util.BeanPool<NetBar>() {
		@Override
		protected NetBar newBean() {
			return new xbean.__.NetBar();
		}
	};

	public static NetBar newNetBar() {
		return poolNetBar.get();
	}

	public static void _reset_unsafe_add_(NetBar bean) {
		poolNetBar._reset_unsafe_add_(bean);
	}

	public static void padd(NetBar bean) {
		mkdb.Procedure.padd(bean, poolNetBar);
	}

	public static NetBar newNetBarData() {
		return new xbean.__.NetBar.Data();
	}

	public static mkdb.util.BeanPool<varMap> poolvarMap = new mkdb.util.BeanPool<varMap>() {
		@Override
		protected varMap newBean() {
			return new xbean.__.varMap();
		}
	};

	public static varMap newvarMap() {
		return poolvarMap.get();
	}

	public static void _reset_unsafe_add_(varMap bean) {
		poolvarMap._reset_unsafe_add_(bean);
	}

	public static void padd(varMap bean) {
		mkdb.Procedure.padd(bean, poolvarMap);
	}

	public static varMap newvarMapData() {
		return new xbean.__.varMap.Data();
	}

	public static mkdb.util.BeanPool<varSet> poolvarSet = new mkdb.util.BeanPool<varSet>() {
		@Override
		protected varSet newBean() {
			return new xbean.__.varSet();
		}
	};

	public static varSet newvarSet() {
		return poolvarSet.get();
	}

	public static void _reset_unsafe_add_(varSet bean) {
		poolvarSet._reset_unsafe_add_(bean);
	}

	public static void padd(varSet bean) {
		mkdb.Procedure.padd(bean, poolvarSet);
	}

	public static varSet newvarSetData() {
		return new xbean.__.varSet.Data();
	}

	public static mkdb.util.BeanPool<varXBean> poolvarXBean = new mkdb.util.BeanPool<varXBean>() {
		@Override
		protected varXBean newBean() {
			return new xbean.__.varXBean();
		}
	};

	public static varXBean newvarXBean() {
		return poolvarXBean.get();
	}

	public static void _reset_unsafe_add_(varXBean bean) {
		poolvarXBean._reset_unsafe_add_(bean);
	}

	public static void padd(varXBean bean) {
		mkdb.Procedure.padd(bean, poolvarXBean);
	}

	public static varXBean newvarXBeanData() {
		return new xbean.__.varXBean.Data();
	}

	public static mkdb.util.BeanPool<SubBean> poolSubBean = new mkdb.util.BeanPool<SubBean>() {
		@Override
		protected SubBean newBean() {
			return new xbean.__.SubBean();
		}
	};

	public static SubBean newSubBean() {
		return poolSubBean.get();
	}

	public static void _reset_unsafe_add_(SubBean bean) {
		poolSubBean._reset_unsafe_add_(bean);
	}

	public static void padd(SubBean bean) {
		mkdb.Procedure.padd(bean, poolSubBean);
	}

	public static SubBean newSubBeanData() {
		return new xbean.__.SubBean.Data();
	}

	public static mkdb.util.BeanPool<DataType> poolDataType = new mkdb.util.BeanPool<DataType>() {
		@Override
		protected DataType newBean() {
			return new xbean.__.DataType();
		}
	};

	public static DataType newDataType() {
		return poolDataType.get();
	}

	public static void _reset_unsafe_add_(DataType bean) {
		poolDataType._reset_unsafe_add_(bean);
	}

	public static void padd(DataType bean) {
		mkdb.Procedure.padd(bean, poolDataType);
	}

	public static DataType newDataTypeData() {
		return new xbean.__.DataType.Data();
	}

	public static mkdb.util.BeanPool<fxbean0> poolfxbean0 = new mkdb.util.BeanPool<fxbean0>() {
		@Override
		protected fxbean0 newBean() {
			return new xbean.__.fxbean0();
		}
	};

	public static fxbean0 newfxbean0() {
		return poolfxbean0.get();
	}

	public static void _reset_unsafe_add_(fxbean0 bean) {
		poolfxbean0._reset_unsafe_add_(bean);
	}

	public static void padd(fxbean0 bean) {
		mkdb.Procedure.padd(bean, poolfxbean0);
	}

	public static fxbean0 newfxbean0Data() {
		return new xbean.__.fxbean0.Data();
	}

	public static mkdb.util.BeanPool<fxbean> poolfxbean = new mkdb.util.BeanPool<fxbean>() {
		@Override
		protected fxbean newBean() {
			return new xbean.__.fxbean();
		}
	};

	public static fxbean newfxbean() {
		return poolfxbean.get();
	}

	public static void _reset_unsafe_add_(fxbean bean) {
		poolfxbean._reset_unsafe_add_(bean);
	}

	public static void padd(fxbean bean) {
		mkdb.Procedure.padd(bean, poolfxbean);
	}

	public static fxbean newfxbeanData() {
		return new xbean.__.fxbean.Data();
	}

	public static mkdb.util.BeanPool<depends1> pooldepends1 = new mkdb.util.BeanPool<depends1>() {
		@Override
		protected depends1 newBean() {
			return new xbean.__.depends1();
		}
	};

	public static depends1 newdepends1() {
		return pooldepends1.get();
	}

	public static void _reset_unsafe_add_(depends1 bean) {
		pooldepends1._reset_unsafe_add_(bean);
	}

	public static void padd(depends1 bean) {
		mkdb.Procedure.padd(bean, pooldepends1);
	}

	public static depends1 newdepends1Data() {
		return new xbean.__.depends1.Data();
	}

	public static mkdb.util.BeanPool<Flush> poolFlush = new mkdb.util.BeanPool<Flush>() {
		@Override
		protected Flush newBean() {
			return new xbean.__.Flush();
		}
	};

	public static Flush newFlush() {
		return poolFlush.get();
	}

	public static void _reset_unsafe_add_(Flush bean) {
		poolFlush._reset_unsafe_add_(bean);
	}

	public static void padd(Flush bean) {
		mkdb.Procedure.padd(bean, poolFlush);
	}

	public static Flush newFlushData() {
		return new xbean.__.Flush.Data();
	}

	public static mkdb.util.BeanPool<SecondaryIndex> poolSecondaryIndex = new mkdb.util.BeanPool<SecondaryIndex>() {
		@Override
		protected SecondaryIndex newBean() {
			return new xbean.__.SecondaryIndex();
		}
	};

	public static SecondaryIndex newSecondaryIndex() {
		return poolSecondaryIndex.get();
	}

	public static void _reset_unsafe_add_(SecondaryIndex bean) {
		poolSecondaryIndex._reset_unsafe_add_(bean);
	}

	public static void padd(SecondaryIndex bean) {
		mkdb.Procedure.padd(bean, poolSecondaryIndex);
	}

	public static SecondaryIndex newSecondaryIndexData() {
		return new xbean.__.SecondaryIndex.Data();
	}

	public static mkdb.util.BeanPool<Diskdbh> poolDiskdbh = new mkdb.util.BeanPool<Diskdbh>() {
		@Override
		protected Diskdbh newBean() {
			return new xbean.__.Diskdbh();
		}
	};

	public static Diskdbh newDiskdbh() {
		return poolDiskdbh.get();
	}

	public static void _reset_unsafe_add_(Diskdbh bean) {
		poolDiskdbh._reset_unsafe_add_(bean);
	}

	public static void padd(Diskdbh bean) {
		mkdb.Procedure.padd(bean, poolDiskdbh);
	}

	public static Diskdbh newDiskdbhData() {
		return new xbean.__.Diskdbh.Data();
	}

	public static mkdb.util.BeanPool<yyy> poolyyy = new mkdb.util.BeanPool<yyy>() {
		@Override
		protected yyy newBean() {
			return new xbean.__.yyy();
		}
	};

	public static yyy newyyy() {
		return poolyyy.get();
	}

	public static void _reset_unsafe_add_(yyy bean) {
		poolyyy._reset_unsafe_add_(bean);
	}

	public static void padd(yyy bean) {
		mkdb.Procedure.padd(bean, poolyyy);
	}

	public static yyy newyyyData() {
		return new xbean.__.yyy.Data();
	}

	public static mkdb.util.BeanPool<xxx> poolxxx = new mkdb.util.BeanPool<xxx>() {
		@Override
		protected xxx newBean() {
			return new xbean.__.xxx();
		}
	};

	public static xxx newxxx() {
		return poolxxx.get();
	}

	public static void _reset_unsafe_add_(xxx bean) {
		poolxxx._reset_unsafe_add_(bean);
	}

	public static void padd(xxx bean) {
		mkdb.Procedure.padd(bean, poolxxx);
	}

	public static xxx newxxxData() {
		return new xbean.__.xxx.Data();
	}

	public static mkdb.util.BeanPool<varValue> poolvarValue = new mkdb.util.BeanPool<varValue>() {
		@Override
		protected varValue newBean() {
			return new xbean.__.varValue();
		}
	};

	public static varValue newvarValue() {
		return poolvarValue.get();
	}

	public static void _reset_unsafe_add_(varValue bean) {
		poolvarValue._reset_unsafe_add_(bean);
	}

	public static void padd(varValue bean) {
		mkdb.Procedure.padd(bean, poolvarValue);
	}

	public static varValue newvarValueData() {
		return new xbean.__.varValue.Data();
	}

}
