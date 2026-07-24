/**
 * JSON工具类 - 基于Jackson 2.x
 * 替代 net.sf.json.JSONObject/JSONArray
 *
 * @作者 GSXDB 团队
 * @版本1.0.0
 */
package fire.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.log4j.Logger;

public class JsonUtil {
    private static final Logger logger = Logger.getLogger("JSON");
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    /**
     * 对象转JSON字符串
     * 替代: JSONObject.fromObject(obj).toString()
     * 
     * @param obj 要序列化的对象
     * @return JSON字符串，失败返回 "{}"
     */
    public static String toJsonString(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            logger.error("JSON序列化失败", e);
            return "{}";
        }
    }
    
    /**
     * JSON字符串转对象
     * 替代: JSONObject.fromObject(str)
     * 
     * @param json JSON字符串
     * @param clazz 目标类型
     * @return 反序列化后的对象，失败返回 null
     */
    public static <T> T fromJson(String json, Class<T> clazz) {
        try {
            return objectMapper.readValue(json, clazz);
        } catch (Exception e) {
            logger.error("JSON反序列化失败: " + json, e);
            return null;
        }
    }
    
    /**
     * JSON字符串转JsonNode（用于动态访问）
     * 替代: JSONObject.fromObject(str)
     * 
     * @param json JSON字符串
     * @return JsonNode对象，失败返回 null
     */
    public static JsonNode parseJson(String json) {
        try {
            return objectMapper.readTree(json);
        } catch (Exception e) {
            logger.error("JSON解析失败: " + json, e);
            return null;
        }
    }
    
    /**
     * 创建空的ObjectNode
     * 替代: new JSONObject()
     * 
     * @return ObjectNode对象
     */
    public static ObjectNode createObject() {
        return objectMapper.createObjectNode();
    }
    
    /**
     * 创建空的ArrayNode
     * 替代: new JSONArray()
     * 
     * @return ArrayNode对象
     */
    public static ArrayNode createArray() {
        return objectMapper.createArrayNode();
    }
    
    /**
     * 获取共享的ObjectMapper实例
     * 
     * @return ObjectMapper实例
     */
    public static ObjectMapper getObjectMapper() {
        return objectMapper;
    }
}
