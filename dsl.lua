local dsl = {}

--contains constructors
local constructors = {}
--stores predicates for groups
local predicates = {}
--for objects of types as defined by the dsl.object function
local groups = {}
--array of event types like events = {event_name1, event_name2, ...}
local events = {}
--listeners[group_name] = [event_name] = {} aka nested table
local listeners = {}

--creates a new object type similar to classes
function dsl.object(name)
  groups[name] = {}
  listeners[name] = {}
  return function(body)
    body.__index = body
    constructors[name] = function(object)
      setmetatable(object, body)
      for g, predicate in pairs(predicates) do
        if predicate(object) then
          table.insert(groups[g], object)
        end
      end
      return object
    end
  end
end

--a constructor for objects
function dsl.new(name)
  return function(data)
    local o = constructors[name](data)
    table.insert(groups[name], o)
    return o
  end
end

function dsl.group(name)
  groups[name] = {}
  listeners[name] = {}
  return function(func)
    predicates[name] = func
  end
end

--creates a new event type
function dsl.event(name)
  table.insert(events, name)
  for group, _ in pairs(groups) do
    listeners[group][name] = {}
  end
end

--dispatches event
function dsl.dispatch(group)
  return function(event)
    return function(data)
      for _, listener in ipairs(listeners[group][event]) do
        listener(data)
      end
    end
  end
end

--event is a string
function dsl.when(group)
  return function(event)
    return function(func)
      table.insert(listeners[group][event], func)
    end
  end
end

--function that operates on each item of a group
function dsl.for_each(group)
  return function(func)
    for _, object in ipairs(groups[group]) do
      func(object)
    end
  end
end

return dsl
