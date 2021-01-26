---
layout: page
title: Angular
---

## Quickstart for Fedora

Install `nodejs` from dnf. Then:

    $ npm install @angular/cli
    $ npx ng new my-app-name

Optionally then install Angular Language support for VS Code.

## Concepts

- **Components** - reusable parts for the application, where each component has its own styling and business logic. The root `app` component holds the entire application.
- **Modules** - bundle components into packages, e.g. `AppModule`
- **Event binding** - binding to the events of an HTML attribute, e.g. `<button (click)="myMethod()">`
- **String interpolation vs property binding**
    - string interpolation inserts values using `{{ myvar }}` syntax
    - property binding - e.g. `[myproperty]="someVar"` - binds a property on the object to a value. When using with component tags (`<my-app-editor>`) it is kind of like invoking the component and setting the given property to the given value.
    - event binding - e.g. `<my-component (eventName)="something"/>` will listen to the given `eventName`
- **Local reference** - e.g. `#myVar`
- **Directives**
  - attribute directives - look like a normal HTML attribute on an element. Can only change properties of an element, not destroy it.
  - structural directives - looks like an attribute but with a leading `*`. Can also change the structure of the DOM, e.g. if the directive is equal to false, then the given element will be removed from the DOM, e.g. `*ngFor="let myVar of myVars"`. Can't have more than 1 structural directive on an element.
    - e.g. `<div *ngIf="showStuff">`

### Model

An example model:

```ts
export class Recipe {
    public name: string;
    public description: string;

    constructor(name: string, description: string) {
        this.name = name;
        this.description = description;
    }
}
```

## Components

A component is identified in Angular using the `@Component` decorator (annotation):

- selector is the HTML element that will be used to reference this component
- `templateUrl` is the path to the HTML file for this component

A component needs to be added into the module in which it's contained, e.g. add it to `app.module.ts` under `declarations`.

## Cookbook

### Event Binding on click

In the component's HTML file, generate an event when a link is pressed:

```html
<a href="#" (click)="onSelect('recipe')">Recipes</a>
```

Then in the component typescript file, define the `EventEmitter` and the method that will be invoked on click. This will **emit** the event:

```ts
// Output allows this to be listened to from the parent component
@Output() featureSelected = new EventEmitter<string>();

// Emits an event when one of the navbar links is clicked
// Event content is the string of the link name
onSelect(feature: string) {
  this.featureSelected.emit(feature);
}
```

In the component receiving the event, we **bind to the `featureSelected` event**:

```html
<app-header (featureSelected)="onNavigate($event)"></app-header>
```

And then implement the method that will be invoked when the event occurs - this will set a field _loadedFeature_:

```ts
onNavigate(feature: string) {
  this.loadedFeature = feature;
}
```

Finally we can use this field in our HTML, e.g. to show/hide a relevant section:

```html
<app-recipes *ngIf="loadedFeature === 'recipe'"></app-recipes>
<app-shopping-list *ngIf="loadedFeature !== 'recipe'"></app-shopping-list>
```
