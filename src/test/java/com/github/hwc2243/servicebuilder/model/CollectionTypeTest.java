package com.github.hwc2243.servicebuilder.model;

import static org.assertj.core.api.Assertions.assertThat;

import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

public class CollectionTypeTest {

	@Test
	public void whenValid_shouldReturnEnum ()
	{
		CollectionType listType = CollectionType.fromString("LIST");
		assertThat(listType).isEqualTo(CollectionType.LIST);
		listType = CollectionType.fromString("List");
		assertThat(listType).isEqualTo(CollectionType.LIST);
		listType = CollectionType.fromString("list");
		assertThat(listType).isEqualTo(CollectionType.LIST);
		
		CollectionType setType = CollectionType.fromString("SET");
		assertThat(setType).isEqualTo(CollectionType.SET);
		setType = CollectionType.fromString("Set");
		assertThat(setType).isEqualTo(CollectionType.SET);
		setType = CollectionType.fromString("set");
		assertThat(setType).isEqualTo(CollectionType.SET);
	}
	
	@Test
	public void invalid_shouldFail ()
	{
		assertThrows(IllegalArgumentException.class, () -> {
			CollectionType.fromString("invalid");
	    });
	}
}
