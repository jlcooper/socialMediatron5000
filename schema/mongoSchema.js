conn = new Mongo();
db = conn.getDB("socailMediatron5000");

db.createCollection("configurations");
db.configurations.createIndex({"properties": 1});
db.configurations.createIndex({"active": 1, "properties": 1});

db.createCollection("items");
db.items.createIndex({"figshareId": 1});
db.items.createIndex({"dspaceId": 1});
db.items.createIndex({"rssId": 1});
db.items.createIndex({"source": 1});
db.items.createIndex({"statuses": 1});
db.items.createIndex({"timestamps": 1});

db.createCollection("tweetLog");
db.tweetLog.createIndex({"timestamp": 1});

db.createCollection("postLog");
db.postLog.createIndex({"timestamp": 1});
