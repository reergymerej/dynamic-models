----------------------------------
--- Define a model, one shot!
WITH new_model as (
	-- model
	insert into model (name) values ('sticker') returning *
),
new_attributes as (
	-- attributes
	insert into attributes (type, name) values
		('string', 'description'),
		('string', 'stock id'),
		('string', 'image url'),
		('num', 'on hand'),
		('num', 'price'),
		('bool', 'awesome')
	on conflict on constraint attributes_type_name_key
	do update set name=EXCLUDED.name
	returning *
)
-- model_attributes
insert into model_attributes (model_id, attributes_id)
  select nm.id, na.id from new_model nm, new_attributes na;





----------------------------------
-- See a model definition.
select m.name, a.type, a.name
from model m
left join model_attributes ma on ma.model_id = m.id
left join attributes a on a.id = ma.attributes_id
where m.name = 'sticker'
order by m.id
;




----------------------------------
-- Add an attribute to a model.
WITH new_attributes as (
	-- attributes
	insert into attributes (type, name) values
		('string', 'color'),
		('num', 'discount price')
	on conflict on constraint attributes_type_name_key
	do update set name=EXCLUDED.name
	returning *
)
-- model_attributes
insert into model_attributes (model_id, attributes_id)
  select (
    select m.id from model m where m.name = 'sticker'
  ), na.id from new_attributes na;


