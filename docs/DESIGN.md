# Design Specification: Generator Schema

## Type Definitions (XSD Mappings)
| DSL Concept | XSD Type | Allowed Values |
| :--- | :--- | :--- |
| **Data Types** | `dataTypes` | boolean, enum, int, long, float, double, string, date, time, datetime, money |
| **Key Types** | `keyTypes` | int, long, string, uuid |
| **Relations** | `relationshipType` | one_to_one, one_to_many, many_to_one, many_to_many |

## Component Architecture
1. **Service Container:** Root element defining package and tenancy.
2. **Entity Definition:** Defines the DB mapping, attributes, and keys.
3. **API Exposure:** Nested internal/external elements controlling allowed `apiOperationsType`.

## API Visibility Definitions
- Internal: API endpoints and services exposed only inside the gated walls (e.g., inter-service communication, system daemons).
- External: API endpoints exposed to end-users, third-party clients, and public/partner integrations.

## Component Structure Specification
| Component | Type | Naming Convention | Role |
| :--- | :--- | :--- | :--- |
| Base | interface | Base{EntityName}{Layer} | Defines the method signatures/contract.
| | abstract | Base{EntityName}{Layer}Impl | Implements the base methods.
| Extension | interface | {EntityName}{Layer} | Defines custom method signatures/contract.
| | concrete | {EntityName}{Layer}Impl | Implements the customer methods.

> **Generation Rule:** The extension interface and concrete implementation (the "Extension" components) must *only* be generated if they do not already exist in the target path. If they exist, the generator must skip them to preserve manual customizations.

## Class Hierarchy Specification
| Layer | Component | Package Name Pattern | File Name Pattern | Type | Logic Content |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Model | Base | {PackageName}.model.base | Base{EntityName}.java | interface | Contract provided by base attributes expressed as Getters/Setters.
| | Extension | {PackageName}.model | {EntityName}.java | interface | Contract for any additional custom attributes expressed as Getters/Setters 
| Entity | Base | {PackageName}.entity.base | Base{EntityName}Entity.java | interface | Contract provided by base Getters/Setters.
| | Base | {PackageName}.entity.base | Base{EntityName}EntityImpl.java | abstract | Base fields, JPA Annotations, Getters/Setters.
| | Extension | {PackageName}.entity | {EntityName}Entity.java | interface | Contract for Custom fields, Business methods, Validation logic.
| | Extension | {PackageName}.entity | {EntityName}EntityImpl.java | concrete | Custom Fields, JPA Annotations,Business methods, Validation logic.
| Persistence | Base | {PackageName}.persistence.base | Base{EntityName}Persistence.java | interface | JPA Repository definition.
| | Extension | {PackageName}.persistence | {EntityName}Persistence.java | interface | Custom persistence methods.
| DTO | Base | {PackageName}.dto.base | Base{EntityName}DTO.java | interface | Contract provided by base Getters/Setters.
| | Base | {PackageName}.dto.base | Base{EntityName}DTOImpl.java | abstract | Base fields, Getters/Setters.
| | Extension | {PackageName}.dto | {EntityName}DTO.java | interface | Contract for Custom fields
| | Extension | {PackageName}.dto | {EntityName}DTOImpl.java | concrete | Custom Fields
| Service | Base | {PackageName}.service.base | Base{EntityName}Service.java | interface | Contract provided by base service.
| | Base | {PackageName}.service.base | Base{EntityName}ServiceImpl.java | abstract | CRUD orchestration, Transactional logic.
| | Extension | {PackageName}.service | {EntityName}Service.java | interface | Contract provided by custom service impl.
| | Extension | {PackageName}.service | {EntityName}ServiceImpl.java | concrete | Custom service methods/Complex workflows.
| API | Base | {PackageName}.api.{Visibility}.base | Base{EntityName}{Visibility}Rest.java | interface | Contract for base CRUD API
| | Base | {PackageName}.api.{Visibility}.base | Base{EntityName}{Visibility}RestImpl.java | abstract | Base CRUD API
| | Extension | {PackageName}.api.{Visibility} | {EntityName}{Visibility}Rest.java | interface | Contract provided by custom REST API
| | Extention | {PackageName}.api.{Visibility} | {EntityName}{Visibility}RestImpl.java | concrete | Custom REST API
