library angular.core.annotation;

import "package:di/di.dart" show Visibility, Injector;

/**
 * An annotation when applied to a class indicates that the class (service) will
 * be instantiated by di injector.
 */
class NgInjectableService {
  const NgInjectableService();
}

abstract class NgAnnotation {
  /**
   * CSS selector which will trigger this component/directive.
   * CSS Selectors are limited to a single element and can contain:
   *
   * * `element-name` limit to a given element name.
   * * `.class` limit to an element with a given class.
   * * `[attribute]` limit to an element with a given attribute name.
   * * `[attribute=value]` limit to an element with a given attribute and value.
   * * `:contains(/abc/)` limit to an element which contains the given text.
   *
   *
   * Example: `input[type=checkbox][ng-model]`
   */
  final String selector;

  /**
   * Specifies the compiler action to be taken on the child nodes of the
   * element which this currently being compiled.  The values are:
   *
   * * [COMPILE_CHILDREN] (*default*)
   * * [TRANSCLUDE_CHILDREN]
   * * [IGNORE_CHILDREN]
   */
  final String children;

  /**
   * Compile the child nodes of the element.  This is the default.
   */
  static const String COMPILE_CHILDREN = 'compile';
  /**
   * Compile the child nodes for transclusion and makes available
   * [BoundViewFactory], [ViewFactory] and [ViewPort] for injection.
   */
  static const String TRANSCLUDE_CHILDREN = 'transclude';
  /**
   * Do not compile/visit the child nodes.  Angular markup on descendant nodes
   * will not be processed.
   */
  static const String IGNORE_CHILDREN = 'ignore';

  /**
   * A directive/component controller class can be injected into other
   * directives/components. This attribute controls whether the
   * controller is available to others.
   *
   * * `local` [NgDirective.LOCAL_VISIBILITY] - the controller can be injected
   *   into other directives / components on the same DOM element.
   * * `children` [NgDirective.CHILDREN_VISIBILITY] - the controller can be
   *   injected into other directives / components on the same or child DOM
   *   elements.
   * * `direct_children` [NgDirective.DIRECT_CHILDREN_VISIBILITY] - the
   *   controller can be injected into other directives / components on the
   *   direct children of the current DOM element.
   */
  final Visibility visibility;

  /**
   * A directive/component class can publish types by using a factory
   * function to generate a module. The module is then installed into
   * the injector at that element. Any types declared in the module then
   * become available for injection.
   *
   * Example:
   *
   *     @NgDirective(
   *       selector: '[foo]',
   *       module: Foo.moduleFactory)
   *     class Foo {
   *       static moduleFactory() => new Module()
   *         ..type(SomeTypeA, visibility: NgDirective.LOCAL_VISIBILITY);
   *     }
   *
   * When specifying types, factories or values in the module, notice that
   * `Visibility` maps to:
   *  * [NgDirective.LOCAL_VISIBILITY]
   *  * [NgDirective.CHILDREN_VISIBILITY]
   *  * [NgDirective.DIRECT_CHILDREN_VISIBILITY]
   */
  final Function module;

  /**
   * Use map to define the mapping of  DOM attributes to fields.
   * The map's key is the DOM attribute name (DOM attribute is in dash-case).
   * The Map's value consists of a mode prefix followed by an expression.
   * The destination expression will be evaluated against the instance of the
   * directive / component class.
   *
   * * `@` - Map the DOM attribute string. The attribute string will be taken
   *   literally or interpolated if it contains binding {{}} systax and assigned
   *   to the expression. (cost: 0 watches)
   *
   * * `=>` - Treat the DOM attribute value as an expression. Set up a watch,
   *   which will read the expression in the attribute and assign the value
   *   to destination expression. (cost: 1 watch)
   *
   * * `<=>` - Treat the DOM attribute value as an expression. Set up a watch
   *   on both outside as well as component scope to keep the src and
   *   destination in sync. (cost: 2 watches)
   *
   * * `=>!` - Treat the DOM attribute value as an expression. Set up a one time
   *   watch on expression. Once the expression turns truthy it will no longer
   *   update. (cost: 1 watches until not null, then 0 watches)
   *
   * * `&` - Treat the DOM attribute value as an expression. Assign a closure
   *   function into the field. This allows the component to control
   *   the invocation of the closure. This is useful for passing
   *   expressions into controllers which act like callbacks. (cost: 0 watches)
   *
   * Example:
   *
   *     <my-component title="Hello {{username}}"
   *                   selection="selectedItem"
   *                   on-selection-change="doSomething()">
   *
   *     @NgComponent(
   *       selector: 'my-component'
   *       map: const {
   *         'title': '@title',
   *         'selection': '<=>currentItem',
   *         'on-selection-change': '&onChange'})
   *     class MyComponent {
   *       String title;
   *       var currentItem;
   *       ParsedFn onChange;
   *     }
   *
   *  The above example shows how all three mapping modes are used.
   *
   *  * `@title` maps the title DOM attribute to the controller `title`
   *    field. Notice that this maps the content of the attribute, which
   *    means that it can be used with `{{}}` interpolation.
   *
   *  * `<=>currentItem` maps the expression (in this case the `selectedItem`
   *    in the current scope into the `currentItem` in the controller. Notice
   *    that mapping is bi-directional. A change either in field or on
   *    parent scope will result in change to the other.
   *
   *  * `&onChange` maps the expression into the controller `onChange`
   *    field. The result of mapping is a callable function which can be
   *    invoked at any time by the controller. The invocation of the
   *    callable function will result in the expression `doSomething()` to
   *    be executed in the parent context.
   */
  final Map<String, String> map;

