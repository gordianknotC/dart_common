
import 'dart:async';

import 'package:dart_common/dart_common.dart';
import 'package:test/test.dart';



class Temp with CrossingDateWidget{
	int counterA = 0;
	int counterB = 0;
	void onCrossingDateOccursA(){
		counterA ++;
	}
	
	void onCrossingDateOccursB(){
		counterB ++;
	}
}

void main(){
	final matchId = 639711;
	final temp = Temp();
	final now = DateTimeExtension.envNow();
	final day1 = now.subtract(Duration(days: 1));
	final day2 = now.subtract(Duration(days: 2));
	
	Future waitOneSecond() async {
		await Future.delayed(Duration(milliseconds: 1020));
		print(temp.crossingDateDeteector.getTImer().tick);
	}
	group('timer tests for LeagueMatchInPlayScoreService', (){
		setUpAll((){
			/// duplicated here is intended;
			temp.addDetectee(temp.onCrossingDateOccursA);
			temp.addDetectee(temp.onCrossingDateOccursA);
			temp.addDetectee(temp.onCrossingDateOccursB);
			temp.crossingDateDeteector.updateTimer(2);
		});
		
		test('initial test', () async {
			expect(temp.crossingDateDeteector.getTImer().tick, 0);
			Timer t = Timer.periodic(Duration(seconds:1), (t){{
				print("timer: ${t.tick}");
			}});
			
			expect(temp.crossingDateDeteector.getTImer().isActive, true);
			expect(temp.counterA, 0);
			expect(temp.counterB, 0);
			expect(temp.crossingDateDeteector.instantiatedDate.day, now.day);
		});
		
		test('wait a period of time, expect everything remained the same', () async {
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			expect(temp.counterA, 0);
			expect(temp.counterB, 0);
		});
		
		test('update current time to simulate crossing date, expect crossing date occurs', () async {
			temp.crossingDateDeteector.instantiatedDate = day1;
			expect(day1.day + 1, equals(now.day));
			expect(temp.counterA, 0);
			expect(temp.counterB, 0);
			
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			
			expect(temp.counterA, 1);
			expect(temp.counterB, 1);
			
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			
			expect(temp.counterA, 1);
			expect(temp.counterB, 1);
		});
		
		test('wait a period of time, expect remained the same', () async {
			temp.crossingDateDeteector.instantiatedDate = day2;
			expect(day2.day + 2, equals(now.day));
			
			expect(temp.counterA, 1);
			expect(temp.counterB, 1);
			
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();expect(temp.counterA, 2);
			expect(temp.counterB, 2);
			
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			await waitOneSecond();
			expect(temp.counterA, 2);
			expect(temp.counterB, 2);
		});

	}, timeout: Timeout(Duration(minutes: 3)));
}
