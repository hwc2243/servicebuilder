package com.github.hwc2243.servicebuilder.model;

/**
 * Represents the allowed data types as defined in the XSD's dataType simpleType.
 * Using an enum ensures type-safety and prevents invalid data type values from being used.
 */
public enum DataType {
    BOOLEAN("boolean", "Boolean"),
    ENUM("enum", "Enum"),
    INT("int", "Integer"),
    LONG("long", "Long"),
    FLOAT("float", "Float"),
    DOUBLE("double", "Double"),
    STRING("string", "String"),
    DATE("date", "java.time.LocalDate"),
    TIME("time", "java.time.LocalTime"),
    DATETIME("datetime", "java.time.LocalDateTime"),
    MONEY("money", "java.math.BigDecimal");
    
    private final String value;
    private final String javaType;
    
    private DataType(String value, String javaType) {
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