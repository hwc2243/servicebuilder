package com.github.hwc2243.servicebuilder.model;

public enum CollectionType {
	LIST,
	SET;
	
	public static CollectionType fromString (String collectionType)
	{
		return CollectionType.valueOf(collectionType.toUpperCase());
	}
}
