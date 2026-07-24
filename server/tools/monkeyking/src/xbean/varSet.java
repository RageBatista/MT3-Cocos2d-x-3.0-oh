
package xbean;

public interface varSet extends mkdb.Bean {
	public varSet copy(); // deep clone
	public varSet toData(); // a Data instance
	public varSet toBean(); // a Bean instance
	public varSet toDataIf(); // a Data instance If need. else return this
	public varSet toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<Integer> getV(); // 
	public java.util.Set<Integer> getVAsData(); // 

}
