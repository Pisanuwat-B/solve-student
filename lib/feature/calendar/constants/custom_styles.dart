import 'package:flutter/material.dart';
import 'package:solve_student/feature/calendar/helper/utility_helper.dart';

import 'constants.dart';

class CustomStyles {
  static final _util = UtilityHelper();
  static double paddingApp = 16.0;
  static double miniPaddingApp = 8.0;
  static double marginModalTop = 16.0;
  static double marginModalButtonVertical = 28.0;
  static double marginModalBottom = 38.0;

  // Button Style
  static ButtonStyle activeStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    elevation: 4,
  );

  static ButtonStyle disabledStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[300],
    elevation: 0,
  );

  //MARK: FONT REGULAR
  static TextStyle reg11Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(11),
  );

  static TextStyle reg11green125924 = TextStyle(
    color: CustomColors.green125924,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(11),
  );

  static TextStyle reg11Gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(11),
  );

  static TextStyle reg12greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle reg12green125924 = TextStyle(
    color: CustomColors.green125924,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle reg12Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle reg12Gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle reg12yellowFF9800 = TextStyle(
    color: CustomColors.yellowFF9800,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle reg12Gray878787Underline = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
    decoration: TextDecoration.underline,
  );
  static TextStyle reg12OrangeCC6700 = TextStyle(
    color: CustomColors.orangeCC6700,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle reg14green125924 = TextStyle(
    color: CustomColors.green125924,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle reg14white = TextStyle(
    color: CustomColors.white,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle reg14Gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle reg14Gray878787Underline = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
    decoration: TextDecoration.underline,
  );

  static TextStyle reg14orangeCC6700 = TextStyle(
    color: CustomColors.orangeCC6700,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle reg24orangeCC6700 = TextStyle(
    color: CustomColors.orangeCC6700,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(24),
  );
  static TextStyle reg32orangeCC6700 = TextStyle(
    color: CustomColors.orangeCC6700,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(32),
  );
  static TextStyle reg14RedF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle reg14Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle reg16Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg16orangeCC6700 = TextStyle(
    color: CustomColors.orangeCC6700,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg22Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(22),
  );
  static TextStyle reg32Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(32),
  );
  static TextStyle reg32gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(32),
  );
  static TextStyle reg16redF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg18greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(18),
  );

  static TextStyle reg12Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(12),
  );
  static TextStyle reg12GreenBold = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontWeight: FontWeight.bold,
    fontSize: _util.addMinusFontSize(12),
  );
  static TextStyle reg12RedBold = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSans,
    fontWeight: FontWeight.bold,
    fontSize: _util.addMinusFontSize(12),
  );
  static TextStyle reg14Black = TextStyle(
    color: Colors.black,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle reg14BlackUnderline = TextStyle(
    color: Colors.black,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
    decoration: TextDecoration.underline,
  );

  static TextStyle reg14Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );

  //MARK: BOLD REGULAR

  static TextStyle bold12Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle bold12BlackFF9800 = TextStyle(
    color: CustomColors.yellowFF9800,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle bold14Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle reg14gray363636 = TextStyle(
    color: CustomColors.gray363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle bold14yellowFF9800 = TextStyle(
    color: CustomColors.yellowFF9800,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle reg16Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg15gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(15),
  );
  static TextStyle reg16gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg16gray363636 = TextStyle(
    color: CustomColors.gray363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg16white = TextStyle(
    color: CustomColors.whitePrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg16greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle reg18Gray363636 = TextStyle(
    color: CustomColors.gray363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(18),
  );

  static TextStyle reg18black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: _util.addMinusFontSize(18),
  );
  //MARK: FONT BOLD
  static TextStyle bold14Gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle bold12Gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle bold11Gray878787 = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 11,
  );

  static TextStyle bold14RedF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle bold14White = TextStyle(
    color: CustomColors.white,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle bold14greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle bold14bluePrimary = TextStyle(
    color: CustomColors.blue0D47A1,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle bold12bluePrimary = TextStyle(
    color: CustomColors.blue0D47A1,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(12),
  );
  static TextStyle bold14bluePrimaryLine = TextStyle(
    color: CustomColors.blue0D47A1,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
    decoration: TextDecoration.underline,
  );
  static TextStyle bold18greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(18),
  );

  static TextStyle bold14green125924 = TextStyle(
    color: CustomColors.green125924,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle bold14redB71C1C = TextStyle(
    color: CustomColors.redB71C1C,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle bold12redB71C1C = TextStyle(
    color: CustomColors.redB71C1C,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle bold14green4CAF50 = TextStyle(
    color: CustomColors.green4CAF50,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle bold12green4CAF50 = TextStyle(
    color: CustomColors.green4CAF50,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(12),
  );
  static TextStyle bold14Black363636Overflow = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
    overflow: TextOverflow.ellipsis,
  );

  static TextStyle bold16redF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle bold16Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle bold16Black = TextStyle(
    color: CustomColors.black,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(16),
  );
  static TextStyle blod16gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle bold22Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(22),
  );

  static TextStyle bold22redF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(22),
  );

  static TextStyle bold14Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(14),
  );
  static TextStyle bold16Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle bold18Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(18),
  );
  static TextStyle bold20Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(20),
  );

  static TextStyle bold22Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(22),
  );

  static TextStyle bold36greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(36),
  );

  static TextStyle bold36gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: _util.addMinusFontSize(36),
  );

  //MARK: FONT MED
  static TextStyle med11greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(11),
  );

  static TextStyle med11gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(11),
  );

  static TextStyle med12redB71C1C = TextStyle(
    color: CustomColors.redB71C1C,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle med12gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle med12GreenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(12),
  );

  static TextStyle med14Black363636Overflow = TextStyle(
    overflow: TextOverflow.ellipsis,
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med14Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med14redB71C1C = TextStyle(
    color: CustomColors.redB71C1C,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med14Gray878787 = TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med14greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med14greenPrimaryOverflow = TextStyle(
    overflow: TextOverflow.ellipsis,
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med14White = TextStyle(
    color: CustomColors.white,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(14),
  );

  static TextStyle med15Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(15),
  );
  static TextStyle med16Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle med16Black36363606 = TextStyle(
    color: CustomColors.black.withOpacity(0.6),
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle med16White = TextStyle(
    color: CustomColors.white,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle med16Green = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(16),
  );

  static TextStyle med16GreenUnderline = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(16),
    decoration: TextDecoration.underline,
  );

  static TextStyle med18greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(18),
  );

  static TextStyle med18redF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(18),
  );

  static TextStyle med18Black363636 = TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(18),
  );

  static TextStyle med32greenPrimary = TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(32),
  );

  static TextStyle med32redF44336 = TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(32),
  );

  static TextStyle reg14black363636 = const TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSans,
    fontSize: 14,
  );

  static TextStyle bold11White = const TextStyle(
    color: CustomColors.whitePrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 11,
  );

  static TextStyle bold12redF44336 = const TextStyle(
    color: CustomColors.redF44336,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 12,
  );

  static TextStyle bold12gray878787 = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 12,
  );

  static TextStyle bold12greenPrimary = const TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 12,
  );

  static TextStyle bold14RedB71C1C = const TextStyle(
    color: CustomColors.redB71C1C,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
  );
  static TextStyle bold14Gray878787underline = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
    decoration: TextDecoration.underline,
  );

  static TextStyle bold14grayCFCFCF = const TextStyle(
    color: CustomColors.grayCFCFCF,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
  );

  static TextStyle bold14Gray878787Overflow = const TextStyle(
      color: CustomColors.gray878787,
      fontFamily: CustomFontFamily.NotoSansBold,
      fontSize: 14,
      overflow: TextOverflow.ellipsis);

  static TextStyle bold14orangeCC6700 = const TextStyle(
    color: CustomColors.orangeCC6700,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
  );

  static TextStyle bold14greenPrimaryUnderline = const TextStyle(
    color: CustomColors.greenPrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
    decoration: TextDecoration.underline,
    decorationColor: CustomColors.greenPrimary,
  );

  static TextStyle bold14blue0D47A1 = const TextStyle(
    color: CustomColors.blue0D47A1,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
  );

  static TextStyle bold14blue0D47A1Line = const TextStyle(
    color: CustomColors.blue0D47A1,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
    decoration: TextDecoration.underline,
  );

  static TextStyle bold18greenPrimaryOverflow = const TextStyle(
      color: CustomColors.greenPrimary,
      fontFamily: CustomFontFamily.NotoSansBold,
      fontSize: 18,
      overflow: TextOverflow.ellipsis);

  static TextStyle bold16gray878787 = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 16,
  );

  static TextStyle bold16Black363636Overflow = const TextStyle(
      color: CustomColors.black363636,
      fontFamily: CustomFontFamily.NotoSansBold,
      fontSize: 16,
      overflow: TextOverflow.ellipsis);

  static TextStyle bold22Black363636underline = const TextStyle(
    color: CustomColors.black363636,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 22,
    decoration: TextDecoration.underline,
  );

  static TextStyle bold18gray878787 = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 18,
  );

  static TextStyle bold16greenPrimaryOverflow = const TextStyle(
      color: CustomColors.greenPrimary,
      fontFamily: CustomFontFamily.NotoSansBold,
      fontSize: 16,
      overflow: TextOverflow.ellipsis);

  static TextStyle bold16whitePrimary = const TextStyle(
    color: CustomColors.whitePrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 16,
  );
  static TextStyle bold14whitePrimary = const TextStyle(
    color: CustomColors.whitePrimary,
    fontFamily: CustomFontFamily.NotoSansBold,
    fontSize: 14,
  );

  static TextStyle med11white = const TextStyle(
    color: CustomColors.whitePrimary,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: 11,
  );

  static TextStyle med11gray878787Overflow = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: 11,
    overflow: TextOverflow.ellipsis,
  );

  static TextStyle med12gray878787underline = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: 12,
    decoration: TextDecoration.underline,
  );

  static TextStyle med14redFF4201 = const TextStyle(
    color: CustomColors.redFF4201,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: 14,
  );

  static TextStyle med16gray878787 = const TextStyle(
    color: CustomColors.gray878787,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: 16,
  );

  static TextStyle weekendStyle = TextStyle(
    color: CustomColors.redB71C1C,
    fontFamily: CustomFontFamily.NotoSansMed,
    fontSize: _util.addMinusFontSize(16),
  );
}
