import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:html/parser.dart';
import 'format.i18n.dart';

extension StringFormatUtils on String {
  String specialChars() => this
      .replaceAll("é", "e")
      .replaceAll("á", "a")
      .replaceAll("ó", "o")
      .replaceAll("ő", "o")
      .replaceAll("ö", "o")
      .replaceAll("ú", "u")
      .replaceAll("ű", "u")
      .replaceAll("ü", "u")
      .replaceAll("í", "i");

  String capital() => this.length > 0 ? this[0].toUpperCase() + this.substring(1) : "";

  String capitalize() => this.split(" ").map((w) => w.capital()).join(" ");

  String escapeHtml() {
    String htmlString = this;
    htmlString = htmlString.replaceAll("\r", "");
    htmlString = htmlString.replaceAll(RegExp(r'<br ?/?>'), "\n");
    htmlString = htmlString.replaceAll(RegExp(r'<p ?>'), "");
    htmlString = htmlString.replaceAll(RegExp(r'</p ?>'), "\n");
    var document = parse(htmlString);
    return document.body?.text.trim() ?? "";
  }
}

extension DateFormatUtils on DateTime {
  String format(BuildContext context, {bool timeOnly = false, bool weekday = false}) {
    // Time only
    if (timeOnly) return DateFormat("HH:mm").format(this);

    DateTime now = DateTime.now();
    if (now.year == this.year && now.month == this.month && now.day == this.day) {
      if (this.hour == 0 && this.minute == 0 && this.second == 0) return "Today".i18n;
      return DateFormat("HH:mm").format(this);
    }
    if (now.year == this.year && now.month == this.month && now.subtract(Duration(days: 1)).day == this.day) return "Yesterday".i18n;

    String formatString;
    if (this.year == now.year)
      formatString = "MMM dd.";
    else
      formatString = "yy/MM/dd";

    if (weekday) formatString += " (EEEE)";

    return DateFormat(formatString, I18n.of(context).locale.toString()).format(this);
  }
}
