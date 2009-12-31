things.each { |thing| person.use thing }

person.use each(things)

things.each(&'person.use')

person.use_each(things)

person.buy_each(things, :good?)

person.visit_each(shops)

thins.select_expired?.each_drop_to(bin)

things.each &:add_to.call_with(cart)

things.each &:add_to.(cart)

proc do |thing|
  thing.instance_eval self
end
