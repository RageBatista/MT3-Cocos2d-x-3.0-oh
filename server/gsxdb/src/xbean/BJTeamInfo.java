
package xbean;

public interface BJTeamInfo extends mkdb.Bean {
	public BJTeamInfo copy(); // 深拷贝
	public BJTeamInfo toData(); // 一个 Data 实例
	public BJTeamInfo toBean(); // 一个 Bean 实例
	public BJTeamInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BJTeamInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getServiceid(); // 
	public java.util.List<Long> getBjdata(); // 
	public java.util.List<Long> getBjdataAsData(); // 

	public void setServiceid(int _v_); // 
}
