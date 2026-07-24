
package xbean;

public interface Pets extends mkdb.Bean {
	public Pets copy(); // 深拷贝
	public Pets toData(); // 一个 Data 实例
	public Pets toBean(); // 一个 Bean 实例
	public Pets toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Pets toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getCapacity(); // 
	public int getNextid(); // 下一个id
	public java.util.Map<Integer, xbean.PetInfo> getPetmap(); // 
	public java.util.Map<Integer, xbean.PetInfo> getPetmapAsData(); // 

	public void setCapacity(int _v_); // 
	public void setNextid(int _v_); // 下一个id
}
