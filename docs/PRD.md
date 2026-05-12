# Requirements: Entity/Service Generator

## Core System Goals
- **G.1:** Generate consistent Java/Spring/JPA source code from XML definitions.
- **G.2:** Support multi-tenant data isolation at the schema/service level.
- **G.3:** Automate the creation of CRUD API layers (Internal/External).

## Functional Requirements
| ID | Requirement | Description |
| :--- | :--- | :--- |
| **FR.1** | **Identity Management** | Support configurable key types (UUID, Long, Int, String). |
| **FR.2** | **Relationship Mapping** | Handle JPA-style cardinality (1:1, 1:N, N:M) and directionality. |
| **FR.3** | **Search Abstraction** | Generate "Finders" based on specific attribute sets. |
| **FR.4** | **Multi-tenancy** | Inject tenant-discriminator logic into service and entity layers. |
| **FR.5** | **Interface-First Architecture** | Every generated component (Service, Repository/Persistence, API) must be defined by a Java Interface.
| **FR.5.1** | **Consumer Decoupling** | All internal and external service injections must use the Interface type, never the implementation class.
| **FR.6** | **Generation Gap Pattern** | All generated layers (Entity, Persistence, Service, API) must use an inheritance-based "Base" and "Impl" split.
| **FR.6.1** | **Base Layer Protection** | The Base classes are "volatile" and will be overwritten on every generation. They must contain all logic derived from the service.xml.
| **FR.6.2** | **Customization Layer** | The Impl subclasses are "stable" and created only if they do not exist. Users provide custom logic, overrides, and manual extensions here.
