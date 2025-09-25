package com.github.hwc2243.servicebuilder.model;

/**
 * Represents the allowed data types as defined in the XSD's dataType simpleType.
 * Using an enum ensures type-safety and prevents invalid data type values from being used.
 */
public enum KeyType {
    INT("int", "Integer"),
    LONG("long", "Long"),
    STRING("string", "String");
    
    private final String value;
    private final String javaType;
    
    private KeyType(String value, String javaType) {
        this.value = value;
        this.javaType = javaType;
    }
    
    public String getValue() {
        return value;
    }
    
    public String getJavaType() {
        return javaType;
    }
}