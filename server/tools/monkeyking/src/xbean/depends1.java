
package xbean;

public interface depends1 extends mkdb.Bean {
	public depends1 copy(); // deep clone
	public depends1 toData(); // a Data instance
	public depends1 toBean(); // a Bean instance
	public depends1 toDataIf(); // a Data instance If need. else return this
	public depends1 toBeanIf(); // a Bean instance If need. else return this

	public int getDummyavoidwarning(); // 

	public void setDummyavoidwarning(int _v_); // 
}
