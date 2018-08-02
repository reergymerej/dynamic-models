----------------------------------
--- Define a model, one shot!
WITH new_model as (
	-- model
	insert into model (name) values ('shoe') returning *
),
new_attributes as (
	-- attributes
	insert into attributes (type, name) values
		('string', 'brand'),
		('string', 'description'),
		('string', 'image url'),
		('num', 'price'),
		('num', 'in stock')
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
--where m.name = 'shoe'
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




----------------------------------
-- Add instance of model.
INSERT INTO model_instances (model_id)
	SELECT m.id FROM model m WHERE name = 'shoe'
;

-- model instance id
select mi.id
from model_instances mi
where mi.model_id = (
	SELECT m.id FROM model m WHERE name = 'shoe'
);

-- Add instance values.
--	brand: Nike
--	image url: http://foo.com/1
--	image url: http://foo.com/2
--	price: 9.99

select * from attributes_values_string avs;

INSERT INTO attributes_values_string (model_instance_id, attributes_id, value)
VALUES (
	2,  -- get from query
	(
		select a.id
		from model m
		left join model_attributes ma on ma.model_id = m.id
		left join attributes a on a.id = ma.attributes_id
		where m.name = 'shoe'
		and a.name = 'brand'
	),

	'Adidas'
);

INSERT INTO attributes_values_num (model_instance_id, attributes_id, value)
VALUES (
	2,  -- get from query
	(
		select a.id
		from model m
		left join model_attributes ma on ma.model_id = m.id
		left join attributes a on a.id = ma.attributes_id
		where m.name = 'shoe'
		and a.name = 'price'
	),

	19.99
);




----------------------------------
-- Get all data for an instance.
select a.name, avs.value, null as "value"
from model_instances mi
join model m on m.id = mi.model_id
join attributes_values_string avs on avs.model_instance_id = mi.id
join attributes a on a.id = avs.attributes_id
where mi.id = 2

UNION ALL

select a.name, null as "value", avn.value
from model_instances mi
join model m on m.id = mi.model_id
join attributes_values_num avn on avn.model_instance_id = mi.id
join attributes a on a.id = avn.attributes_id
where mi.id = 2
;

