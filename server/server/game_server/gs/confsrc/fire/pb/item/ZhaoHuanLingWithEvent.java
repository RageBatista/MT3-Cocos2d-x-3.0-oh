package fire.pb.item;


public class ZhaoHuanLingWithEvent implements mytools.ConvMain.Checkable ,Comparable<ZhaoHuanLingWithEvent>{

	public int compareTo(ZhaoHuanLingWithEvent o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public ZhaoHuanLingWithEvent(){
		super();
	}
	public ZhaoHuanLingWithEvent(ZhaoHuanLingWithEvent arg){
		this.id=arg.id ;
		this.eventId=arg.eventId ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * 
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 
	 */
	public int eventId  = 0  ;
	
	public int getEventId(){
		return this.eventId;
	}
	
	public void setEventId(int v){
		this.eventId=v;
	}
	
	
};