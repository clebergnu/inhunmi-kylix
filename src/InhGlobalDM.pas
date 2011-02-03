{InhGlobalDM.pas - Global Data Used All Around

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

unit InhGlobalDM;

interface

uses
  SysUtils, Classes, QTypes, FMTBcd, DB, SqlExpr,

  InhMainDM, DBClient, Provider, DBLocal, DBLocalS;

type
  TGlobalDM = class(TDataModule)
    ProdutoDSet: TSQLClientDataSet;
  private
    { Private declarations }
  public
    function GetProdutoDSource (): TDataSource;
    { Public declarations }
  end;

var
  GlobalDM: TGlobalDM;

implementation

{$R *.xfm}

{ TGlobalDM }

function TGlobalDM.GetProdutoDSource: TDataSource;
var
   DSource : TDataSource;
begin
   DSource := TDataSource.Create(nil);

   DSource.DataSet := ProdutoDSet;
   Result := DSource;
end;

end.
