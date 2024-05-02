package com.github.hwc2243.servicebuilder.model;

public enum RelationshipType {
	ONE_TO_ONE,
	ONE_TO_MANY,
	MANY_TO_ONE,
	MANY_TO_MANY;
	
	public static RelationshipType fromString (String value)
	{
		return RelationshipType.valueOf(value.toUpperCase());
	}
}
