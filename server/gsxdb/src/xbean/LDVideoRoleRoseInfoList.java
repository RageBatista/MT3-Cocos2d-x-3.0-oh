
package xbean;

public interface LDVideoRoleRoseInfoList extends mkdb.Bean {
	public LDVideoRoleRoseInfoList copy(); // 深拷贝
	public LDVideoRoleRoseInfoList toData(); // 一个 Data 实例
	public LDVideoRoleRoseInfoList toBean(); // 一个 Bean 实例
	public LDVideoRoleRoseInfoList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LDVideoRoleRoseInfoList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<String, xbean.LDVideoRoleRoseInfo> getLdvideoroleroseinfolist(); // 点赞记录 key=videoid
	public java.util.Map<String, xbean.LDVideoRoleRoseInfo> getLdvideoroleroseinfolistAsData(); // 点赞记录 key=videoid

}
