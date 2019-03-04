import 'package:common/src/common.log.dart';
import 'package:colorize/colorize.dart' show   Colorize, Styles;


typedef _TEndsStartsWith = bool Function(String source, String end);
typedef _TSubstring = String Function(String source, int start, int end);


final _log = Logger(name: 'common', levels: [ELevel.level3]);
final _UPPERCACE_A = 'A'.codeUnitAt(0);
final _UPPERCASE_Z = 'Z'.codeUnitAt(0);
final _LOWERCASE_A = 'a'.codeUnitAt(0);
final _LOWERCASE_Z = 'z'.codeUnitAt(0);

void tryRaise(Function expression, [Object message]) {
   try {
      try {
         expression();
      } catch (e, s) {
         _log("[AnError] $message\n$e \n$s", ELevel.error);
         rethrow;
      }
   } catch (e) {}
}

T guard<T>(T expression(), Object message, {bool raiseOnly: true, String error = 'AnError'}){
   if (raiseOnly){
      try{
         return expression();
      } catch(e, s){
         try {
            var trace = StackTrace.fromString(message);
            _log("[$error] $trace\n$e \n$s", ELevel.error);
            rethrow;
         } catch(e, s) {
            //untested: unbolock this if ...
            //rethrow;
         }
      }
   } else {
      try {
         return expression();
      } catch (e, s){
         var trace = StackTrace.fromString(message);
         throw Exception("[$error] $trace\n$e \n$s");
      }
   }
}
void raise(Object message, {String error = 'AnError'}) {
   try {
      try {
         throw(message);
      } catch (e, s) {
         _log("[$error] $message\n$e \n$s", ELevel.error);
         rethrow;
      }
   } catch (e) {}
}

String ignoreWhiteSpace(String x){
   return x.split('\n')
      .where((x) => x.trim() != '')
      .map((x) => x.trim())
      .join(' ');
}

void GP(String message, Function(String _) cb, [int level = 1]) {
   const String H = '-';
   const String S = ' ';
   final int TITLE_L = message.length;
   final int MIN_COL = TITLE_L <= 36
                       ? TITLE_L % 2 == 0
                         ? TITLE_L
                         : 36 + 1
                       : TITLE_L;
   final HEADING = (MIN_COL - TITLE_L) ~/ 2; //note: ~/2 indicates divide by 2 and transform it into int;
   final HORIZONTAL = H * MIN_COL;
   final TITLE = S * HEADING + message;
   print(HORIZONTAL);
   print(TITLE);
   print(HORIZONTAL);
   cb('\t' * level);
}

class Tuple<K, V> {
   K key;
   V value;
   
   String toString() => [key, value].toString();
   
   Tuple(this.key, [this.value]);
}

/*class Triple<K, M, V> {
   K father;
   V mother;
   M child;
   Triple(this.father, this.mother, this.child);
}*/

Map<K, V>
Dict<K, V>(List<MapEntry<K, V>> data){
   var ret = <K, V>{};
   for (var i = 0; i < data.length; ++i) {
      var d = data[i];
      ret[d.key] = d.value;
   }
   return ret;
}

class Triple<F, M, C> {
   F father;
   M mother;
   C child;

   String toString() => [father, mother, child].toString();
   
   Triple(this.father, this.mother, this.child);
}

//@formatter:off
class _singletonIS {
   bool set (Set set)             => !IS.set(set);
   bool string (String s)         => !IS.string(s);
   bool array (List<dynamic> arr) => !IS.array(arr);
   bool number (String n)         => !IS.number(n);
   bool Int (String n)            => !IS.Int(n);
   bool Null (dynamic a)          => !IS.Null(a);
   bool present(dynamic a)        => !IS.present(a);
   bool empty  (dynamic s)        => !IS.empty(s);
}

final IS = singletonIS();

class singletonIS {
   _singletonIS _not;
   get not {
      _not ??= _singletonIS();
      return _not;
   }
   bool
   empty(dynamic s) {
      if (s is Set) return s.isEmpty;
      if (s is String) return s.length <= 0;
      if (s is List) return s.length <= 0;
      return s == null || s == 0;
   }
   
   bool
   set (Set<dynamic> set) => set is Set;
   
   bool
   string (String text) => text is String;
   
   bool
   array (List<dynamic> arr) => arr is List;
   
   bool
   Null (dynamic a) => a == null;
   
   bool
   present (dynamic a) => a != null;
   

   bool
   number (dynamic text) =>
      text is String
         ? double.tryParse(text) != null
         : text is num;

