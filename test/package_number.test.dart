import 'package:dart_common/dart_common.dart';
import 'package:test/test.dart';

class Helper {
	void expectParsingProperly(PackageNumber inst, int major, int minor, int maintain, [int patch = 0]){
		expect(inst.majorNumber, equals(major));
		expect(inst.minorNumber, equals(minor));
		expect(inst.maintainNumber, equals(maintain));
		expect(inst.patchNumber, equals(patch));
	}

	void expectGreater(PackageNumber a, List<PackageNumber> rest){
		for (var i = 0; i < rest.length; ++i) {
      var o = rest[i];
      expect(a, greaterThan(o), reason: 'greater than package number ${o.versionString}');
    }
	}

	void expectNotEqual(PackageNumber a, List<PackageNumber> rest){
		for (var i = 0; i < rest.length; ++i) {
			var o = rest[i];
			expect(a, isNot(equals(o)), reason: 'not equal as package number ${o.versionString}');
		}

	}

	void expectLesser(PackageNumber a, List<PackageNumber> rest){
		for (var i = 0; i < rest.length; ++i) {
			var o = rest[i];
			expect(a, lessThan(o), reason: 'lesser than package number ${o.versionString}');
		}
	}
}

extension ListExtention<T> on List<T>{
	Iterable<T> except(T b){
		return where((_)=> _ != b);
	}
}

void main() {
	group('PackageNumber tests', () {
		final Helper h = Helper();
		final String va1 = "1.0.1";
		final String va2=  "1.0.2";
		final String va3 = "0.9.8";
		//
		final String vb1 = "2.0.1";
		final String vb2=  "2.1.2";
		final String vb3 = "1.9.8";
		final String vb4 = "1.9.8+1";
		final String vb5 = "1.9.8+12";
		//
		final pva1 = PackageNumber(va1);
		final pva2 = PackageNumber(va2);
		final pva3 = PackageNumber(va3);
		final pvb1 = PackageNumber(vb1);
		final pvb2 = PackageNumber(vb2);
		final pvb3 = PackageNumber(vb3);
		final pvb5 = PackageNumber(vb5);
		final all = [pva1, pva2, pva3, pvb1, pvb2, pvb3, pvb5];
		setUpAll((){
		});

		test('parsing package number', (){
			h.expectParsingProperly(pva1, 1, 0, 1);
			h.expectParsingProperly(pva3, 0, 9, 8);
			h.expectParsingProperly(pvb3, 1, 9, 8);
			h.expectParsingProperly(pvb5, 1, 9, 8, 12);
		});

		test('expect not equal...', (){
			for (var i = 0; i < all.length; ++i) {
        var elt = all[i];
        h.expectNotEqual(elt, all.except(elt).toList());
      }
    });

		test('expect lesser', (){
			h.expectLesser(pva1, [pva2, pvb1, pvb2, pvb3, pvb5]);
			h.expectLesser(pva2, [      pvb1, pvb2, pvb3, pvb5]);
			h.expectLesser(pva3, [pva1, pva2, pvb1, pvb2, pvb3, pvb5]);
			//
			h.expectLesser(pvb1, [pvb2]);
			//h.expectLesser(pvb2, []);
			h.expectLesser(pvb3, [pvb1, pvb2, pvb5]);
			h.expectLesser(pvb5, [pvb1, pvb2]);
		});

		test('expect greater', (){
			h.expectGreater(pva1, [pva3]);
			h.expectGreater(pva2, [pva1, pva3]);
			//h.expectGreater(pva3, []);
			//
			h.expectGreater(pvb1, [pva1, pva2, pva3, pvb3, pvb5]);
			h.expectGreater(pvb2, [pva1, pva2, pva3, pvb1, pvb3, pvb5]);
			h.expectGreater(pvb3, [pva1, pva2, pva3]);
			h.expectGreater(pvb5, [pva1, pva2, pva3, pvb3]);
		});
	});
}
