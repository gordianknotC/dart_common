import 'dart:async';
import 'package:dart_common/common.dart';
import 'package:test/test.dart';


void main() {
	String va1 = "1.0.1";
	String va2=  "1.0.2";
	String va3 = "0.9.8";
	
	String vb1 = "2.0.1";
	String vb2=  "2.1.2";
	String vb3 = "1.9.8+1";
	String vb4 = "1.9.8+12";
	
	group('群組測試', () {
		/// [setUpAll]
		/// 用於初始化 group test 所需的參數
		setUpAll((){
		});
		
		test('測試 - va1 ~ va3 parsing', (){
			expect(PackageNumber(va1), greaterThan(PackageNumber(va3)));
			expect(PackageNumber(va2), greaterThan(PackageNumber(va3)));
			expect(PackageNumber(va3), lessThan(PackageNumber(va2)));
			expect(PackageNumber(va3), lessThan(PackageNumber(va1)));
			
			expect(PackageNumber(va1), equals(PackageNumber(va1)));
		});
		
		test('測試 - vb1 ~ vb4 parsing', (){
			expect(PackageNumber(vb1), greaterThan(PackageNumber(vb3)));
			expect(PackageNumber(vb1), greaterThan(PackageNumber(vb4)));
			expect(PackageNumber(vb2), greaterThan(PackageNumber(vb1)));
			expect(PackageNumber(vb2), greaterThan(PackageNumber(vb3)));
			expect(PackageNumber(vb2), greaterThan(PackageNumber(vb4)));
			expect(PackageNumber(vb4), greaterThan(PackageNumber(vb3)));
		});
		
		test('混合測試', (){
			expect(PackageNumber(vb2), greaterThan(PackageNumber(va1)));
			expect(PackageNumber(vb4), greaterThan(PackageNumber(va2)));
		});
		
	});
}