   bool
   Int (dynamic text) =>
      text is String
         ? int.tryParse (text) != null
         : text is int;
   
   bool
   union<E>(List<E> master_set, List<E> sub_set) {
      return sub_set.every((sub) => master_set.any((master) => master == sub));
   }
   
   bool
   alphabetic(String w){
      return w.codeUnitAt(0) >= _UPPERCACE_A && w.codeUnitAt(0) <= _LOWERCASE_Z;
   }
   
   bool
   upperCaseChar(String w) {
      return w.codeUnitAt(0) >= _UPPERCACE_A && w.codeUnitAt(0) <= _UPPERCASE_Z;
   }

   bool
   lowerCaseChar(String w) {
      return w.codeUnitAt(0) >= _LOWERCASE_A && w.codeUnitAt(0) <= _LOWERCASE_Z;
   }

   bool
   underlineChar(String w) {
      return w == '_';
   }

   bool
   camelCase(String word) {
      var letters     = word.split('');
      var first_test  = IS.upperCaseChar(letters[0]) ? IS.upperCaseChar : IS.lowerCaseChar;
      var second_test = first_test == IS.upperCaseChar ? IS.lowerCaseChar : IS.upperCaseChar;
   
      if (first_test(letters[0])) {
         var altered = letters.firstWhere((l) => second_test(l), orElse: () => null);
         var idx = altered != null ? letters.indexOf(altered) : letters.length;
         if (idx < letters.length - 1) {
            if (letters.indexWhere((l) => first_test(l), idx) != -1)
               return true;
         }
         return false;
      } else {
         return false;
      }
   }
   
   bool
   snakeCase(String word){
      var letters     = word.split('');
      var first_test  = IS.alphabetic(letters[0])   ? IS.alphabetic    : IS.underlineChar;
      var second_test = first_test == IS.alphabetic ? IS.underlineChar : IS.alphabetic;
   
      if (first_test(letters[0])) {
         var altered_char = letters.firstWhere((l) => second_test(l), orElse: () => null);
         var idx          = altered_char != null
                      ? letters.indexOf(altered_char)
                      : letters.length;
         if (idx < letters.length - 1) {
            if (letters.indexWhere((l) => first_test(l), idx) != -1)
               return true;
         }
         return false;
      } else {
         return false;
      }
   }
   
   bool
   odd(int num) => num != 0 && ((num - 1) % 2 == 0);
   
   bool
   even(int num) => num != 0 && (num % 2 == 0);
   
}

String _keepIndent(String source, int level) {
   const tab = '\t';
   var ol = source.length;
   var _source = FN.stripLeft(source, tab);
   var initial_indent = ol - _source.length + level;
   if (initial_indent > 0) {
      return _source.split('\n').map((String line) {
         return (tab * initial_indent) + line;
      }).join('\n');
   }
   return source;
}

class FN {
   /*static String
   toString(dynamic source){
   
   }
   static num
   toNum(String source){
   
   }
   static int
   toInt(String source){
   
   }*/
   
   /*static List<E>
   repeat<E>({E fn(), E material ,int t}){
      if (fn != null){
         return List.generate(t, fn);
      }
      return List.filled(t, material);
   }*/
   
   
   
   static E
   range<E>(E s, [int start, int end]){
      if (E == String){
         var source = s as String;
         if (start != null && start < 0)
            start = source.length + start;
         if (end != null && end < 0)
            end = source.length + end;
         return source.substring(start, end) as E;
      }else if (E == List){
         var source = s as List;
         if (start != null && start < 0)
            start = source.length + start;
         if (end != null && end < 0)
            end = source.length + end;
         return source.sublist(start, end) as E;
      }else{
         throw Exception('Invalid type. Only support for string or list');
      }
   }
   
   static Iterable<E>
   head<E> (List<E> array){
      return array.sublist(0, array.length - 1);
   }

   static Iterable<E>
   tail<E> (List<E> array){
      return array.sublist(1, array.length);
   }
   
   static E
   last<E> (List<E> array){
      return array.last;
   }
   
   static E
   first<E> (List<E> array){
      return array.first;
   }
   
   static T
   remove<T>(List<T> array, T element) {
      return array.removeAt(array.indexOf(element));
   }
   
   static List<String>
   split(String data, String ptn, [int max = 1]){
      var d = data, pre, suf;
      var ret = <String>[];
      for (var i = 0; i < max; ++i) {
         var idx = d.indexOf(ptn);
         if (idx == -1) {
            ret.add(d);
            return ret;
         }
         pre = d.substring(0, idx);
         suf = d.substring(pre.length + 1);
         d = suf;
         ret.add(pre);
      }
      ret.add(suf);
      return ret;
   }
   
