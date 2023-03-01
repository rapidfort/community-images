
show dbs
show collections
db.version()
use rapidfort
db.createCollection("community")
db.community.insertMany([ {name: "Dave", origin: "Ireland", skill: "noob"}, {name: "Anmol", origin: "India", skill: "ninja"}, {name: "Ankit", origin: "India", skill: "wizard"}, {name: "Vinod", origin: "India", skill: "wizard", compensation: "astronomical"}, {name: "Reuben", origin: "USA", skill: "noob", passion: "whiskey"} ])
db.community.find().pretty()

