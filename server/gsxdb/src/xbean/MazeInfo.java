
package xbean;

public interface MazeInfo extends mkdb.Bean {
	public MazeInfo copy(); // 深拷贝
	public MazeInfo toData(); // 一个 Data 实例
	public MazeInfo toBean(); // 一个 Bean 实例
	public MazeInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MazeInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getMapid(); // 地图id
	public int getPos(); // 位置编号或者npcid，待定

	public void setMapid(int _v_); // 地图id
	public void setPos(int _v_); // 位置编号或者npcid，待定
}