   static int
   findIndex<T>(List<T> data, bool search(T element)) {
      int result;
      FN.forEach(data, (el, [i]) {
         if (search(el)) {
            result = i;
            return true;
         }
         return false;
      });
      return result;
   }
   
   
   static int
   count<E>(List<E> A, E B, bool comp(E a, E b)){
      var counter = 0;
      var len = A.length;
      for (var ia = 0; ia < len; ++ia) {
         var ra = A[ia];
         if (comp(ra, B))
            counter ++;
      }
      return counter;
   }
   
   static List<E>
   unique<E>(List<E> A, bool filter(List<E> acc, E b)){
      List<E> result = [];
      filter ??= (acc, b) => acc.contains(b);
      for (var i = 0; i < A.length; ++i) {
         var a = A[i];
         if (filter(result, a))
            result.add(a);
      }
      return result;
   }
   
   static Iterable<List<T>>
   zip<T>(Iterable<Iterable<T>> iterables) sync* {
      if (iterables.isEmpty) return;
      //note: without toList(growable: false) - causes infinite loop ???
      final iterators = iterables.map((e) => e.iterator).toList(growable: false);
      while (iterators.every((e) => e.moveNext())) {
         yield iterators.map((e) => e.current).toList(growable: false);
      }
   }

   static Iterable<E>
   union_1dlist<E>(List<E> left, List<E> right, [bool comp(List<E> a, E b)]){
      var already_in_r = false;
      var ret = left;
      comp ??= (a, b) => a.contains(b);
      
      for (var i = 0; i < right.length; ++i) {
         var r_member = right[i];
         already_in_r = left.any((l_member) => l_member == r_member);
         if (already_in_r){
         }else{
            ret.add(r_member);
         };
      }
      return ret;
   }

   static List<List<E>>
   union_2dlist<E>(List<List<E>> left, List<List<E>> right, [bool comp(List<E> a, E b)]){
      var already_in_r = false;
      var all = <List<E>>[];
      comp ??= (a, b) => a.contains(b);
      
      for (var i = 0; i < right.length; ++i) {
         var r_member = right[i];
         already_in_r = r_member.every((ref) =>
            left.any((l_member) =>
               comp(l_member, ref) ));
         if (already_in_r){
         }else{
            all.add(r_member);
         };
      }
      return all;
   }
   
   static List<T>
   sorted<T>(List<T> data, [int compare(T a, T b)]) {
      if (data.isEmpty) return data;
      final iterators = data.toList(growable: false);
      iterators.sort(compare);
      return iterators;
   }
   
   static void
   forEach<T>(List<T> list, bool Function(T member, [int index]) cb) {
      var length = list.length;
      for (var i = 0; i < length; ++i) {
         if (cb(list[i], i)) return;
      }
   }

   static Iterable<T>
   map<T, E>(List<E> list, T Function(E member, [int index]) cb) {
      var i = -1;
      return list.map((e) {
         i ++;
         return cb(e, i);
      });
   }


   static String
   _strip(String source, List<String> stripper,
          int srlen, int stlen,
          _TEndsStartsWith conditioning, _TSubstring substring) {
      var strip_counter = -1;
      while (strip_counter != 0) {
         strip_counter = 0;
         _log.debug('[strip]$source, ${conditioning == source.endsWith}, ${conditioning == source.startsWith}');
         for (var i = 0; i < stlen; ++i) {
            _log.debug('   1) ends with ${stripper[i]} ${conditioning(source, stripper[i])}');
            
            if (conditioning(source, stripper[i])) {
               source = substring(source, 0, source.length - 1);
               strip_counter ++;
            }
         }
      }
      return source;
   }
   
   static String
   _stripRight(String source, List<String> stripper, int srlen, int stlen, _TEndsStartsWith conditioning, _TSubstring substring) {
      return _strip(source, stripper, srlen, stlen, conditioning, substring);
   }
   
   static String
   _stripLeft(String source, List<String> stripper, int srlen, int stlen, _TEndsStartsWith conditioning, _TSubstring substring) {
      return _strip(source, stripper, srlen, stlen, conditioning, substring);
   }
   
   static String
   _stripLR(String source, String stripper,
            String Function(String source, List<String> stripper, int srlen, int stlen, _TEndsStartsWith conditioning, _TSubstring substring) pathway,
            _TEndsStartsWith conditioning, _TSubstring substring) {
      var l = stripper.length;
      if (l == 0) return source;
      if (l == 1) {
         if (conditioning(source, stripper)) {
            return substring(source, 0, source.length - 1);
         }
      } else {
         return pathway(source, stripper.split(''), source.length, stripper.length, conditioning, substring);
      }
      return source;
   } //@fmt:on
   
