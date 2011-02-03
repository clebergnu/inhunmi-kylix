{InhProduto.pas - Description pending

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

unit InhProduto;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QExtCtrls, QButtons, QStdCtrls, QMask, InhProdutoDM,
  QGrids, QDBGrids, QComCtrls, InhFiltroPadrao, InhBiblio, InhAjuda,
  QMenus, QTypes, QActnList, DB, InhDbForm,

  InhReportProdutoTabelaPrecoVendido, InhReportEstoqueProdutoHistorico;

type
  TInhProdutoForm = class(TInhDbForm)
    IdDbEdit: TDBEdit;
    AtributosGroupBox: TGroupBox;
    TipoCompradoDbCheckBox: TDBCheckBox;
    TipoVendidoDbCheckBox: TDBCheckBox;
    TipoProduzidoDbCheckBox: TDBCheckBox;
    TipoMetaGrupoDbCheckBox: TDBCheckBox;
    TipoGeneralizadoDbCheckBox: TDBCheckBox;
    DescricaoDbEdit: TDBEdit;
    UnidadeDbComboBox: TDBComboBox;
    PrecoVendaDbEdit: TDBEdit;
    Label1: TLabel;
    UnidadeLabel: TLabel;
    DescricaoLabel: TLabel;
    Label2: TLabel;
    GrupoLabel: TLabel;
    GrupoDbLookupComboBox: TDBLookupComboBox;
    EstoqueMinimoLabel: TLabel;
    EstoqueMinimoDbEdit: TDBEdit;
    GroupBox1: TGroupBox;
    DepartamentoCompraDbLookupComboBox: TDBLookupComboBox;
    DepartamentoCompraLabel: TLabel;
    DepartamentoVendaDbLookupComboBox: TDBLookupComboBox;
    DepartamentoVendaLabel: TLabel;
    DepartamentoProducaoLabel: TLabel;
    DepartamentoEstoqueLabel: TLabel;
    DepartamentoProducaoDbLookupComboBox: TDBLookupComboBox;
    DepartamentoEstoqueDbLookupComboBox: TDBLookupComboBox;
    TabelaPrecos: TAction;
    TabeladePreosProdutosVendidos1: TMenuItem;
    Estoque1: TMenuItem;
    HistricoDeEstoque1: TMenuItem;
    DetalhesButton: TButton;
   procedure TabelaPrecoVendidosExecute(Sender : TObject);
   procedure MasterDataSetAfterScroll (DataSet : TDataSet);
   procedure FormShow(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DetalhesButtonClick(Sender: TObject);
    procedure HistricoDeEstoque1Click(Sender: TObject);
  private
    { Private declarations }
  public

  end;

function ProdutoFormNew() : TInhProdutoForm;

implementation

uses InhDbGridUtils, InhProdutoDetalhes;

{$R *.xfm}

function ProdutoFormNew() : TInhProdutoForm;
var
   MyForm : TInhProdutoForm;
begin
   MyForm := TInhProdutoForm.Create(Application);

   if (ProdutoDM = nil) then
      ProdutoDM := TProdutoDM.Create(Application);

   MyForm.DataModule := ProdutoDM;
   ProdutoDM.DbForm := MyForm;

   MyForm.MasterDataSource := ProdutoDM.ProdutoDSource;
   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;

   MyForm.FirstControl := MyForm.DescricaoDbEdit;
//   MyForm.DetailsBox := MyForm.DetailsPageControl;

   MyForm.HelpTopic := 'capitulo_cadastro_produtos';

   Result := MyForm;
end;

procedure TInhProdutoForm.TabelaPrecoVendidosExecute(Sender: TObject);
begin
  inherited;
   InhReportProdutoTabelaPrecoVendidoDlgRun();
end;

procedure TInhProdutoForm.MasterDataSetAfterScroll(DataSet: TDataSet);
begin
   TProdutoDM(DataModule).DMOpen;
end;

procedure TInhProdutoForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhProdutoForm.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

procedure TInhProdutoForm.DetalhesButtonClick(Sender: TObject);
begin
  inherited;
   InhProdutoDetalhesRun (Self, MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

procedure TInhProdutoForm.HistricoDeEstoque1Click(Sender: TObject);
begin
  inherited;
   InhReportEstoqueProdutoHistoricoID(MasterDataSource.DataSet.FieldByName('id').AsInteger, 0);
end;

end.
