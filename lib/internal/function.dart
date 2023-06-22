import 'package:http/http.dart' as http;

dynamic upDownNum( num, bool type) {
  switch (type) {
    case true:
      {
        num += 1;
        break;
      }

    case false:
      {
        num -= 1;
        if (num < 1) {
          num = 1;
        }
        break;
      }

    default:
      {}
      break;
  }
  return num;
}

Future<dynamic> changeCurrency(price) async {
  dynamic res1 = await http.get(Uri.parse(
      "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR"));

  print(res1.data.USD);
  dynamic res2 = await http.get(Uri.parse(
      "https://api.api-ninjas.com/v1/convertcurrency?have=USD&want=VND&amount=${res1.data.USD * price}"));

  print(res2.data.new_amount);
  return res2.data.new_amount;
}
