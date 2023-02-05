import 'dart:convert';

import 'package:dart_common/src/dart_common.dart';
import 'package:test/test.dart';


final COUNTRY_CODES = [
	{ "Code": "AF", "Name": "Afghanistan"},
	{ "Code": "AX", "Name": "\u00c5land Islands"},
	{ "Code": "AL", "Name": "Albania"},
	{ "Code": "DZ", "Name": "Algeria"},
	{ "Code": "AS", "Name": "American Samoa"},
	{ "Code": "AD", "Name": "Andorra"},
	{ "Code": "AO", "Name": "Angola"},
	{ "Code": "AI", "Name": "Anguilla"},
	{ "Code": "AQ", "Name": "Antarctica"},
	{ "Code": "AG", "Name": "Antigua and Barbuda"},
	{ "Code": "AR", "Name": "Argentina"},
	{ "Code": "AM", "Name": "Armenia"},
	{ "Code": "AW", "Name": "Aruba"},
	{ "Code": "AU", "Name": "Australia"},
	{ "Code": "AT", "Name": "Austria"},
	{ "Code": "AZ", "Name": "Azerbaijan"},
	{ "Code": "BS", "Name": "Bahamas"},
	{ "Code": "BH", "Name": "Bahrain"},
	{ "Code": "BD", "Name": "Bangladesh"},
	{ "Code": "BB", "Name": "Barbados"},
	{ "Code": "BY", "Name": "Belarus"},
	{ "Code": "BE", "Name": "Belgium"},
	{ "Code": "BZ", "Name": "Belize"},
	{ "Code": "BJ", "Name": "Benin"},
	{ "Code": "BM", "Name": "Bermuda"},
	{ "Code": "BT", "Name": "Bhutan"},
	{ "Code": "BO", "Name": "Bolivia, Plurinational State of"},
	{ "Code": "BQ", "Name": "Bonaire, Sint Eustatius and Saba"},
	{ "Code": "BA", "Name": "Bosnia and Herzegovina"},
	{ "Code": "BW", "Name": "Botswana"},
	{ "Code": "BV", "Name": "Bouvet Island"},
	{ "Code": "BR", "Name": "Brazil"},
	{ "Code": "IO", "Name": "British Indian Ocean Territory"},
	{ "Code": "BN", "Name": "Brunei Darussalam"},
	{ "Code": "BG", "Name": "Bulgaria"},
	{ "Code": "BF", "Name": "Burkina Faso"},
	{ "Code": "BI", "Name": "Burundi"},
	{ "Code": "KH", "Name": "Cambodia"},
	{ "Code": "CM", "Name": "Cameroon"},
	{ "Code": "CA", "Name": "Canada"},
	{ "Code": "CV", "Name": "Cape Verde"},
	{ "Code": "KY", "Name": "Cayman Islands"},
	{ "Code": "CF", "Name": "Central African Republic"},
	{ "Code": "TD", "Name": "Chad"},
	{ "Code": "CL", "Name": "Chile"},
	{ "Code": "CN", "Name": "China"},
	{ "Code": "CX", "Name": "Christmas Island"},
	{ "Code": "CC", "Name": "Cocos (Keeling) Islands"},
	{ "Code": "CO", "Name": "Colombia"},
	{ "Code": "KM", "Name": "Comoros"},
	{ "Code": "CG", "Name": "Congo"},
	{ "Code": "CD", "Name": "Congo, the Democratic Republic of the"},
	{ "Code": "CK", "Name": "Cook Islands"},
	{ "Code": "CR", "Name": "Costa Rica"},
	{ "Code": "CI", "Name": "C\u00f4te d'Ivoire"},
	{ "Code": "HR", "Name": "Croatia"},
	{ "Code": "CU", "Name": "Cuba"},
	{ "Code": "CW", "Name": "Cura\u00e7ao"},
	{ "Code": "CY", "Name": "Cyprus"},
	{ "Code": "CZ", "Name": "Czech Republic"},
	{ "Code": "DK", "Name": "Denmark"},
	{ "Code": "DJ", "Name": "Djibouti"},
	{ "Code": "DM", "Name": "Dominica"},
	{ "Code": "DO", "Name": "Dominican Republic"},
	{ "Code": "EC", "Name": "Ecuador"},
	{ "Code": "EG", "Name": "Egypt"},
	{ "Code": "SV", "Name": "El Salvador"},
	{ "Code": "GQ", "Name": "Equatorial Guinea"},
	{ "Code": "ER", "Name": "Eritrea"},
	{ "Code": "EE", "Name": "Estonia"},
	{ "Code": "ET", "Name": "Ethiopia"},
	{ "Code": "FK", "Name": "Falkland Islands (Malvinas)"},
	{ "Code": "FO", "Name": "Faroe Islands"},
	{ "Code": "FJ", "Name": "Fiji"},
	{ "Code": "FI", "Name": "Finland"},
	{ "Code": "FR", "Name": "France"},
	{ "Code": "GF", "Name": "French Guiana"},
	{ "Code": "PF", "Name": "French Polynesia"},
	{ "Code": "TF", "Name": "French Southern Territories"},
	{ "Code": "GA", "Name": "Gabon"},
	{ "Code": "GM", "Name": "Gambia"},
	{ "Code": "GE", "Name": "Georgia"},
	{ "Code": "DE", "Name": "Germany"},
	{ "Code": "GH", "Name": "Ghana"},
	{ "Code": "GI", "Name": "Gibraltar"},
	{ "Code": "GR", "Name": "Greece"},
	{ "Code": "GL", "Name": "Greenland"},
	{ "Code": "GD", "Name": "Grenada"},
	{ "Code": "GP", "Name": "Guadeloupe"},
	{ "Code": "GU", "Name": "Guam"},
	{ "Code": "GT", "Name": "Guatemala"},
	{ "Code": "GG", "Name": "Guernsey"},
	{ "Code": "GN", "Name": "Guinea"},
	{ "Code": "GW", "Name": "Guinea-Bissau"},
	{ "Code": "GY", "Name": "Guyana"},
	{ "Code": "HT", "Name": "Haiti"},
	{ "Code": "HM", "Name": "Heard Island and McDonald Islands"},
	{ "Code": "VA", "Name": "Holy See (Vatican City State)"},
	{ "Code": "HN", "Name": "Honduras"},
	{ "Code": "HK", "Name": "Hong Kong"},
	{ "Code": "HU", "Name": "Hungary"},
	{ "Code": "IS", "Name": "Iceland"},
	{ "Code": "IN", "Name": "India"},
	{ "Code": "ID", "Name": "Indonesia"},
	{ "Code": "IR", "Name": "Iran, Islamic Republic of"},
	{ "Code": "IQ", "Name": "Iraq"},
	{ "Code": "IE", "Name": "Ireland"},
	{ "Code": "IM", "Name": "Isle of Man"},
	{ "Code": "IL", "Name": "Israel"},
	{ "Code": "IT", "Name": "Italy"},
	{ "Code": "JM", "Name": "Jamaica"},
	{ "Code": "JP", "Name": "Japan"},
	{ "Code": "JE", "Name": "Jersey"},
	{ "Code": "JO", "Name": "Jordan"},
	{ "Code": "KZ", "Name": "Kazakhstan"},
	{ "Code": "KE", "Name": "Kenya"},
	{ "Code": "KI", "Name": "Kiribati"},
	{ "Code": "KP", "Name": "Korea, Democratic People's Republic of"},
	{ "Code": "KR", "Name": "Korea, Republic of"},
	{ "Code": "KW", "Name": "Kuwait"},
	{ "Code": "KG", "Name": "Kyrgyzstan"},
	{ "Code": "LA", "Name": "Lao People's Democratic Republic"},
	{ "Code": "LV", "Name": "Latvia"},
	{ "Code": "LB", "Name": "Lebanon"},
	{ "Code": "LS", "Name": "Lesotho"},
	{ "Code": "LR", "Name": "Liberia"},
	{ "Code": "LY", "Name": "Libya"},
	{ "Code": "LI", "Name": "Liechtenstein"},
	{ "Code": "LT", "Name": "Lithuania"},
	{ "Code": "LU", "Name": "Luxembourg"},
	{ "Code": "MO", "Name": "Macao"},
	{ "Code": "MK", "Name": "Macedonia, the Former Yugoslav Republic of"},
	{ "Code": "MG", "Name": "Madagascar"},
	{ "Code": "MW", "Name": "Malawi"},
	{ "Code": "MY", "Name": "Malaysia"},
	{ "Code": "MV", "Name": "Maldives"},
	{ "Code": "ML", "Name": "Mali"},
	{ "Code": "MT", "Name": "Malta"},
	{ "Code": "MH", "Name": "Marshall Islands"},
	{ "Code": "MQ", "Name": "Martinique"},
	{ "Code": "MR", "Name": "Mauritania"},
	{ "Code": "MU", "Name": "Mauritius"},
	{ "Code": "YT", "Name": "Mayotte"},
	{ "Code": "MX", "Name": "Mexico"},
	{ "Code": "FM", "Name": "Micronesia, Federated States of"},
	{ "Code": "MD", "Name": "Moldova, Republic of"},
	{ "Code": "MC", "Name": "Monaco"},
	{ "Code": "MN", "Name": "Mongolia"},
	{ "Code": "ME", "Name": "Montenegro"},
	{ "Code": "MS", "Name": "Montserrat"},
	{ "Code": "MA", "Name": "Morocco"},
	{ "Code": "MZ", "Name": "Mozambique"},
	{ "Code": "MM", "Name": "Myanmar"},
	{ "Code": "NA", "Name": "Namibia"},
	{ "Code": "NR", "Name": "Nauru"},
	{ "Code": "NP", "Name": "Nepal"},
	{ "Code": "NL", "Name": "Netherlands"},
	{ "Code": "NC", "Name": "New Caledonia"},
	{ "Code": "NZ", "Name": "New Zealand"},
	{ "Code": "NI", "Name": "Nicaragua"},
	{ "Code": "NE", "Name": "Niger"},
	{ "Code": "NG", "Name": "Nigeria"},
	{ "Code": "NU", "Name": "Niue"},
	{ "Code": "NF", "Name": "Norfolk Island"},
	{ "Code": "MP", "Name": "Northern Mariana Islands"},
	{ "Code": "NO", "Name": "Norway"},
	{ "Code": "OM", "Name": "Oman"},
	{ "Code": "PK", "Name": "Pakistan"},
	{ "Code": "PW", "Name": "Palau"},
	{ "Code": "PS", "Name": "Palestine, State of"},
	{ "Code": "PA", "Name": "Panama"},
	{ "Code": "PG", "Name": "Papua New Guinea"},
	{ "Code": "PY", "Name": "Paraguay"},
	{ "Code": "PE", "Name": "Peru"},
	{ "Code": "PH", "Name": "Philippines"},
	{ "Code": "PN", "Name": "Pitcairn"},
	{ "Code": "PL", "Name": "Poland"},
	{ "Code": "PT", "Name": "Portugal"},
	{ "Code": "PR", "Name": "Puerto Rico"},
	{ "Code": "QA", "Name": "Qatar"},
	{ "Code": "RE", "Name": "R\u00e9union"},
	{ "Code": "RO", "Name": "Romania"},
	{ "Code": "RU", "Name": "Russian Federation"},
	{ "Code": "RW", "Name": "Rwanda"},
	{ "Code": "BL", "Name": "Saint Barth\u00e9lemy"},
	{ "Code": "SH", "Name": "Saint Helena, Ascension and Tristan da Cunha"},
	{ "Code": "KN", "Name": "Saint Kitts and Nevis"},
	{ "Code": "LC", "Name": "Saint Lucia"},
	{ "Code": "MF", "Name": "Saint Martin (French part)"},
	{ "Code": "PM", "Name": "Saint Pierre and Miquelon"},
	{ "Code": "VC", "Name": "Saint Vincent and the Grenadines"},
	{ "Code": "WS", "Name": "Samoa"},
	{ "Code": "SM", "Name": "San Marino"},
	{ "Code": "ST", "Name": "Sao Tome and Principe"},
	{ "Code": "SA", "Name": "Saudi Arabia"},
	{ "Code": "SN", "Name": "Senegal"},
	{ "Code": "RS", "Name": "Serbia"},
	{ "Code": "SC", "Name": "Seychelles"},
	{ "Code": "SL", "Name": "Sierra Leone"},
	{ "Code": "SG", "Name": "Singapore"},
	{ "Code": "SX", "Name": "Sint Maarten (Dutch part)"},
	{ "Code": "SK", "Name": "Slovakia"},
	{ "Code": "SI", "Name": "Slovenia"},
	{ "Code": "SB", "Name": "Solomon Islands"},
	{ "Code": "SO", "Name": "Somalia"},
	{ "Code": "ZA", "Name": "South Africa"},
	{ "Code": "GS", "Name": "South Georgia and the South Sandwich Islands"},
	{ "Code": "SS", "Name": "South Sudan"},
	{ "Code": "ES", "Name": "Spain"},
	{ "Code": "LK", "Name": "Sri Lanka"},
	{ "Code": "SD", "Name": "Sudan"},
	{ "Code": "SR", "Name": "Suriname"},
	{ "Code": "SJ", "Name": "Svalbard and Jan Mayen"},
	{ "Code": "SZ", "Name": "Swaziland"},
	{ "Code": "SE", "Name": "Sweden"},
	{ "Code": "CH", "Name": "Switzerland"},
	{ "Code": "SY", "Name": "Syrian Arab Republic"},
	{ "Code": "TW", "Name": "Taiwan, Province of China"},
	{ "Code": "TJ", "Name": "Tajikistan"},
	{ "Code": "TZ", "Name": "Tanzania, United Republic of"},
	{ "Code": "TH", "Name": "Thailand"},
	{ "Code": "TL", "Name": "Timor-Leste"},
	{ "Code": "TG", "Name": "Togo"},
	{ "Code": "TK", "Name": "Tokelau"},
	{ "Code": "TO", "Name": "Tonga"},
	{ "Code": "TT", "Name": "Trinidad and Tobago"},
	{ "Code": "TN", "Name": "Tunisia"},
	{ "Code": "TR", "Name": "Turkey"},
	{ "Code": "TM", "Name": "Turkmenistan"},
	{ "Code": "TC", "Name": "Turks and Caicos Islands"},
	{ "Code": "TV", "Name": "Tuvalu"},
	{ "Code": "UG", "Name": "Uganda"},
	{ "Code": "UA", "Name": "Ukraine"},
	{ "Code": "AE", "Name": "United Arab Emirates"},
	{ "Code": "GB", "Name": "United Kingdom"},
	{ "Code": "US", "Name": "United States"},
	{ "Code": "UM", "Name": "United States Minor Outlying Islands"},
	{ "Code": "UY", "Name": "Uruguay"},
	{ "Code": "UZ", "Name": "Uzbekistan"},
	{ "Code": "VU", "Name": "Vanuatu"},
	{ "Code": "VE", "Name": "Venezuela, Bolivarian Republic of"},
	{ "Code": "VN", "Name": "Viet Nam"},
	{ "Code": "VG", "Name": "Virgin Islands, British"},
	{ "Code": "VI", "Name": "Virgin Islands, U.S."},
	{ "Code": "WF", "Name": "Wallis and Futuna"},
	{ "Code": "EH", "Name": "Western Sahara"},
	{ "Code": "YE", "Name": "Yemen"},
	{ "Code": "ZM", "Name": "Zambia"},
	{ "Code": "ZW", "Name": "Zimbabwe"}
];

