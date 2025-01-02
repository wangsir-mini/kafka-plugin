local typedefs = require "kong.db.schema.typedefs"

return {
    name = "event-collect",
    fields = {
        -- 配置记录（record），包含所有与 Kafka 相关的设置
        {
            config = {
                type = "record",
                fields = {
                    {
                        kafka = {
                            type = "record",
                            fields = {
                                { host = { type = "string", required = true, default = "localhost" } }, -- Kafka 主机地址
                                { port = { type = "number", required = false, default = 9092 } }, -- Kafka 端口号
                                { topic = { type = "string", required = true } }, -- Kafka 主题名称
                            },
                        },
                    },
                },
            },
        },
    },
}