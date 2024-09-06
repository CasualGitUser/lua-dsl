# A domain specific language written in lua
This demonstrates that braceless functions can be used to create domain specific languages with a non-lua-ish syntax.

## Features
1. Create objects as "blueprints" for instances
2. Create groups of entities based on predicates
3. Iteration over a group of entities using a for_each like construct
4. Define and dispatch events
5. React to when an event happens in a group using a "when" keyword-like function

## Examples
### Defining object types
To define a object, use the syntax: ```object "object_name" {default values} ``` <br>
This also creates what is called a "group". In this case its the "person" group. <br>
```lua
object "person" {
  name = "",
  age = 0,
  gender = "",
  balance = 0,
  talk = function(self)
    print("im: ", self.name)
  end
}

object "robot" {
  name = "",
  material = "steel"
}
```
### Creating new instances
To create a instance, use the syntax: ```local varName = new "object_name" {data}``` <br>
The default data that the object (in this case "person") defines acts as a metatable for the new instance. <br>
There are no constructors. if you want to add properties, methods etc. to an object (or use default values), just add them in the instance or dont write them. <br>
The instances that are created are part of the group (in this case the "person" group). <br>
```lua
local bob = new "person" {
  name = "bob",
  age = 20,
  gender = "male",
  --oh noes, debt
  balance = -5000
}

local bobette = new "person" {
  name = "bobette",
  --uses the default age of 0 instead because it is not specified
  gender = "female",
  --no debt
  balance = 5,
  --has an additional field
  friends = {}
}
```
### Defining groups using predicates
This creates a new group. <br>
Every entity that is created after it is tested with this predicate. If it returns true, it adds the object to the group "namedEntity". If it returns false, it doesn't. <br>
Groups should be defined before any instance is created, as all instances created previously wont be tested for this (and therefore may qualify for the group, but arent in it). <br>
For example, a "person" and a "pet" may both have a name, but are different classes (and there in different groups), so you can use this instead to create a new group with both of them in it if you need to iterate over all objects with a name property. <br>
```lua
group "namedEntity" (function(object)
  if object.name then
    return true
  else
    return false
  end
end)
```
### Using for_each to iterate over a group
To iterate over a syntax, use the syntax: ```for_each "group" (function(object_in_group) end)``` <br>
```lua
for_each "namedEntity" (function(namedEntity)
  print("entity name: ", namedEntity.name)
end)
```
### Declaring events
To declare events, use the syntax: ```event "event_name"``` <br>
Note that a event can carry data, but it is not specified in its declaration. The data that is sent is defined in its "dispatch". <br>
Each group now has a "aged up" event. <br>
```lua
event "aged up"
```
### Reacting to events
To react to events, use the syntax: ```when "group" "event" (function(event_data) end)``` <br>
This runs a function when the event fired in one of the members of the specified group. <br>
```lua
when "person" "aged up" (function(data)
  print(data.name, " aged up)
end)
```
### Dispatching events
To dispatch events, use the syntax: ```dispatch "group" "event" {event_data}``` <br>
In this example, this for_each block ages up every person and triggers the aged up event. The event carries the name, the previous age and the new age as data. <br>
```lua
for_each "person" (function(person)
  person.age = person.age + 1
  --dispatch the event "aged up" in group "person"
  --triggers "when" functions that have subscribed to "person" "aged up"
  dispatch "person" "aged up" {
    name = person.name,
    previousAge = person.age - 1,
    newAge = person.age
  }
end)
```