final COUNTRY_CODE_TW = {
	"AF": "阿富汗",
	"AL": "阿爾巴尼亞",
	"AG": "阿爾及利亞",
	"AQ": "美屬薩摩亞",
	"AN": "澳大拉西亞",
	"AO": "安哥拉",
	"AV": "安圭拉",
	"AY": "南極洲",
	"AC": "安地卡及巴布達",
	"AR": "阿根廷",
	"AM": "亞美尼亞",
	"AA": "阿魯巴",
	"AS": "澳洲",
	"AU": "非盟",
	"AJ": "亞塞拜然",
	"BF": "巴哈馬",
	"BA": "巴林",
	"BG": "孟加拉國",
	"BB": "巴貝多",
	"BO": "波希米亞",
	"BE": "比利時",
	"BH": "貝里斯",
	"BN": "貝南",
	"BD": "百慕達",
	"BT": "不丹",
	"BL": "玻利維亞",
	"BK": "波士尼亞與赫塞哥維納",
	"BC": "波札那",
	"BV": "布韋島",
	"BR": "巴西",
	"IO": "英屬印度洋領地",
	"VI": "英屬維京群島",
	"BX": "汶萊",
	"BU": "保加利亞",
	"UV": "布吉納法索",
	"BM": "緬甸",
	"BY": "蒲隆地",
	"CV": "維德角",
	"CB": "柬埔寨",
	"CM": "喀麥隆",
	"CA": "加拿大",
	"CJ": "開曼群島",
	"CT": "中非",
	"CD": "查德",
	"CI": "智利",
	"CH": "中國",
	"KT": "聖誕島",
	"CK": "科科斯（基林）群島",
	"CO": "哥倫比亞",
	"CN": "葛摩",
	"CG": "民主剛果",
	"CF": "剛果",
	"CW": "庫克群島",
	"CS": "哥斯大黎加",
	"IV": "象牙海岸",
	"HR": "克羅埃西亞",
	"CU": "古巴",
	"UC": "古拉索",
	"CY": "賽普勒斯",
	"EZ": "捷克",
	"DA": "達荷美",
	"DJ": "吉布地",
	"DO": "多米尼克",
	"DR": "多明尼加",
	"EC": "厄瓜多",
	"EG": "埃及",
	"ES": "薩爾瓦多",
	"EK": "赤道幾內亞",
	"ER": "厄利垂亞",
	"EN": "獨立國協",
	"ET": "衣索比亞",
	"FK": "福克蘭群島",
	"FO": "法羅群島",
	"FJ": "斐濟",
	"FI": "芬蘭",
	"FR": "法國",
	"FX": "法國本土",
	"FG": "法屬圭亞那",
	"FP": "法屬玻里尼西亞",
	"FS": "法屬南方和南極洲領地",
	"GB": "加彭",
	"GA": "甘比亞",
	"GZ": "巴勒斯坦",
	"GG": "喬治亞",
	"GM": "德國",
	"GH": "加納",
	"GI": "直布羅陀",
	"GR": "希臘",
	"GL": "格陵蘭",
	"GJ": "格瑞那達",
	"GP": "瓜德羅普",
	"GQ": "關島",
	"GT": "瓜地馬拉",
	"GK": "耿西",
	"GV": "幾內亞",
	"PU": "幾內亞比索",
	"GY": "蓋亞那",
	"HA": "海地",
	"HM": "赫德島和麥克唐納群島",
	"VT": "梵蒂岡",
	"HO": "宏都拉斯",
	"HK": "中國香港",
	"HU": "匈牙利",
	"IC": "冰島",
	"IN": "印度",
	"ID": "印尼",
	"IR": "伊朗",
	"IZ": "伊拉克",
	"EI": "愛爾蘭",
	"IM": "曼島",
	"IS": "以色列",
	"IT": "義大利",
	"JM": "牙買加",
	"JA": "日本",
	"JE": "澤西",
	"JO": "約旦",
	"KZ": "哈薩克",
	"KE": "肯亞",
	"KR": "吉里巴斯",
	"KN": "北韓",
	"KS": "韓國",
	"KV": "科索沃",
	"KU": "科威特",
	"KG": "吉爾吉斯",
	"LA": "寮國",
	"LG": "拉脫維亞",
	"LE": "黎巴嫩",
	"LT": "賴索托",
	"LI": "賴比瑞亞",
	"LY": "利比亞",
	"LS": "列支敦斯登",
	"LH": "立陶宛",
	"LU": "盧森堡",
	"MC": "中國澳門",
	"MK": "北馬其頓",
	"MA": "馬達加斯加",
	"MI": "馬拉威",
	"MY": "馬來西亞",
	"MV": "馬爾地夫",
	"ML": "馬利",
	"MT": "馬爾他",
	"RM": "馬紹爾群島",
	"MB": "馬提尼克",
	"MR": "茅利塔尼亞",
	"MP": "模里西斯",
	"MF": "馬約特",
	"MX": "墨西哥",
	"FM": "密克羅尼西亞聯邦",
	"MD": "摩爾多瓦",
	"MN": "摩納哥",
	"MG": "蒙古國",
	"MJ": "蒙特內哥羅",
	"MH": "蒙哲臘",
	"MO": "摩洛哥",
	"MZ": "莫三比克",
	"WA": "納米比亞",
	"NR": "諾魯",
	"NP": "尼泊爾",
	"NL": "荷蘭",
	"NT": "荷屬安地列斯",
	"NC": "新喀里多尼亞",
	"NZ": "紐西蘭",
	"NU": "尼加拉瓜",
	"NG": "尼日",
	"NI": "奈及利亞",
	"NE": "紐埃",
	"NF": "諾福克島",
	"CQ": "北馬利亞納群島",
	"NO": "挪威",
	"MU": "阿曼",
	"PK": "巴基斯坦",
	"PS": "帛琉",
	"PM": "巴拿馬",
	"PP": "巴布亞紐幾內亞",
	"PA": "巴拉圭",
	"PE": "秘魯",
	"RP": "菲律賓",
	"PC": "皮特肯群島",
	"PL": "波蘭",
	"PO": "葡萄牙",
	"RQ": "波多黎各",
	"QA": "卡達",
	"RE": "留尼旺",
	"RO": "羅馬尼亞",
	"TW": "臺灣",
	"RS": "俄羅斯",
	"RW": "盧安達",
	"TB": "聖巴泰勒米",
	"SH": "聖海蓮娜、阿森松和特里斯坦-達庫尼亞",
	"SC": "塞爾維亞與蒙特內哥羅",
	"ST": "聖露西亞",
	"RN": "法屬聖馬丁",
	"VC": "聖文森及格瑞那丁",
	"WS": "薩摩亞",
	"SM": "聖馬利諾",
	"TP": "聖多美普林西比",
	"SA": "沙烏地阿拉伯",
	"SG": "塞內加爾",
	"RI": "塞爾維亞",
	"SE": "塞席爾",
	"SL": "獅子山",
	"SN": "新加坡",
	"NN": "荷屬聖馬丁",
	"LO": "斯洛伐克",
	"SI": "斯洛維尼亞",
	"BP": "索羅門群島",
	"SO": "索馬利亞",
	"SF": "南非",
	"SX": "南喬治亞和南桑威奇群島",
	"OD": "南蘇丹",
	"SP": "西班牙",
	"CE": "斯里蘭卡",
	"SU": "蘇丹",
	"NS": "蘇利南",
	"SB": "聖皮耶與密克隆",
	"WZ": "史瓦帝尼",
	"SW": "瑞典",
	"SZ": "瑞士",
	"SY": "敘利亞",
	"TI": "塔吉克",
	"TZ": "坦尚尼亞",
	"TH": "泰國",
	"TT": "東帝汶",
	"TO": "多哥",
	"TL": "托克勞",
	"TN": "東加",
	"TD": "千里達及托巴哥",
	"TS": "突尼西亞",
	"TU": "土耳其",
	"TX": "土庫曼",
	"TK": "特克斯與凱科斯群島",
	"TV": "吐瓦魯",
	"UG": "烏干達",
	"UP": "烏克蘭",
	"AE": "阿聯",
	"UK": "英國",
	"US": "美國",
	"UM": "美國本土外小島嶼",
	"UY": "烏拉圭",
	"UZ": "烏茲別克",
	"NH": "萬那杜",
	"VE": "委內瑞拉",
	"VM": "越南",
	"VQ": "美屬維京群島",
	"WF": "瓦利斯和富圖納",
	"WE": "巴勒斯坦",
	"WI": "西印度群島聯邦",
	"UN": "聯合國",
	"EU": "歐盟",
	"ASEAN": "東協",
	"YM": "葉門",
	"ZA": "尚比亞",
	"ZI": "辛巴威",
	"RH": "羅德西亞",
	"YU": "南斯拉夫",
	"UR": "蘇聯",
	"VO": "上伏塔",
	"TC": "捷克斯洛伐克",
	"UA": "阿拉伯聯合共和國"
};

