local cjson = require("cjson")
local producer = require "resty.kafka.producer"
local EventCollectHandler = {}

EventCollectHandler.PRIORITY = 1
EventCollectHandler.VERSION = "0.1.0"

-- 初始化 Kafka 生产者
local function init_kafka_producer(conf)
    local broker_list = {
        { host = conf.kafka.host, port = conf.kafka.port },
    }
    local bp = producer:new(broker_list, { producer_type = "async" })
    if not bp then
        kong.log.err("Failed to create Kafka producer: ", err)
        return nil, err
    end
    return bp
end

function EventCollectHandler:init_worker()
    -- 在 worker 启动时初始化 Kafka 生产者
    local producer, err = init_kafka_producer(kong.configuration.plugin_configuration("event-collect"))
    if not producer then
        kong.log.err("Failed to initialize Kafka producer during init_worker: ", err)
        return
    end
    kong.ctx.eventCollect.producer = producer
end



function EventCollectHandler:access(conf)
    -- 从 conf 参数中获取配置值
    local kafka_topic = conf.kafka.topic
    local producer = kong.ctx.eventCollect.producer
    if not producer then
        kong.log.err("kp is not initialized")
        return kong.response.exit(200, { message = "Internal Server Error", code = 500, data = {} })
    end
    -- 检查请求方法是否为 POST
    if kong.request.get_method() == "POST" then
        -- 尝试获取请求体
        local raw_body, err = kong.request.get_raw_body()
        if not raw_body then
            kong.log.err("Failed to get request body: ", err)
            return kong.response.exit(200, { message = "Invalid request body" , code = 400 , data = {} })
        end
        -- 发送到kafka
        -- local bp = producer:new(broker_list, { producer_type = "async" })
        -- 发送日志消息,send第二个参数key,用于kafka路由控制:
        -- key为nill(空)时，一段时间向同一partition写入数据
        -- 指定key，按照key的hash写入到对应的partition
        local ok, sendErr = producer:send(kafka_topic, nil, raw_body)
        if not ok then
            kong.log.err("Failed to get request body: ", sendErr);
            return kong.response.exit(200, { message = "handler error" , code = 400 , data = {} })
        end
        return kong.response.exit(200, { message = "success" , code = 0 , data = {} })
    end
    return kong.response.exit(200, { message = "success" , code = 0 , data = {} })
end

return EventCollectHandler