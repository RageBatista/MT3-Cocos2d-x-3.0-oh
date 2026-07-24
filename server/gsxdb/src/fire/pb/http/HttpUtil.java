/*
 * @作者：错误：错误：git config user.name & 请设置死值或安装 git && 错误：git config user.email & 请设置死值或安装 git & 请设置死值或安装 git
 * @日期：2025-12-30 17:13:08
 * @LastEditors：错误：错误：git config user.name & 请设置死值或安装 git && 错误：git config user.email & 请设置死值或安装 git & 请设置死值或安装 git
 * @LastEditTime: 2026-01-11 11:20:02
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\http\HttpUtil.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
package fire.pb.http;

import java.util.concurrent.Future;

import com.fasterxml.jackson.databind.JsonNode;
import fire.util.JsonUtil;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;

import fire.pb.main.Gs;

/**
 * @作者直流
 * http同步请求工具
 */
public class HttpUtil {
	public static final Logger logger = Logger.getLogger("SYSTEM");
	
	public static JsonNode execHttpRequest(HttpGet req) {
		try {
			Future<HttpResponse> future = Gs.getHttpClient().execute(req, null);
			HttpResponse response = future.get();
			int status = response.getStatusLine().getStatusCode();
            if (status >= 200 && status < 300) {
                HttpEntity entity = response.getEntity();
                String result = EntityUtils.toString(entity);
                logger.debug("HttpUtil.execHttpRequest.HttpEntity:" + result);
                if(result == null || result.isEmpty()){
                	logger.error("HttpUtil.execHttpRequest completed, but HttpEntity to String is null!");
                	return null;
                }
                JsonNode jsonret = JsonUtil.parseJson(result);
                return jsonret;
            } else {
                throw new ClientProtocolException("HttpUtil.execHttpRequest,Unexpected http response status: " + status);
            }
		} catch (Throwable e) {
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * 应用宝的请求处理
	 * @参数要求
	 * @返回
	 */
	public static JsonNode execHttpYYBRequest(HttpGet req) {
		try {
			Future<HttpResponse> future = Gs.getHttpClient().execute(req, null);
			HttpResponse response = future.get();
			int status = response.getStatusLine().getStatusCode();
            if (status >= 200 && status < 300) {
                HttpEntity entity = response.getEntity();
                String result = EntityUtils.toString(entity);
                logger.debug("HttpUtil.execHttpYYBRequest.HttpEntity:" + result);
                if (result == null || result.isEmpty()) {
                	logger.error("HttpUtil.execHttpYYBRequest completed, but HttpEntity to String is null!");
                	return null;
                }
                JsonNode jsonret = JsonUtil.parseJson(result);
                return jsonret;
            } else {
            	logger.error("HttpUtil.execHttpYYBRequest,Unexpected http response status: " + status);
            	return null;
            }
		} catch (Throwable e) {
			e.printStackTrace();
		}
		return null;
	}
	
}
