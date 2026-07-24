
package xbean;

public interface BuffAgent extends mkdb.Bean {
	public BuffAgent copy(); // 深拷贝
	public BuffAgent toData(); // 一个 Data 实例
	public BuffAgent toBean(); // 一个 Bean 实例
	public BuffAgent toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BuffAgent toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.Buff> getBuffs(); // key为buffId
	public java.util.Map<Integer, xbean.Buff> getBuffsAsData(); // key为buffId
	public java.util.Map<Integer, Integer> getBattleendclear(); // 如果在战斗中buff到时，id放入此表，等战斗结束一起执行。 key为buffId，value为处理方式：1为detach，2为period process
	public java.util.Map<Integer, Integer> getBattleendclearAsData(); // 如果在战斗中buff到时，id放入此表，等战斗结束一起执行。 key为buffId，value为处理方式：1为detach，2为period process
	public java.util.Map<Integer, Long> getTimerfutures(); // key=buffId value=未来id
	public java.util.Map<Integer, Long> getTimerfuturesAsData(); // key=buffId value=未来id

}