final COUNTRY_CODE_CN = {
	"AF": "阿富汗",
	"AL": "阿尔巴尼亚",
	"AG": "阿尔及利亚",
	"AQ": "美属萨摩亚",
	"AN": "澳大拉西亚",
	"AO": "安哥拉",
	"AV": "安圭拉",
	"AY": "南极洲",
	"AC": "安地卡及巴布达",
	"AR": "阿根廷",
	"AM": "亚美尼亚",
	"AA": "阿鲁巴",
	"AS": "澳洲",
	"AU": "非盟",
	"AJ": "亚塞拜然",
	"BF": "巴哈马",
	"BA": "巴林",
	"BG": "孟加拉国",
	"BB": "巴贝多",
	"BO": "波希米亚",
	"BE": "比利时",
	"BH": "贝里斯",
	"BN": "贝南",
	"BD": "百慕达",
	"BT": "不丹",
	"BL": "玻利维亚",
	"BK": "波士尼亚与赫塞哥维纳",
	"BC": "博茨瓦纳",
	"BV": "布韦岛",
	"BR": "巴西",
	"IO": "英属印度洋领地",
	"VI": "英属维京群岛",
	"BX": "汶莱",
	"BU": "保加利亚",
	"UV": "布吉纳法索",
	"BM": "缅甸",
	"BY": "布隆迪",
	"CV": "维德角",
	"CB": "柬埔寨",
	"CM": "喀麦隆",
	"CA": "加拿大",
	"CJ": "开曼群岛",
	"CT": "中非",
	"CD": "乍得",
	"CI": "智利",
	"CH": "中国",
	"KT": "圣诞岛",
	"CK": "科科斯（基林）群岛",
	"CO": "哥伦比亚",
	"CN": "科摩罗",
	"CG": "民主刚果",
	"CF": "刚果",
	"CW": "库克群岛",
	"CS": "哥斯达黎加",
	"IV": "科特迪瓦",
	"HR": "克罗埃西亚",
	"CU": "古巴",
	"UC": "古拉索",
	"CY": "赛普勒斯",
	"EZ": "捷克",
	"DA": "达荷美",
	"DJ": "吉布提",
	"DO": "多米尼加联邦",
	"DR": "多米尼加",
	"EC": "厄瓜多尔",
	"EG": "埃及",
	"ES": "萨尔瓦多",
	"EK": "赤道几内亚",
	"ER": "厄利垂亚",
	"EN": "独立国协",
	"ET": "衣索比亚",
	"FK": "福克兰群岛",
	"FO": "法罗群岛",
	"FJ": "斐济",
	"FI": "芬兰",
	"FR": "法国",
	"FX": "法国本土",
	"FG": "法属盖亚那",
	"FP": "法属玻里尼西亚",
	"FS": "法属南方和南极洲领地",
	"GB": "加蓬",
	"GA": "甘比亚",
	"GZ": "巴勒斯坦",
	"GG": "乔治亚",
	"GM": "德国",
	"GH": "迦纳",
	"GI": "直布罗陀",
	"GR": "希腊",
	"GL": "格陵兰",
	"GJ": "格瑞那达",
	"GP": "瓜德罗普",
	"GQ": "关岛",
	"GT": "瓜地马拉",
	"GK": "耿西",
	"GV": "几内亚",
	"PU": "几内亚比索",
	"GY": "盖亚那",
	"HA": "海地",
	"HM": "赫德岛和麦克唐纳群岛",
	"VT": "梵蒂冈",
	"HO": "洪都拉斯",
	"HK": "中国香港",
	"HU": "匈牙利",
	"IC": "冰岛",
	"IN": "印度",
	"ID": "印尼",
	"IR": "伊朗",
	"IZ": "伊拉克",
	"EI": "爱尔兰",
	"IM": "曼岛",
	"IS": "以色列",
	"IT": "义大利",
	"JM": "牙买加",
	"JA": "日本",
	"JE": "泽西",
	"JO": "约旦",
	"KZ": "哈萨克",
	"KE": "肯亚",
	"KR": "基里巴斯",
	"KN": "北韩",
	"KS": "韩国",
	"KV": "科索沃",
	"KU": "科威特",
	"KG": "吉尔吉斯",
	"LA": "寮国",
	"LG": "拉脱维亚",
	"LE": "黎巴嫩",
	"LT": "赖索托",
	"LI": "赖比瑞亚",
	"LY": "利比亚",
	"LS": "列支敦士登",
	"LH": "立陶宛",
	"LU": "卢森堡",
	"MC": "中国澳门",
	"MK": "北马其顿",
	"MA": "马达加斯加",
	"MI": "马拉威",
	"MY": "马来西亚",
	"MV": "马尔地夫",
	"ML": "马利",
	"MT": "马尔他",
	"RM": "马绍尔群岛",
	"MB": "马提尼克",
	"MR": "茅利塔尼亚",
	"MP": "毛里求斯",
	"MF": "马约特",
	"MX": "墨西哥",
	"FM": "密克罗尼西亚联邦",
	"MD": "摩尔多瓦",
	"MN": "摩纳哥",
	"MG": "蒙古国",
	"MJ": "蒙特内哥罗",
	"MH": "蒙哲腊",
	"MO": "摩洛哥",
	"MZ": "莫桑比克",
	"WA": "纳米比亚",
	"NR": "诺鲁",
	"NP": "尼泊尔",
	"NL": "荷兰",
	"NT": "荷属安地列斯",
	"NC": "新喀里多尼亚",
	"NZ": "纽西兰",
	"NU": "尼加拉瓜",
	"NG": "尼日尔",
	"NI": "奈及利亚",
	"NE": "纽埃",
	"NF": "诺福克岛",
	"CQ": "北马利亚纳群岛",
	"NO": "挪威",
	"MU": "阿曼",
	"PK": "巴基斯坦",
	"PS": "帕劳",
	"PM": "巴拿马",
	"PP": "巴布亚纽几内亚",
	"PA": "巴拉圭",
	"PE": "秘鲁",
	"RP": "菲律宾",
	"PC": "皮特肯群岛",
	"PL": "波兰",
	"PO": "葡萄牙",
	"RQ": "波多黎各",
	"QA": "卡达",
	"RE": "留尼旺",
	"RO": "罗马尼亚",
	"TW": "台湾",
	"RS": "俄罗斯",
	"RW": "卢安达",
	"TB": "圣巴泰勒米",
	"SH": "圣海莲娜、阿森松和特里斯坦-达库尼亚",
	"SC": "塞尔维亚与蒙特内哥罗",
	"ST": "圣露西亚",
	"RN": "法属圣马丁",
	"VC": "圣文森及格瑞那丁",
	"WS": "萨摩亚",
	"SM": "圣马利诺",
	"TP": "圣多美普林西比",
	"SA": "沙乌地阿拉伯",
	"SG": "塞内加尔",
	"RI": "塞尔维亚",
	"SE": "塞席尔",
	"SL": "狮子山",
	"SN": "新加坡",
	"NN": "荷属圣马丁",
	"LO": "斯洛伐克",
	"SI": "斯洛维尼亚",
	"BP": "索罗门群岛",
	"SO": "索马利亚",
	"SF": "南非",
	"SX": "南乔治亚和南桑威奇群岛",
	"OD": "南苏丹",
	"SP": "西班牙",
	"CE": "斯里兰卡",
	"SU": "苏丹",
	"NS": "苏利南",
	"SB": "圣皮耶与密克隆",
	"WZ": "史瓦帝尼",
	"SW": "瑞典",
	"SZ": "瑞士",
	"SY": "叙利亚",
	"TI": "塔吉克斯坦",
	"TZ": "坦尚尼亚",
	"TH": "泰国",
	"TT": "东帝汶",
	"TO": "多哥",
	"TL": "托克劳",
	"TN": "东加",
	"TD": "千里达及托巴哥",
	"TS": "突尼西亚",
	"TU": "土耳其",
	"TX": "土库曼",
	"TK": "特克斯与凯科斯群岛",
	"TV": "吐瓦鲁",
	"UG": "乌干达",
	"UP": "乌克兰",
	"AE": "阿联",
	"UK": "英国",
	"US": "美国",
	"UM": "美国本土外小岛屿",
	"UY": "乌拉圭",
	"UZ": "乌兹别克",
	"NH": "万那杜",
	"VE": "委内瑞拉",
	"VM": "越南",
	"VQ": "美属维京群岛",
	"WF": "瓦利斯和富图纳",
	"WE": "巴勒斯坦",
	"WI": "西印度群岛联邦",
	"UN": "联合国",
	"EU": "欧盟",
	"ASEAN": "东协",
	"YM": "叶门",
	"ZA": "尚比亚",
	"ZI": "津巴布韦",
	"RH": "罗德西亚",
	"YU": "南斯拉夫",
	"UR": "苏联",
	"VO": "上伏塔",
	"TC": "捷克斯洛伐克",
	"UA": "阿拉伯联合共和国"
};

