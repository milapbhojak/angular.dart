library angular.mock.test_bed_spec;

import '../_specs.dart';

void main() {
  describe('test bed', () {
    TestBed _;
    Compiler compile;
    Injector injector;
    Scope rootScope;

    beforeEachModule((Module module) {
      module..type(MyTestBedDirective);
      return (TestBed tb) => _ = tb;
    });

    it('should allow for a scope-based compile', () {

      inject((Scope scope) {
        Scope childScope = scope.createChild({});

        _.compile('<div my-directive probe="i"></div>', scope: childScope);

        Probe probe = _.rootScope.context['i'];
        var directiveInst = probe.directive(MyTestBedDirective);

        childScope.destroy();

        expect(directiveInst.destroyed).toBe(true);
      });
    });

  });
}

@NgDirective(selector: '[my-directive]')
class MyTestBedDirective {
  bool destroyed = false;

  MyTestBedDirective(Scope scope) {
    scope.on(ScopeEvent.DESTROY).listen((_) {
      destroyed = true;
    });
  }
}