  /**
   * Use the list to specify expressions containing attributes which are not
   * included under [map] with '=' or '@' specification.
   */
  final List<String> exportExpressionAttrs;

  /**
   * Use the list to specify expressions which are evaluated dynamically
   * (ex. via [Scope.eval]) and are otherwise not statically discoverable.
   */
  final List<String> exportExpressions;

  const NgAnnotation({
    this.selector,
    this.children: NgAnnotation.COMPILE_CHILDREN,
    this.visibility: NgDirective.LOCAL_VISIBILITY,
    this.module,
    this.map: const {},
    this.exportExpressions: const [],
    this.exportExpressionAttrs: const []
  });

  toString() => selector;
  get hashCode => selector.hashCode;
  operator==(other) =>
      other is NgAnnotation && selector == other.selector;

  NgAnnotation cloneWithNewMap(newMap);
}


bool _applyAuthorStylesDeprecationWarningPrinted = false;
bool _resetStyleInheritanceDeprecationWarningPrinted = false;

/**
 * Meta-data marker placed on a class which should act as a controller for the
 * component. Angular components are a light-weight version of web-components.
 * Angular components use shadow-DOM for rendering their templates.
 *
 * Angular components are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Components
 * can also ask for other components or directives declared on the DOM element.
 *
 * Components can implement [NgAttachAware], [NgDetachAware],
 * [NgShadowRootAware] and declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 * * `onShadowRoot(ShadowRoot shadowRoot)` - Called when [ShadowRoot] is loaded.
 */
class NgComponent extends NgAnnotation {
  /**
   * Inlined HTML template for the component.
   */
  final String template;

  /**
   * A URL to HTML template. This will be loaded asynchronously and
   * cached for future component instances.
   */
  final String templateUrl;

  /**
   * A list of CSS URLs to load into the shadow DOM.
   */
  final _cssUrls;

  /**
   * Set the shadow root applyAuthorStyles property. See shadow-DOM
   * documentation for further details.
   *
   * This feature will be removed in Chrome 35.
   */
  @deprecated
  bool get applyAuthorStyles {
    if (!_applyAuthorStylesDeprecationWarningPrinted && _applyAuthorStyles == true) {
      print("WARNING applyAuthorStyles is deprecated in component $selector");
      _applyAuthorStylesDeprecationWarningPrinted = true;
    }
    return _applyAuthorStyles;
  }
  final bool _applyAuthorStyles;

  /**
   * Set the shadow root resetStyleInheritance property. See shadow-DOM
   * documentation for further details.
   *
   * This feature will be removed in Chrome 35.
   */
  @deprecated
  bool get resetStyleInheritance {
    if (!_resetStyleInheritanceDeprecationWarningPrinted && _resetStyleInheritance == true) {
      print("WARNING resetStyleInheritance is deprecated in component $selector");
      _resetStyleInheritanceDeprecationWarningPrinted = true;
    }
    return _resetStyleInheritance;
  }
  final bool _resetStyleInheritance;

  /**
   * An expression under which the component's controller instance will be
   * published into. This allows the expressions in the template to be referring
   * to controller instance and its properties.
   */
  final String publishAs;

  const NgComponent({
    this.template,
    this.templateUrl,
    cssUrl,
    applyAuthorStyles,
    resetStyleInheritance,
    this.publishAs,
    module,
    map,
    selector,
    visibility,
    exportExpressions,
    exportExpressionAttrs})
      : _cssUrls = cssUrl,
        _applyAuthorStyles = applyAuthorStyles,
        _resetStyleInheritance = resetStyleInheritance,
        super(selector: selector,
             children: NgAnnotation.COMPILE_CHILDREN,
             visibility: visibility,
             map: map,
             module: module,
             exportExpressions: exportExpressions,
             exportExpressionAttrs: exportExpressionAttrs);

  List<String> get cssUrls => _cssUrls == null ?
      const [] :
      _cssUrls is List ?  _cssUrls : [_cssUrls];

  NgAnnotation cloneWithNewMap(newMap) =>
      new NgComponent(
          template: template,
          templateUrl: templateUrl,
          cssUrl: cssUrls,
          applyAuthorStyles: applyAuthorStyles,
          resetStyleInheritance: resetStyleInheritance,
          publishAs: publishAs,
          map: newMap,
          module: module,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs);
}

RegExp _ATTR_NAME = new RegExp(r'\[([^\]]+)\]$');

const String SHADOW_DOM_INJECTOR_NAME = 'SHADOW_INJECTOR';

_skipShadow(Injector injector)
    => injector.name == SHADOW_DOM_INJECTOR_NAME ? injector.parent : injector;

