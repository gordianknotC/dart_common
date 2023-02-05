import 'dart:math';
import 'package:colorize/colorize.dart' show Colorize, Styles;


///
/// void main() {
//  	print('hello world overflow 19'.overflowLeft());
//  	print('hello world overflow 19'.overflowRight());
//  	print('hello world overflow 19'.overflowCenter());
//  }
///
/// output:
/// 	...rld overflow 19
/// 	hello world ove...
///		hello wo...rflow 19
///
extension StringExtensionExtension on String{
	String overflowLeft({int maxLength = 18}){
		if (length > maxLength){
			return "...${this.substring(3 + length - maxLength, length)}";
		}
		return this;
	}
	String overflowRight({int maxLength = 18}){
		if (length > maxLength){
			return "${this.substring(0, maxLength - 3)}...";
		}
		return this;

	}
	String overflowCenter({int maxLength = 18}){
		if (length > maxLength){
			final stripLength = min(length, maxLength) ~/ 2 - 1;
			final ls = this.substring(0, stripLength);
			final rs = this.substring(length - stripLength, length);
			return "$ls...$rs";
		}
		return this;
	}
}

///
/// clamp value within L, R
///
T clamp<T extends num>(T source, {required T L, required T R}){
	return min(max(source, L), R);
}

















