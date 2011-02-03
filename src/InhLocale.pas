unit InhLocale;

interface

uses SysUtils;

procedure InhLocaleInit ();

implementation

procedure InhLocaleInit ();
begin
  // Locale related settings:
  // These are optimal values for Brazil, so change
  // them at will if you're using this somewhere else
  CurrencyString := 'R$';
  CurrencyFormat := 2;
  NegCurrFormat := 12;
{
  ThousandSeparator := ',';
  DecimalSeparator := '.';
  CurrencyDecimals := 2;
}
  DateSeparator := '/';
  LongDateFormat := 'dd/mm/yyyy hh:nn:ss';
  TimeSeparator := ':';
  ShortDateFormat := 'dd/mm/yyyy';
  LongTimeFormat := 'hh:nn:ss';

  ShortMonthNames[1] := ('Jan');
  ShortMonthNames[2] := ('Fev');
  ShortMonthNames[3] := ('Mar');
  ShortMonthNames[4] := ('Abr');
  ShortMonthNames[5] := ('Mai');
  ShortMonthNames[6] := ('Jun');
  ShortMonthNames[7] := ('Jul');
  ShortMonthNames[8] := ('Ago');
  ShortMonthNames[9] := ('Set');
  ShortMonthNames[10] := ('Out');
  ShortMonthNames[11] := ('Nov');
  ShortMonthNames[12] := ('Dez');

  LongMonthNames[1] := ('Janeiro');
  LongMonthNames[2] := ('Fevereiro');
  LongMonthNames[3] := ('Março');
  LongMonthNames[4] := ('Abril');
  LongMonthNames[5] := ('Maio');
  LongMonthNames[6] := ('Junho');
  LongMonthNames[7] := ('Julho');
  LongMonthNames[8] := ('Agosto');
  LongMonthNames[9] := ('Setembro');
  LongMonthNames[10] := ('Outubro');
  LongMonthNames[11] := ('Novembro');
  LongMonthNames[12] := ('Dezembro');
end;

end.