   static String
   stripLeft(String source, [String stripper = " "]) {
      return _stripLR(source, stripper, _stripLeft,
            (String s, String end) => s.startsWith(end),
            (String s, int start, int end) => s.substring(s.length - end));
   }
   
   static String
   stripRight(String source, [String stripper = " "]) {
      return _stripLR(source, stripper, _stripRight,
            (String s, String end) => s.endsWith(end),
            (String s, int start, int end) => s.substring(start, end));
   }
   
   static String
   strip(String source, [String stripper = " "]) {
      return stripLeft(stripRight(source, stripper), stripper);
   }
   
   static String
   dePrefix(String prefixed_name, String prefix, [String suffix = '', bool to_camelcase = false]){
      var l    = prefix.length;
      var r    = suffix.length;
      var name = prefixed_name.substring(l, prefixed_name.length - r);
      if (to_camelcase)
         return '${name.substring(0, 1).toLowerCase()}${name.substring(1)}';
      return '${name.substring(0, 1)}${name.substring(1)}';
   }
   
   static String
   toCamelCase(String word){
      var current_under = IS.upperCaseChar(word[0]), last_under = null, altered = false;
      if (IS.snakeCase(word)){
         word =  word.split('').map((w) {
            current_under = IS.underlineChar(w);
            altered = last_under != current_under;
            last_under = current_under;
            if (altered && current_under == true)
                return '';
            if (altered)
               return w.toUpperCase();
            return w;
         }).join('');
         return '${word.substring(0,1).toLowerCase()}${word.substring(1)}';
      }
      return word;
   }
   static String
   toSnakeCase(String word){
      var current_upper = IS.upperCaseChar(word[0]), last_upper = null, altered = false;
      if (IS.camelCase(word))
         return word.split('').map((w) {
            current_upper = IS.upperCaseChar(w);
            altered = last_upper != current_upper;
            last_upper = current_upper;
            if (altered && current_upper == true)
               return '_' + w.toLowerCase();
            return w;
         }).join('');
      return word;
   }
   
   
   static void
   prettyPrint(dynamic source, [int level = 0]){
      print(FN.stringPrettier(source, level));
   }
   
   static Object
   stringPrettier(dynamic node, [int level = 0]) {
      var output = '';
      if (node is Map) {
         Map _node = node;
         output += "\t" * level + "{" + '\n';
         _node.forEach((n, value) {
            var keyname = "\t" * (level + 1) + n.toString();
            var val = FN.stringPrettier(value, level + 1).toString().trim();
            output += '$keyname: ${val},\n';
         });
         return output + "\t" * level + '}';
      }
      if (node is List) {
         List _node = node;
         output += "\t" * level + "[" + '\n';
         _node.forEach((value) {
            var val = FN.stringPrettier(value, level + 1);
            output += '${val}, \n';
         });
         return output + "\t" * level + ']';
      }
      output += node.toString();
      var t = Colorize(node.runtimeType.toString());
      var v = Colorize(output);
      v.apply(Styles.LIGHT_GREEN);
      v.apply(Styles.BOLD);
      t.apply(Styles.LIGHT_MAGENTA);
      var vstring = v.toString();
      var clines = vstring
         .split('\n')
         .length;
      vstring = clines > 1
                ? _keepIndent(v.toString(), level)
                : vstring;
      return "\t" * (level) + '$t $vstring';
   }
}

void main([arguments]) {
   if (arguments.length == 1 && arguments[0] == '-directRun') {
      var a = 'helloWorld';
      var b = 'hello_world';
      
      assert(IS.camelCase(a), '$a expect to be a camel case' );
      assert(IS.snakeCase(b), '$b expect to be a snake case');
      
      var ta = FN.toSnakeCase(a);
      var tb = FN.toCamelCase(b);
      
      assert(ta == b, '$ta expect to be snake case');
      assert(tb == a, '$tb expect to be camel case');
      
      var pa = 'onSumChanged';
      
      assert(
         FN.dePrefix(pa, 'on', 'changed')  == 'Sum',
         '''\nexpect $pa to be Sum, got: ${FN.dePrefix(pa, 'on', 'changed')}'''
      );
      assert(
         FN.dePrefix(pa, 'on', 'changed', true) == 'sum',
         '''\nexpect $pa to be sum, got: ${FN.dePrefix(pa, 'on', 'changed', true)}'''
      );
   }
}


