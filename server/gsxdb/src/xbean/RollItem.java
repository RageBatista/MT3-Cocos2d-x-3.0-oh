
package xbean;

public interface RollItem extends mkdb.Bean {
	public RollItem copy(); // 深拷贝
	public RollItem toData(); // 一个 Data 实例
	public RollItem toBean(); // 一个 Bean 实例
	public RollItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RollItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemid(); // 道具表id，作者 changhao
	public int getItemnum(); // 数量id，作者 changhao
	public int getCountertype(); // 
	public int getXiangguanid(); // 
	public int getAwardid(); // 

	public void setItemid(int _v_); // 道具表id，作者 changhao
	public void setItemnum(int _v_); // 数量id，作者 changhao
	public void setCountertype(int _v_); // 
	public void setXiangguanid(int _v_); // 
	public void setAwardid(int _v_); // 
}
