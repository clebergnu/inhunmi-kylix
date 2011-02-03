{InhunmiConsumoAdicionaDM.pas - Inhunmi "Add Expenses" Data Module

 Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

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

unit InhConsumoAdicionaDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhBiblio, FMTBcd;

type
  TConsumoAdicionaDM = class(TDataModule)
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    ConsumoAdicionaDSet: TSQLDataSet;
    ProdutoDSetdescricao: TStringField;
    ProdutoDSetpreco_venda: TFloatField;
    ProdutoDSetid: TIntegerField;
  private
    { Private declarations }
  public
    function  DMOpen () : boolean;
    procedure DMClose();
  end;

implementation

uses InhMainDM;

{$R *.xfm}

function TConsumoAdicionaDM.DMOpen: boolean;
begin
   if (InhDataSetOpenMaster(ProdutoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   Result := True;
end;


procedure TConsumoAdicionaDM.DMClose;
begin
   ProdutoDSet.Close;
end;



end.
