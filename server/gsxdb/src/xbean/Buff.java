
package xbean;

public interface Buff extends mkdb.Bean {
	public Buff copy(); // 深拷贝
	public Buff toData(); // 一个 Data 实例
	public Buff toBean(); // 一个 Bean 实例
	public Buff toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Buff toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public final static int BATTLE_END_IMPACT = 1; // 战斗结束detach
	public final static int BATTLE_END_PROCESS = 2; // 战斗结束process

	public int getIndex(); // buff类型Id，一种类型的buff只能有一个
	public long getImpacttime(); // buff attach时的时间，用于计算剩余时间和检测到期
	public long getRemaintime(); // 计时buff总持续时间（period时的period）
	public int getRound(); // 计数buff剩余回合（period时的count）
	public long getValue(); // buff的剩余量（period时的initDelay）
	public java.util.Map<Integer, Float> getEffects(); // key = 效果类型id
	public java.util.Map<Integer, Float> getEffectsAsData(); // key = 效果类型id
	public int getFighterkey(); // 当在战斗中添加的buff时，记录战斗者key

	public void setIndex(int _v_); // buff类型Id，一种类型的buff只能有一个
	public void setImpacttime(long _v_); // buff attach时的时间，用于计算剩余时间和检测到期
	public void setRemaintime(long _v_); // 计时buff总持续时间（period时的period）
	public void setRound(int _v_); // 计数buff剩余回合（period时的count）
	public void setValue(long _v_); // buff的剩余量（period时的initDelay）
	public void setFighterkey(int _v_); // 当在战斗中添加的buff时，记录战斗者key
}
