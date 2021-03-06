part of angular.core.dom_internal;

List<dom.Node> cloneElements(elements) {
  return elements.map((el) => el.clone(true)).toList();
}

typedef ApplyMapping(NodeAttrs attrs, Scope scope, Object dst,
                     FilterMap filters, notify());

class DirectiveRef {
  final dom.Node element;
  final Type type;
  final NgAnnotation annotation;
  final String value;
  final mappings = new List<ApplyMapping>();

  DirectiveRef(this.element, this.type, this.annotation, [ this.value ]);

  String toString() {
    var html = element is dom.Element
        ? (element as dom.Element).outerHtml
        : element.nodeValue;
    return '{ element: $html, selector: ${annotation.selector}, value: $value, '
           'type: $type }';
  }
}

/**
 * Creates a child injector that allows loading new directives, filters and
 * services from the provided modules.
 */
Injector forceNewDirectivesAndFilters(Injector injector, List<Module> modules) {
  modules.add(new Module()
      ..factory(Scope, (i) {
        var scope = i.parent.get(Scope);
        return scope.createChild(new PrototypeMap(scope.context));
      }));

  return injector.createChild(modules,
      forceNewInstances: [DirectiveMap, FilterMap]);
}
