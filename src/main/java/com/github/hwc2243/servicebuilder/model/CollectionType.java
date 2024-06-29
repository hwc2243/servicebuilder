package com.github.hwc2243.servicebuilder.model;

public enum CollectionType {
	LIST("List", "java.util.List"),
	SET("Set", "java.util.Set");
	
	protected String collectionType;
	protected String collectionClass;
	
	private CollectionType (String collectionType, String collectionClass)
	{
		this.collectionType = collectionType;
		this.collectionClass = collectionClass;
	}
	
	public String getCollectionType ()
	{
		return this.collectionType;
	}
	
	public String getCollectionClass ()
	{
		return this.collectionClass;
	}
	
	public static CollectionType fromString (String collectionType)
	{
		return CollectionType.valueOf(collectionType.toUpperCase());
	}
}
