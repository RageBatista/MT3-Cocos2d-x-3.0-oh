
package xbean;

public interface SecondaryIndex extends mkdb.Bean {
	public SecondaryIndex copy(); // deep clone
	public SecondaryIndex toData(); // a Data instance
	public SecondaryIndex toBean(); // a Bean instance
	public SecondaryIndex toDataIf(); // a Data instance If need. else return this
	public SecondaryIndex toBeanIf(); // a Bean instance If need. else return this

	public int getSecondaryindex(); // 

	public void setSecondaryindex(int _v_); // 
}