_localVisibility (Injector requesting, Injector defining)
    => identical(_skipShadow(requesting), defining);

_directChildrenVisibility(Injector requesting, Injector defining) {
  requesting = _skipShadow(requesting);
  return identical(requesting.parent, defining) || _localVisibility(requesting, defining);
}

/**
 * Meta-data marker placed on a class which should act as a directive.
 *
 * Angular directives are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Directives
 * can also ask for other components or directives declared on the DOM element.
 *
 * Directives can implement [NgAttachAware], [NgDetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 */
class NgDirective extends NgAnnotation {
  static const Visibility LOCAL_VISIBILITY = _localVisibility;
  static const Visibility CHILDREN_VISIBILITY = null;
  static const Visibility DIRECT_CHILDREN_VISIBILITY = _directChildrenVisibility;

  const NgDirective({children: NgAnnotation.COMPILE_CHILDREN,
                    map,
                    selector,
                    module,
                    visibility,
                    exportExpressions,
                    exportExpressionAttrs})
      : super(selector: selector,
              children: children,
              visibility: visibility,
              map: map,
              module: module,
              exportExpressions: exportExpressions,
              exportExpressionAttrs: exportExpressionAttrs);

  NgAnnotation cloneWithNewMap(newMap) =>
      new NgDirective(
          children: children,
          map: newMap,
          module: module,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs);
}

/**
 * Meta-data marker placed on a class which should act as a controller for your
 * application.
 *
 * Controllers are essentially [NgDirective]s with few key differences:
 *
 * * Controllers create a new scope at the element.
 * * Controllers should not do any DOM manipulation.
 * * Controllers are meant for application-logic
 *   (rather then DOM monipulation logic which directives are meant for.)
 *
 * Controllers can implement [NgAttachAware], [NgDetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 */
class NgController extends NgDirective {
  static const String LOCAL_VISIBILITY = 'local';
  static const String CHILDREN_VISIBILITY = 'children';
  static const String DIRECT_CHILDREN_VISIBILITY = 'direct_children';

  /**
   * An expression under which the controller instance will be published into.
   * This allows the expressions in the template to be referring to controller
   * instance and its properties.
   */
  final String publishAs;

  const NgController({
                    children: NgAnnotation.COMPILE_CHILDREN,
                    this.publishAs,
                    map,
                    module,
                    selector,
                    visibility,
                    exportExpressions,
                    exportExpressionAttrs
                    })
      : super(selector: selector,
              children: children,
              visibility: visibility,
              map: map,
              module: module,
              exportExpressions: exportExpressions,
              exportExpressionAttrs: exportExpressionAttrs);

  NgAnnotation cloneWithNewMap(newMap) =>
      new NgController(
          children: children,
          publishAs: publishAs,
          module: module,
          map: newMap,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs);
}

abstract class AttrFieldAnnotation {
  final String attrName;
  const AttrFieldAnnotation(this.attrName);
  String get mappingSpec;
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a string, equivalent
 * to `@` specification.
 */
class NgAttr extends AttrFieldAnnotation {
  final mappingSpec = '@';
  const NgAttr(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a one-way expression, equivalent
 * to `=>` specification.
 */
class NgOneWay extends AttrFieldAnnotation {
  final mappingSpec = '=>';
  const NgOneWay(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a one time one-way expression,
 * equivalent to `=>!` specification.
 */
class NgOneWayOneTime extends AttrFieldAnnotation {
  final mappingSpec = '=>!';
  const NgOneWayOneTime(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a two-way expression,
 * equivalent to `<=>` specification.
 */
class NgTwoWay extends AttrFieldAnnotation {
  final mappingSpec = '<=>';
  const NgTwoWay(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a callback expression,
 * equivalent to `&` specification.
 */
class NgCallback extends AttrFieldAnnotation {
  final mappingSpec = '&';
  const NgCallback(String attrName) : super(attrName);
}

/**
 * Implementing directives or components [attach] method will be called when
 * the next scope digest occurs after component instantiation. It is guaranteed
 * that when [attach] is invoked, that all attribute mappings have already
 * been processed.
 */
abstract class NgAttachAware {
  void attach();
}

/**
 * Implementing directives or components [detach] method will be called when
 * the associated scope is destroyed.
 */
abstract class NgDetachAware {
  void detach();
}


/**
 * Use @[NgFilter] annotation to register a new filter. A filter is a class
 * with a [call] method (a callable function).
 *
 * Usage:
 *
 *     // Declaration
 *     @NgFilter(name:'myFilter')
 *     class MyFilter {
 *       call(valueToFilter, optArg1, optArg2) {
 *          return ...;
 *       }
 *     }
 *
 *
 *     // Registration
 *     var module = ...;
 *     module.type(MyFilter);
 *
 *
 *     <!-- Usage -->
 *     <span>{{something | myFilter:arg1:arg2}}</span>
 */
class NgFilter {
  final String name;

  const NgFilter({this.name});

  int get hashCode => name.hashCode;
  bool operator==(other) => name == other.name;

  toString() => 'NgFilter: $name';
}
