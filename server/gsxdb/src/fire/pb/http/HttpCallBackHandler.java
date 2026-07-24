/*
 * @作者：错误：错误：git config user.name & 请设置死值或安装 git && 错误：git config user.email & 请设置死值或安装 git & 请设置死值或安装 git
 * @日期：2025-12-30 17:13:08
 * @LastEditors：错误：错误：git config user.name & 请设置死值或安装 git && 错误：git config user.email & 请设置死值或安装 git & 请设置死值或安装 git
 * @LastEditTime: 2026-01-11 11:20:17
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\http\HttpCallBackHandler.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
package fire.pb.http;

import com.fasterxml.jackson.databind.JsonNode;
import fire.util.JsonUtil;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.concurrent.FutureCallback;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;

/**
 * @作者直流
 * http异步回调接口包装
 */
public abstract class HttpCallBackHandler implements FutureCallback<HttpResponse>{
	private static final Logger logger = Logger.getLogger("SYSTEM");
	
	protected abstract boolean process(JsonNode json);
	
	@Override
    public void completed(final HttpResponse response) {
		logger.info("http response completed:" + response.getStatusLine() + ";thread:" + Thread.currentThread().getId());
		try {
			int status = response.getStatusLine().getStatusCode();
            if (status >= 200 && status < 300) {
                HttpEntity entity = response.getEntity();
                String result = EntityUtils.toString(entity);
                logger.debug(result);
                if(result == null || result.isEmpty()){
                	logger.error("HttpCallBackHandler completed, but HttpEntity to String is null!");
                	return;
                }
                JsonNode jsonret = JsonUtil.parseJson(result);
                process(jsonret);
            } else {
                throw new ClientProtocolException("Unexpected http response status: " + status);
            }
		} catch (Throwable e) {
			e.printStackTrace();
		}
    }

    @Override
    public void failed(final Exception ex) {
    	logger.error("http response failed:" + ex + ";thread:" + Thread.currentThread().getId());
    }

    @Override
    public void cancelled() {
    	logger.error("http response cancelled;thread:" + Thread.currentThread().getId());
    }
}
