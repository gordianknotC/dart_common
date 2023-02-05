import 'package:dart_common/src/common.dart';
import 'package:test/test.dart';


void main() {
	group('Ident tests', () {
		late Object obj1;
		late Object obj2;
		late Object o1_beforeDispose;
		late Object o2_beforeDispose;
		setUpAll((){
			obj1 = Object();
			obj2 = Object();
		});
		
		test('Ident - get', (){
			o1_beforeDispose = Ident.get(obj1);
			expect(o1_beforeDispose, equals(Ident.get(obj1)));
			
			o2_beforeDispose = Ident.get(obj2);
			expect(o2_beforeDispose, equals(Ident.get(obj2)));
			
			expect(o1_beforeDispose, isNot(equals(o2_beforeDispose)));
			final o1A = Ident.get(obj1);
			final o2A = Ident.get(obj2);
			
			expect(o1_beforeDispose, equals(o1A));
			expect(o2_beforeDispose, equals(o2A));
		});
		
		test('Ident - dispose', (){
			Ident.dispose(obj1);
			final o1_afterDispose = Ident.get(obj1);
			expect(o1_beforeDispose, isNot(equals(o1_afterDispose)));
		});
	});
}
