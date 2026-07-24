
package fire.pb.activity;

// 保留 2016 结构，使用更清晰的 this 引用
public class CancelDelayActivity implements Runnable {

	private DelayActivity activity;
	
	public CancelDelayActivity(DelayActivity activity) {
       this.activity = activity;
	}

	@Override
	public void run() {
      DelayActivityManager.getInstance().removeDelayActivity(this.activity);
	}

}

