local dsl = require("object")
local object = dsl.object
local new = dsl.new
local group = dsl.group
local event = dsl.event
local dispatch = dsl.dispatch
local when = dsl.when
local for_each = dsl.for_each

--declare a new type of object called "person"
object "person" {
  name = "",
  age = 0,
  gender = "",
  balance = 0,
}

--declare a group
--if the predicate returns true, the object will be added to the group called "namedEntity"
--only affects objects added from this point on. add groups before using the "new" function
group "namedEntity" (function(object)
  if object.name then
    return true
  else
    return false
  end
end)

--create instance of type "person"
local bob = new "person" {
  name = "bob",
  age = 20,
  gender = "male",
  --oh noes, debt
  balance = -5000
}

--create instance of type "person"
local bobette = new "person" {
  name = "bobette",
  age = 21,
  gender = "female",
  --no debt
  balance = 5
}

for_each "namedEntity" (function(namedEntity)
  print("entity name: ", namedEntity.name)
end)

--declare that there is a event called "aged up"
--the info the event carries is not declared here
event "aged up"

--create an event listener for when a object in group "person" has "aged up"
--data is whatever data we specify in the dispatch
when "person" "aged up" (function(data)
  print("aged up: ", data.name)
end)

for_each "person" (function(person)
  person.age = person.age + 1
  --dispatch the event "aged up" in group "person"
  --triggers "when" functions that have subscribed to "person" "aged up"
  dispatch "person" "aged up" {
    name = person.name,
    oldAge = person.age - 1,
    newAge = person.age
  }
end)
