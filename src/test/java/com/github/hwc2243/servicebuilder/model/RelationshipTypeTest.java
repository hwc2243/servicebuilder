package com.github.hwc2243.servicebuilder.model;

import static org.assertj.core.api.Assertions.assertThat;

import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

public class RelationshipTypeTest {

	@Test
	public void whenValid_shouldReturnEnum ()
	{
		RelationshipType listType = RelationshipType.fromString("one_to_one");
		assertThat(listType).isEqualTo(RelationshipType.ONE_TO_ONE);
		listType = RelationshipType.fromString("One_To_One");
		assertThat(listType).isEqualTo(RelationshipType.ONE_TO_ONE);
		listType = RelationshipType.fromString("One_to_one");
		assertThat(listType).isEqualTo(RelationshipType.ONE_TO_ONE);
	}
	
	@Test
	public void invalid_shouldFail ()
	{
		assertThrows(IllegalArgumentException.class, () -> {
			RelationshipType.fromString("invalid");
	    });
	}
}
