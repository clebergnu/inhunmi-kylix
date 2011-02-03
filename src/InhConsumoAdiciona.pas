{InhunmiConsumoAdiciona.pas - Inhunmi "Add Expenses" Form

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

unit InhConsumoAdiciona;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QStdCtrls, QMask, QExtCtrls, SQLExpr,
  InhBiblio, FMTBcd, DB, InhFiltroPadrao, Qt, InhLookupPadrao, InhConsumoAdicionaDM,
  InhCaixaAtendimentoDM, InhConfig;

const
   icaInicial = 'Adicionar consumo em %s %s %s'; // tipo, 'nr.' ou 'cod.', valor de numero ou codigo
   icaProduto = 'Adicionar %s em %s %s %s'; // produto, tipo, 'nr.' ou 'cod.', valor de numero ou codigo
   icaProdutoQuantidade = 'Adicionar %s %s(s) em %s %s %s'; // quantidade, produto, tipo, 'nr.' ou 'cod.', valor de numero ou codigo
   icaProdutoInexistente = 'Produto %s não existente ou não disponível para venda'; //produto.id
   icaQuantidadeInexistente = 'Favor informar quantos(as) %s adicionar'; //produto.descricao

type
  TInhConsumoAdicionaForm = class(TForm)
    AdicionarButton: TButton;
    ProdutoButton: TButton;
    Label1: TLabel;
    ProdutoEdit: TEdit;
    QuantidadeEdit: TEdit;
    ValorEdit: TEdit;
    procedure ProdutoEditExit(Sender: TObject);
    procedure AdicionarButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure QuantidadeEditExit(Sender: TObject);
    procedure ProdutoEditKeyPress(Sender: TObject; var Key: Char);
    procedure QuantidadeEditKeyPress(Sender: TObject; var Key: Char);
  private
    PortaConsumoID : integer;
    DataModule : TConsumoAdicionaDM;
    AtendimentoDataModule : TCaixaAtendimentoDM;
  public
    procedure Run (PortaConsumoID : integer);
    procedure Clear();
    procedure SetStatus();
    procedure AdicionaConsumo();
  end;

function InhConsumoAdicionaFormNew(AOwer : TComponent;
                                   AtendimentoDataModule : TCaixaAtendimentoDM) : TInhConsumoAdicionaForm;

implementation

uses InhMainDM, InhCaixaAtendimento, InhDlgUtils;

{$R *.xfm}

function InhConsumoAdicionaFormNew(AOwer : TComponent;
                                   AtendimentoDataModule : TCaixaAtendimentoDM) : TInhConsumoAdicionaForm;
var
   MyForm : TInhConsumoAdicionaForm;
begin
   MyForm := TInhConsumoAdicionaForm.Create(AOwer);

   MyForm.DataModule := TConsumoAdicionaDM.Create(AOwer);
   MyForm.AtendimentoDataModule := AtendimentoDataModule;

   if (MyForm.DataModule.DMOpen() = false) then
      InhDlgRecordNotApplied ();

   Result := MyForm;
end;

procedure TInhConsumoAdicionaForm.ProdutoEditExit(Sender: TObject);
begin
   if (ProdutoEdit.Text <> '') and (InhEditCheckForInt (ProdutoEdit)) then
      begin
         DataModule.ProdutoDSet.Locate('id', ProdutoEdit.Text, []);
         //DataModule.ProdutoDSet.FindKey([Trim(ProdutoEdit.Text)]);
         SetStatus();
      end
   else
      SetStatus();
end;

procedure TInhConsumoAdicionaForm.AdicionarButtonClick(Sender: TObject);
begin
   if not (DataModule.ProdutoDSet.Locate('id', ProdutoEdit.Text, [])) then
   //DataModule.ProdutoDSet.FindKey([ProdutoEdit.Text])) then
      begin
         InhDlg ('Produto não existente ou não disponível para venda.');
         ProdutoEdit.SetFocus;
         exit;
      end
   else if (QuantidadeEdit.Text = '') then
      begin
         InhDlg ('Favor especificar quantidade.');
         QuantidadeEdit.SetFocus;
         exit;
      end
   else
      begin
         AdicionaConsumo ();
         AtendimentoDataModule.PortaConsumoUpdateAll ();
         Clear();
      end;
end;

procedure TInhConsumoAdicionaForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if Key = Key_Escape then
      Close;
end;

procedure TInhConsumoAdicionaForm.Clear();
begin
   ProdutoEdit.Text := '';
   QuantidadeEdit.Text := '';
   ProdutoEdit.SetFocus;
   SetStatus();
end;

procedure TInhConsumoAdicionaForm.AdicionaConsumo();
const
   QueryFormat = 'INSERT INTO consumo (dono, produto, produto_quantidade, valor, datahora_inicial, departamento_venda, usuario) VALUES (%u, %s, %s, %s * %s, %s, %s, %s)';
begin
   // Ir para o porta_consumo segundo PortaConsumoId
   AtendimentoDataModule.PortaConsumoDSet.Refresh;
   if not (AtendimentoDataModule.PortaConsumoDSet.Locate('id', PortaConsumoId, [])) then
   //AtendimentoDataModule.PortaConsumoDSet.FindKey([PortaConsumoId])) then
      begin
         InhDlg (AtendimentoDataModule.PortaConsumoDSet.FieldByName('tipo').AsString +
                 ' não está mais disponível, possivelmente está sendo fechado(a).');
         Close();
         exit;
      end;
   // Assegure-se de que o porta_consumo tem "status" = "Aberto"
   if (AtendimentoDataModule.PortaConsumoDSet.FieldByName('status').AsString <> 'Aberto') then
      begin
         InhDlg (AtendimentoDataModule.PortaConsumoDSet.FieldByName('tipo').AsString +
                 ' não está aberto(a), impossível adicionar consumo.');
         Close();
         exit;
      end;

   with DataModule.ConsumoAdicionaDSet do
      begin
         CommandText := Format(QueryFormat,
                              [PortaConsumoId,
                               ProdutoEdit.Text,
                               QuantidadeEdit.Text,
                               DataModule.ProdutoDSet.FieldByName('preco_venda').AsString,
                               QuantidadeEdit.Text,
                               'NULL',
                               LocalConfig.ReadString('Atendimento', 'DepartamentoVenda', 'NULL'),
                               InhAccess.id]);
         ExecSQL(True);
      end;
end;

procedure TInhConsumoAdicionaForm.SetStatus();
var
   Tipo : String;
   Id : String;
   Produto : String;
   Quantidade : String;
   Valor : real;

   ProdutoOk : boolean;
begin
   Tipo := AtendimentoDataModule.PortaConsumoDSet.FieldByName('tipo').AsString;
   Id := AtendimentoDataModule.PortaConsumoDSet.FieldByName('id').AsString;
   Produto := DataModule.ProdutoDSet.FieldByName('descricao').AsString;
   Quantidade := QuantidadeEdit.Text;

   // --- BLOCO ProdutoOk --- //
   ProdutoOk := False;
   if (ProdutoEdit.Text <> '') then
      if (InhEditCheckForInt (ProdutoEdit)) then
         if (DataModule.ProdutoDSet.FindKey ([string(ProdutoEdit.Text)])) then
            ProdutoOk := True;
   // --- BLOCO ProdutoOk --- //

   if (not ProdutoOk) then
      begin
         AdicionarButton.Caption := Format (icaProdutoInexistente, [ProdutoEdit.Text]);
         ValorEdit.Text := '';
      end

   else if (ProdutoOk) and (QuantidadeEdit.Text = '') then
      begin
         AdicionarButton.Caption := Format (icaProduto, [Produto, Tipo, 'código', Id]);
         ValorEdit.Text := '';
      end

   else if (ProdutoOk) and (QuantidadeEdit.Text <> '') then
      begin
      AdicionarButton.Caption := Format (icaProdutoQuantidade, [Quantidade, Produto, Tipo, 'código', Id]);
      Valor := DataModule.ProdutoDSet.FieldByName('preco_venda').AsCurrency * (StrToFloat(QuantidadeEdit.Text));
      ValorEdit.Text := Format ('R$ %.2n', [Valor]);
      end
   else
      begin
         AdicionarButton.Caption := Format (icaInicial, [Tipo, 'código', Id]);
         ValorEdit.Text := '';
      end;
end;

procedure TInhConsumoAdicionaForm.ProdutoButtonClick(Sender: TObject);
begin
   if (InhLookupFromDataSource (DataModule.ProdutoDSource, 'descricao') <> mrOk) then
      exit;
   ProdutoEdit.Text := DataModule.ProdutoDSet.FieldByName('id').AsString;
   DataModule.ProdutoDSet.Filtered := False;
   QuantidadeEdit.SetFocus;
   SetStatus();
end;

procedure TInhConsumoAdicionaForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Clear();
   SetFocus;
end;

procedure TInhConsumoAdicionaForm.QuantidadeEditExit(Sender: TObject);
begin
   SetStatus();
end;

procedure TInhConsumoAdicionaForm.ProdutoEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   // Suporte para ao digitar letras, abrir o LookUp de produtos ja contendo
   // a primeira letra digitada, BTW, FIX-IT!
   //if (Key in ['a'..'z']) or (Key in ['a'..'z']) then ProdutoButton.Click;
   if (Key = #13) then
      if (ProdutoEdit.Text = '') or (ProdutoEdit.Text = '0') then
         ProdutoButton.Click
      else
         Self.FocusControl(QuantidadeEdit);
end;

procedure TInhConsumoAdicionaForm.QuantidadeEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #13) then
      begin
         if (QuantidadeEdit.Text = '') or (QuantidadeEdit.Text = '0') then
            QuantidadeEdit.Text := '1';
         Self.FocusControl(AdicionarButton);
         QuantidadeEditExit(QuantidadeEdit);
      end;
end;

procedure TInhConsumoAdicionaForm.Run(PortaConsumoID: integer);
begin
   Self.PortaConsumoID := PortaConsumoID;
   ShowModal;
end;

end.
