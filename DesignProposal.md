# Steel Design

## ECS
Really, there is only one choice when it comes to developing a performant game engine.
This design pattern is [ECS](https://en.wikipedia.org/wiki/Entity_component_system). ECS is well-documented and understood in the game development community. If ECS is properly implemented, it is also easily parallelizable. Each System can function as if it is the only System in existence, allowing full CPU utilization for high-performance gaming applications.

### Component
A Component is the main way in which developers will interact with the game engine. Components are essentially buckets of data that are used to define behaviors of game elements, as well as being used by the game engine to determine how Components should be rendered.

### Entity
An Entity acts as an ID, acting as a parent to Components. An instance of a Component is registered with an Entity, and an Entity can have an arbitrary number of Components registered to it. If an Entity is deleted, all registered Components are also removed from the game engine Systems.

### System
In the common ECS implementation, the developer should never see the System. When a Component is registered to an Entity, the engine will attach the Component to the relevant Systems and those Systems actually perform operations using the data from the Components. Systems are the objects which render, do physics simulation, and execute any necessary logic. Systems have ownership over the Components and should manage the Component object lifetimes.

## Developer exposure to ECS

### Custom Behavior Components
Most ECS designs follow this model. There is an inheritable parent class representing all Behaviors, and Custom Components inherit from this parent type and define their own logic. An Entity can then have an arbitrary number of Behaviors attached to it, allowing separation of code.

#### Pros
- Hides the System from developers.
- Separation of developer code into multiple classes on the same Entity provides developer autonomy.
- Common design pattern with lots of available resources.

#### Cons
- Separation of developer code into multiple classes on the same Entity can result in a spider web of references between Behaviors and the nodes they need to reference. This is the choice of the developer and is not the inevitable end result of this design.
- Execution of developer code in the Component is less cache-friendly than all of the logic being present in System.

### Single Inheritance Custom Behaviors
Single inheritance is very similar to the first method of Custom Behavior Components. The main differentiation is that Single Inheritance extends from a node type and can only be extended once per Node in the Scene. The main example of Single Inheritance is the Godot engine. If you want to make a character move, create a KinematicBodyComponent, then extend a script from the KinematicBodyComponent and attach it to the node.

#### Pros
- Hides the System from developers.
- Simple implementation in the game engine for enabling custom user logic.

#### Cons
- Prevents separation of code for single nodes into multiple objects, limiting developer choice.
- Execution of developer code in the Component is less cache-friendly than all of the logic being present in System.

### Create Custom Systems
Some ECS designs, like that of [Amethyst](https://github.com/amethyst/amethyst) require that any extra logic be implemented as a System by the developer and registering Component types to the new System.

#### Pros
- Separates all logic from Components into Systems.
- Cache-friendly due to Systems acting upon Components, rather than custom Components acting on their own.

#### Cons
- Makes the System visible to developers.
- Any unique piece of logic must be made into a System. This can be pretty non-intuitive to a developer up front, as it requires a true understanding of Components as bags of data.
- A System can only act on components of an Entity which contain exactly the "subscribed" Component types. Removing a Component from an Entity will then in turn invalidate the Entity's Components from executing in the previousl subscribed Systems.
- Lot of mental juggling to manage Systems.

## Proposal
Regardless of the method of developer exposure, the basics of the ECS design will be mostly the same for Steel under ECS.

### 2D Render System
Rendering of all 2D components is handled by the 2D Render System. This includes simple Sprites and Text. This 2D Render System could be optional if the 2D elements are rendered to a 3D quad and handled by the 3D Render System. Separating the 2D rendering from the 3D rendering would allow more particular optimization of 2D and 3D rendering pipelines. Systems should generally manage the smallest subset of Components as is logically possible. One could argue that Sprites and Text should get their own render systems, and that is a valid option for the design. Text rendering often has many caveats when compared to rendering Sprites. Scaling text without loading new font sizes can make text look pixelated and ugly. A solution such as TextMeshPro can make Text look beautiful at all sizes, but also presents a good argument for separating Text rendering from Sprite rendering into new 2D systems.

### 3D Render System
Same as with 2D system. Would be nice to separate the rendering pipelines for 2D and 3D components for optimization reasons. All 3D components come down to lists of vertices and how they create meshes via triables, so there is no smaller subset of components within the 3D system.

### Audio System
The Audio system would manage currently running and paused audio. Audio often runs on a background thread away from the main loop, so a system should be dedicated to managing when Audio should be running, paused, or completed.

### Physics System
Physics simulation is a whole beast in and of itself. Physics simulations are often so intense that if they are not run on a separate thread, even somewhat simple physics simulations can hang the game loop. Each Physics System would represent a Physics "world". A physics world is a set of physical objects which can interact with one another. Specializing the Physics System into both a 2D and 3D variant is something to consider, as the performance difference between a 2D and 3D system can be quite substantial.

### Behavior System
This is only relevant for the first two ECS implementations. A Behavior System is in charge of managing the process priority and ordering of custom script executions. The Behavior System does no more than schedule and execute the hooks in custom Behavior Components.