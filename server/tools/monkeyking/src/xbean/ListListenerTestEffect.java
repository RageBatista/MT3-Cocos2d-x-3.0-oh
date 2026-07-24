
package xbean;

public interface ListListenerTestEffect extends mkdb.Bean {
	public ListListenerTestEffect copy(); // deep clone
	public ListListenerTestEffect toData(); // a Data instance
	public ListListenerTestEffect toBean(); // a Bean instance
	public ListListenerTestEffect toDataIf(); // a Data instance If need. else return this
	public ListListenerTestEffect toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // 
	public int getType(); // 

	public void setId(int _v_); // 
	public void setType(int _v_); // 
}
