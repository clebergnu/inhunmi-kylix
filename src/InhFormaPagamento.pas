{InhFormaPagamento.pas - Description pending

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

unit InhFormaPagamento;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QExtCtrls, QButtons, QStdCtrls, QMask, InhMainDM, DB,
  SqlExpr, InhBiblio, QComCtrls, InhAjuda, InhDbForm, QActnList, QTypes,
  QMenus;

type
  TInhFormaPagamentoForm = class(TInhDbForm)
    IdDbEdit: TDBEdit;
    DescricaoDbEdit: TDBEdit;
    IdLabel: TLabel;
    DescricaoLabel: TLabel;
    TipoTrocoLabel: TLabel;
    TipoTrocoDbComboBox: TDBComboBox;
    DBCheckBox1: TDBCheckBox;
    procedure FormShow(Sender: TObject);
  private
  public
  end;

function FormaPagamentoFormNew() : TInhFormaPagamentoForm;

implementation

uses InhFormaPagamentoDM;

{$R *.xfm}

function FormaPagamentoFormNew() : TInhFormaPagamentoForm;
var
   MyForm : TInhFormaPagamentoForm;
begin
   MyForm := TInhFormaPagamentoForm.Create(Application);

   if (FormaPagamentoDM = nil) then
      FormaPagamentoDM := TFormaPagamentoDM.Create(Application);

   MyForm.DataModule := FormaPagamentoDM;
   FormaPagamentoDM.DbForm := MyForm;

   MyForm.MasterDataSource := FormaPagamentoDM.FormaPagamentoDSource;

   MyForm.FirstControl := MyForm.DescricaoDbEdit;

   MyForm.HelpTopic := 'capitulo_cadastro_formas_pagamentos';

   Result := MyForm;
end;


procedure TInhFormaPagamentoForm.FormShow(Sender: TObject);
begin
  inherited;
   TFormaPagamentoDM(DataModule).DMOpen;
end;

end.
