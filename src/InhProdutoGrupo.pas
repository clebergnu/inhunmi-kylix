{InhProdutoGrupo.pas - Grupos de Produtos Form

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

unit InhProdutoGrupo;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QExtCtrls, QButtons, QStdCtrls, QMask, InhProdutoGrupoDM,
  InhBiblio, QComCtrls, InhAjuda, InhDbForm, QActnList, QTypes, QMenus;

type
  TInhProdutoGrupoForm = class(TInhDbForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    Label1: TLabel;
    DescricaoDbEdit: TDBEdit;
    procedure FormShow(Sender: TObject);
  private
  public
  end;

  function ProdutoGrupoFormNew() : TInhProdutoGrupoForm;

implementation

{$R *.xfm}

function ProdutoGrupoFormNew() : TInhProdutoGrupoForm;
var
   MyForm : TInhProdutoGrupoForm;
begin
   MyForm := TInhProdutoGrupoForm.Create(Application);

   if (ProdutoGrupoDM = nil) then
      ProdutoGrupoDM := TProdutoGrupoDM.Create(Application);

   MyForm.DataModule := ProdutoGrupoDM;
   ProdutoGrupoDM.DbForm := MyForm;

   MyForm.MasterDataSource := ProdutoGrupoDM.ProdutoGrupoDSource;

   MyForm.FirstControl := MyForm.DescricaoDbEdit;

   MyForm.HelpTopic := 'capitulo_cadastro_grupos_produtos';

   Result := MyForm;
end;

procedure TInhProdutoGrupoForm.FormShow(Sender: TObject);
begin
  inherited;
   TProdutoGrupoDM(DataModule).DMOpen;
end;

end.
