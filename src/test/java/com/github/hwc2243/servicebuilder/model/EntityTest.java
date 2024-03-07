package com.github.hwc2243.servicebuilder.model;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;
import java.util.Map;

public class EntityTest {

	@Test
	public void entity_shouldBeEqual ()
	{
		Entity entity1 = new Entity();
		entity1.setName("test");
		
		Entity entity2 = new Entity();
		entity2.setName("test");
		
		assertThat(entity1).isEqualTo(entity2);
	}
	
	@Test
	public void entity_shouldNotBeEqual ()
	{
		Entity entity1 = new Entity();
		entity1.setName("test");
		
		Entity entity2 = new Entity();
		entity2.setName("not equal");
		
		assertThat(entity1).isNotEqualTo(entity2);
	}
	
	@Test
	public void entity_shouldHash ()
	{
		Map<Entity, String> hashMap = new HashMap<>();
		Entity entity1 = new Entity();
		entity1.setName("test");
		hashMap.put(entity1, "should find");
		
		Entity entity2 = new Entity();
		entity2.setName("test");
		assertThat(hashMap.get(entity2)).isNotNull();
	}
}
