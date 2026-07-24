
package xbean;

public interface RoundResultItems extends mkdb.Bean {
	public RoundResultItems copy(); // 深拷贝
	public RoundResultItems toData(); // 一个 Data 实例
	public RoundResultItems toBean(); // 一个 Bean 实例
	public RoundResultItems toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoundResultItems toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<fire.pb.battle.NewResultItem> getResultitems(); // 一个回合战斗的demo
	public java.util.List<fire.pb.battle.AIOperation> getAiactions(); // 随战斗脚本播放的客户端AI动作
	public java.util.Map<Integer, Integer> getFighterfinallyhps(); // 回合结束时战斗者血量的最终值
	public java.util.Map<Integer, Integer> getFighterfinallyhpsAsData(); // 回合结束时战斗者血量的最终值
	public java.util.Map<Integer, Integer> getFighterfinallymps(); // 回合结束时战斗者兰量的最终值
	public java.util.Map<Integer, Integer> getFighterfinallympsAsData(); // 回合结束时战斗者兰量的最终值

}
