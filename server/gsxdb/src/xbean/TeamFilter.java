
package xbean;

public interface TeamFilter extends mkdb.Bean {
	public TeamFilter copy(); // 深拷贝
	public TeamFilter toData(); // 一个 Data 实例
	public TeamFilter toBean(); // 一个 Bean 实例
	public TeamFilter toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TeamFilter toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public fire.pb.team.TeamFilter getFilter(); // 

	public void setFilter(fire.pb.team.TeamFilter _v_); // 
}
