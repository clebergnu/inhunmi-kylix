{Inhunmi.dpr - Inhunmi Instituicao Data Editing Form

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

unit InhInstituicao;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QExtCtrls, QButtons, InhInstituicaoDM, QGrids,
  QDBGrids, QStdCtrls, QMask, QComCtrls, InhBiblio, InhAjuda, InhDbForm,
  QActnList, QTypes, QMenus, DB;

type
  TInhInstituicaoForm = class(TInhDbForm)
    IdDbEdit: TDBEdit;
    NomeDbEdit: TDBEdit;
    IdLabel: TLabel;
    NomeLabel: TLabel;
    GroupBox: TGroupBox;
    TipoDbComboBox: TDBComboBox;
    CGCDbEdit: TDBEdit;
    TipoLabel: TLabel;
    CGCLabel: TLabel;
    DetailsPageControl: TPageControl;
    TelefoneTabSheet: TTabSheet;
    TelefoneDbGrid: TDBGrid;
    EnderecoTabSheet: TTabSheet;
    EnderecoDbGrid: TDBGrid;
    EMailTabSheet: TTabSheet;
    EMailDbGrid: TDBGrid;
    ContatoTabSheet: TTabSheet;
    ContatoDbGrid: TDBGrid;
    ClienteGroupBox: TGroupBox;
    ClienteDBCheckBox: TDBCheckBox;
    ClienteVipDBCheckBox: TDBCheckBox;
    ClientePendenteDBCheckBox: TDBCheckBox;
    ColaboradorGroupBox: TGroupBox;
    FornecedorDBCheckBox: TDBCheckBox;
    procedure DetailsPageControlPageChanging(Sender: TObject;
      NewPage: TTabSheet; var AllowChange: Boolean);
    procedure HelpButtonClick(Sender: TObject);
    procedure DBGridDetailConfirmDelete(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MasterDataSetAfterScroll(DataSet : TDataSet);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public

end;

function InstituicaoFormNew () : TInhInstituicaoForm;

implementation

uses  InhDbGridUtils;

{$R *.xfm}

function InstituicaoFormNew () : TInhInstituicaoForm;
var
   MyForm : TInhInstituicaoForm;
begin
   MyForm := TInhInstituicaoForm.Create(Application);

   if (InstituicaoDM = nil) then
      InstituicaoDM := TInstituicaoDM.Create(Application);

   MyForm.DataModule := InstituicaoDM;
   InstituicaoDM.DbForm := MyForm;

   MyForm.MasterDataSource := InstituicaoDM.PessoaInstituicaoDSource;
   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.JointDataSource := InstituicaoDM.InstituicaoDSource;

   MyForm.FirstControl := MyForm.NomeDbEdit;
   MyForm.DetailsBox := MyForm.GroupBox;

   MyForm.HelpTopic := 'capitulo_cadastro_instituicoes';

   Result := MyForm;
end;

procedure TInhInstituicaoForm.DetailsPageControlPageChanging(Sender: TObject; NewPage: TTabSheet; var AllowChange: Boolean);
begin
  inherited;
   case NewPage.Tag of
      0 :
         InhDataSetOpenDetail(InstituicaoDM.FoneDSet, InstituicaoDM.PessoaInstituicaoDSet);
      1 :
         InhDataSetOpenDetail(InstituicaoDM.EnderecoDSet, InstituicaoDM.PessoaInstituicaoDSet);
      2 :
         InhDataSetOpenDetail(InstituicaoDM.EMailDSet, InstituicaoDM.PessoaInstituicaoDSet);
      3 :
         InhDataSetOpenDetail(InstituicaoDM.ContatoDSet, InstituicaoDM.PessoaInstituicaoDSet);
   end;
end;

procedure TInhInstituicaoForm.HelpButtonClick(Sender: TObject);
begin
  inherited;
   InhAjudaRun ('capitulo_cadastro_instituicoes');
end;

procedure TInhInstituicaoForm.DBGridDetailConfirmDelete(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

procedure TInhInstituicaoForm.MasterDataSetAfterScroll(DataSet: TDataSet);
var
   AllowPageChange : boolean;
begin
   TInstituicaoDM(DataModule).DMOpen;
   DetailsPageControlPageChanging(Self, DetailsPageControl.ActivePage, AllowPageChange);
end;

procedure TInhInstituicaoForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

end.
