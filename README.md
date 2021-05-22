## ui component module

`uicomponent` is a module containing ui component:

* `colorbox`
* `double_listbox()`
* `toolbar()`


## Comments

A composable widget is a concept that provides the call of some connected widgets in the same manner as a regular widget, that is, by calling a sort of constructor function: `ui.button(...)` for a widget `uic.tabs(...)` (where `uic` is the alias of the imported module `uicomponent`) for a composable widget.

Technically, the constructor of a composable widget returns a container (generally a layout, `ui.Stack` or `ui.CanvasLayout`).

A `ui component` is more specifically the struc(ture) gathering the container of the composable widget and all the elements of this container that needs to be connected together.

The container and all the elements of a composable widget have their field `component` connected to the `ui component` at the creation of the composable widget (after the constructor call). They can then access the `ui component` by calling the facility function `component_<composable widget>(<element>)`.

In order to provide some useful methods for the composable widget, methods for the associated `ui component` are proposed by the developer.

When a user defines its own callback function for an element of a composable widget.

As a final remark, a composable widget can be used as an element of another composable widget whenever the associated `ui component` has the field `component`. 

Composable widgets are then self-content and reusable that expresses modularity.