{Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA 02111-1307, USA.
}

unit InhFiscalReimprime;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QStdCtrls, QMask, QExtCtrls, SQLExpr,
  InhBiblio, DB, InhFiltroPadrao, Qt, InhLookupPadrao, InhConsumoAdicionaDM,
  InhCaixaAtendimentoDM, InhConfig, InhDlgUtils, InhFiscalUtils, InhMainDM;

procedure FiscalReimprimeUltimoCoupon();

implementation

procedure FiscalReimprimeUltimoCoupon();
var
   Date        : String;
   DateTime    : TDateTime;
   QueryDateDS : TSQLDataSet;

   QueryDS  : TSQLDataSet;
   IDs      : CouponArray;
   Contador : Integer;
begin
   // Date is used to get the latest closing operation by this user
   QueryDateDS := TSQLDataSet.Create(MainDM.MainConnection);
   QueryDateDS.SQLConnection := MainDM.MainConnection;
   QueryDateDS.CommandText := format('SELECT datahora FROM porta_consumo_pagamento WHERE (usuario = %s) ' +
                                     'ORDER BY datahora DESC LIMIT 1',
                                     [InhAccess.id]);
   QueryDateDS.Open();
   DateTime := QueryDateDS.FieldByName('datahora').AsDateTime;
   Date := DateTimeToSQLTimeStampString(DateTime);
   FreeAndNil(QueryDateDS);

   // IDs will hold the integers
   Contador := 0;
   SetLength(IDs, Contador); // Create empty array

   // QueryDS will get us the list of IDs in that were last closed by this user
   QueryDS := TSQLDataSet.Create(MainDM.MainConnection);
   QueryDS.SQLConnection := MainDM.MainConnection;
   QueryDS.CommandText := format('SELECT dono FROM porta_consumo_pagamento WHERE (usuario = %s) AND (datahora = %s)',
                                 [InhAccess.id, Date]);

   QueryDS.Open();
   while not (QueryDS.Eof) do
      begin
         Contador := Contador + 1;
         SetLength(IDs, Contador); // Increase array's size
         IDs[Contador - 1] := QueryDS.FieldByName('dono').AsInteger;

         QueryDS.Next();
      end;
   FreeAndNil(QueryDS);

   if (Contador > 0) then
      InhFiscalQueueCoupon(IDs);

end;

end.
