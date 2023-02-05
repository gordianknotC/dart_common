import 'package:dart_common/dart_common.dart';
import 'package:test/test.dart';


void main(){
	group('RetryFetcher base tests', (){
		test('expect 5 retries', ()async {
			int retries = 0;
			final r = RetryFetcher(fetcher: () async {
					retries ++;
					if (retries < 5){
						print('retries $retries with failed response');
						throw Exception('error throws');
					}
					return Future.value('');
			}, maxRettries: 5, duration: Duration(seconds: 1));
			r.fetch();
			for (var i = 0; i < 5; ++i) {
				print(i);
				await Future.delayed(r.duration);
			}
			expect(retries, equals(r.retries));
		});
		
		test('expect 2 retries, one failed the other success', () async {
			int retries = 0;
			final r = RetryFetcher(fetcher: () async {
				retries ++;
				if (retries == 2){
					print('retries $retries with sucessfully response');
					return Future.value('Success');
				}
				if (retries < 5){
					print('retries $retries with failed response');
					throw Exception('error throws');
				}
			}, maxRettries: 5, duration: Duration(seconds: 1));
			r.fetch();
			for (var i = 0; i < 3; ++i) {
				print(i);
				await Future.delayed(r.duration);
			}
			expect(retries, equals(2));
		});
		
		
	});
}