enum EPlayerFoot{
	Left, Right, Both
}


extension EplayerFootExtension on EPlayerFoot{
	static const MAP = [
		'Left', 'Right', 'Both'
	];
	static final List<String> _Strings = EPlayerFoot.values.map((a) => a.name).toList();
	String get name => MAP[index];
	String toEnumString() => _Strings[this.index];
	EPlayerFoot? fromString(String string){
		return EPlayerFoot.values.firstWhere((e){
			return _Strings[e.index] == string;
		}, orElse: ()=>null as dynamic);
	}
}


enum EPlayerPos{
	Defender, Midfielder, Guard, Forward,
}

extension EPlayerPosExtension on EPlayerPos{
	static const MAP = [
		'Defender', 'Midfielder', 'Guard', 'Forward',
	];
	static final List<String> _Strings = EPlayerPos.values.map((a) => a.name).toList();
	String get name => MAP[index];
	EPlayerPos? fromString(String string){
		return EPlayerPos.values.firstWhere((e){
			return _Strings[e.index] == string;
		}, orElse: ()=>null as dynamic);
	}
	String toEnumString() => _Strings[this.index];
}


class CacheTemp {
	int counter = 0;
	CacheProperty<String>? _themeKey;
	
	String? get themeKey {
		_themeKey ??= CacheProperty(onChange: _setThemekey, defaultValue: "BLACK", instance: this);
		return _themeKey!.value;
	}
	
