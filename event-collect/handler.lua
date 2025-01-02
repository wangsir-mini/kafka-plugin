local cjson = require("cjson")
local producer = require "resty.kafka.producer"
local EventCollectHandler = {}

EventCollectHandler.PRIORITY = 1
EventCollectHandler.VERSION = "0.1.0"


function EventCollectHandler:access(conf)
    -- 从 conf 参数中获取配置值
    local kafka_topic = conf.kafka.topic

    local broker_list = {
        { host = conf.kafka.host, port = conf.kafka.port },
    }
    -- 强制读取请求体
    kong.request.set_body_reader(kong.request.get_raw_body)

    -- 检查请求方法是否为 POST
    if kong.request.get_method() == "POST" then
        -- 尝试获取请求体
        local raw_body, err = kong.request.get_raw_body()
        if not raw_body then
            kong.log.err("Failed to get request body: ", err)
            return kong.response.exit(200, { message = "Invalid request body" , code = 400 , data = {} })
        end
        -- 发送到kafka
        local bp = producer:new(broker_list, { producer_type = "async" })
        -- 发送日志消息,send第二个参数key,用于kafka路由控制:
        -- key为nill(空)时，一段时间向同一partition写入数据
        -- 指定key，按照key的hash写入到对应的partition
        local ok, sendErr = bp:send(kafka_topic, nil, raw_body)
        if not ok then
            kong.log.err("Failed to get request body: ", sendErr);
            return kong.response.exit(200, { message = "handler error" , code = 400 , data = {} })
        end
        return kong.response.exit(200, { message = "success" , code = 0 , data = {} })
    end
    return kong.response.exit(200, { message = "success" , code = 0 , data = {} })
end

return EventCollectHandler