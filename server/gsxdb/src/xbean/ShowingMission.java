
package xbean;

public interface ShowingMission extends mkdb.Bean {
	public ShowingMission copy(); // 深拷贝
	public ShowingMission toData(); // 一个 Data 实例
	public ShowingMission toBean(); // 一个 Bean 实例
	public ShowingMission toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ShowingMission toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getMissionid(); // 
	public boolean getIsleader(); // 

	public void setMissionid(int _v_); // 
	public void setIsleader(boolean _v_); // 
}