	void set themeKey(String? v) {
		_themeKey!.value = v;
	}
	
	void _setThemekey(String? value) {
		counter ++;
	}
	
	
	CacheProperty<String>? _name;
	
	String? get name {
		_name ??= CacheProperty(onChange: _setName, defaultValue: "ELTON", instance: this);
		return _name!.value;
	}
	
	void set name(String? v) {
		_name!.value = v;
	}
	
	void _setName(String? value) {
		counter ++;
	}
}


class ExpiredTemp {
	int counter = 0;
}


void main() {
	group('jsonToQueryString test', () {
		final Map<String, dynamic> json = <String, dynamic>{ "action_key": "24", "away_score": "4", "home_score": "5", "id": "5",};
		
		test('show combined country code', () {
			final ncode = Map.from(COUNTRY_CODE_TW);
			ncode.forEach((k, v) {
				final tw = COUNTRY_CODE_TW[k]!;
				final cn = COUNTRY_CODE_CN[k]!;
				final m = COUNTRY_CODES.firstWhere((_) => _["Code"] == k, orElse: ()=>{});
				if (m.isNotEmpty){
					m['TW'] = tw;
					m['CN'] = cn;
					m['EN'] = m['Name']!;
					m.remove('Name');
				}
				COUNTRY_CODES.where((_) => _.containsKey('Name')).forEach((_){
					_['EN'] = _['Name']!;
					_.remove('Name');
					_['TW'] = "";
					_['CN'] = "";
				});
			});
			
			print(jsonEncode(COUNTRY_CODES));
		});
		
		test('A', () {
			String eml = "me@here.com";
			String passwd = "password";
			Map<String, dynamic> json = { "email": eml, "password": passwd};
			Uri outgoingUri = Uri(scheme: 'http', host: 'localhost', port: 8080, path: 'myapp', queryParameters: json);
			expect(outgoingUri.query, "email=me%40here.com&password=password");
		});
		
		test('A-2', () {
			String eml = "me@here.com";
			String passwd = "password";
			Map<String, dynamic> json = { "email": eml, "password": passwd};
			final result = jsonToQueryString(json);
			expect(result, "email=me%40here.com&password=password");
		});
		
		test('A-3', () {
			String eml = "hello";
			String? passwd = null;
			Map<String, dynamic> json = { "email": eml, "password": passwd};
			final result = jsonToQueryString(json);
			expect(result, "email=hello");
		});
		
		test('B', () {
			final u = jsonToQueryString(json);
			print('u: $u');
		});
	});
	
	group('CacheProperty test', () {
		int counter = 0;
		final prop = CacheProperty(onChange: (n) {
			counter ++;
		}, defaultValue: 1000);
		
		final temp = CacheTemp();
		
		test('', () {
			expect(EPlayerFoot.Both.fromString('Left'), equals(EPlayerFoot.Left));
			expect(EPlayerPos.Forward.fromString('Forward'), equals(EPlayerPos.Forward));
			final map = {
				"age": 31,
				"birthday": "1989-01-06",
				"country_code": "gb",
				"extra": {},
				"foot": "Left",
				"height": 193,
				"id": 59575,
				"image": "spyderapi.votefair365.net/resource/image/player_image/2/player_47382.png",
				"jersey_number": "7",
				"name": "Andy Carroll",
				"position": "Forward",
				"weight": 79
			};
			final eFoot = EPlayerFoot.Both.fromString(map['foot'] as String);
		});
		
		test('expect default value to be 1000 and counter remain the same', () {
			expect(prop.value, 1000);
			expect(counter, 0);
			expect(temp.themeKey, 'BLACK');
			expect(temp.name, "ELTON");
		});
		
		test('expect value updated', () {
			prop.value = 13;
			final c = prop.value;
			expect(prop.value, 13);
			expect(counter, 1);
			expect(c, 13);
			
			temp.themeKey = 'LIGHT';
			expect(temp.themeKey, 'LIGHT');
			expect(temp.counter, 1);
			
			expect(temp.name, "ELTON");
			temp.name = 'JOE';
			expect(temp.name, 'JOE');
			expect(temp.counter, 2);
		});
		
		test('expect value cached, counter should remain the same', () {
			prop.value = 13;
			final c = prop.value;
			expect(prop.value, 13);
			expect(counter, 1);
			expect(c, 13);
			
			temp.themeKey = 'LIGHT';
			expect(temp.themeKey, 'LIGHT');
			expect(temp.counter, 2);
		});
		
		test('A-update to a brand new value, expect counter changed', () {
			prop.value = 14;
			final c = prop.value;
			expect(prop.value, 14);
			expect(counter, 2);
			expect(c, 14);
			
			temp.themeKey = 'STYLISH';
			expect(temp.themeKey, 'STYLISH');
			expect(temp.counter, 3);
		});
		
		
		test('B-update to a brand new value, expect counter changed', () {
			prop.value = 14;
			expect(prop.value, 14);
			expect(counter, 2);
			temp.themeKey = 'CLASSIC';
			expect(temp.themeKey, 'CLASSIC');
			expect(temp.counter, 4);
		});
		
		test('expect value cached, counter should remain the same', () {
			prop.value = 14;
			final c = prop.value;
			expect(prop.value, 14);
			expect(counter, 2);
			expect(c, 14);
			temp.themeKey = 'CLASSIC';
			expect(temp.themeKey, 'CLASSIC');
			expect(temp.counter, 4);
		});
	});
	
	group('ExpiredProperty test', () {
		int counter = 0;
		// final prop = ExpirableProperty<List<DateMatchesModel>>(onExpired: () {
		// 	counter ++;
		// 	return fetchDateMatches(MatchTestHelper.h.getDateStringForFetch(0));
		// }, period: Duration(seconds: 5), key: ValueKey('test')
		//
		// );
		//
		// test('get initial value, expect counter to be 1', () async {
		// 	expect(counter, 0);
		// 	final result = await prop.getValue();
		// 	expect(counter, 1);
		// });
		//
		// test('fetch again within five seconds, expect to be cached and counter remain the same', () async {
		// 	await Future.delayed(Duration(seconds: 3));
		// 	final result = await prop.getValue();
		// 	expect(counter, 1);
		// });
		//
		// test('fetch again after expiration period, expect counter increased', () async {
		// 	await Future.delayed(Duration(seconds: 3));
		// 	final result = await prop.getValue();
		// 	expect(counter, 2);
		// });
		
	});
}
