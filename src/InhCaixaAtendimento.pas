{InhunmiCaixaAtendimento.pas - Inhunmi "Teller" Form

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

unit InhCaixaAtendimento;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QStdCtrls, QDBCtrls, InhCaixaAtendimentoDM, QGrids, QDBGrids,
  QTypes, QActnList, DB, InhConsumoAdiciona, QButtons, QComCtrls, InhBiblio,
  InhReport, QMenus, Qt, InhConsumoCompostoDlg, InhConsumoAdicionaDM, QMask,
  InhPortaConsumoLookUpDlg, InhEncomendaLookUpDlg, InhPortaConsumoNovo, InhConfig, SQLExpr,
  InhConsumoPropriedadesDlg, InhPortaConsumoPropriedadesDlg, InhLogger, InhConsumoUtils;

type
  TInhCaixaAtendimentoForm = class(TForm)
    TipoComboBox: TComboBox;
    StatusComboBox: TComboBox;
    Panel1: TPanel;
    PortaConsumoDbGrid: TDBGrid;
    ConsumoDbGrid: TDBGrid;
    SairSpeedButton: TSpeedButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    InformacoesGroupBox: TGroupBox;
    Label5: TLabel;
    DataHoraInicialDbText: TDBText;
    TotalPortaConsumoDBText: TDBText;
    TotalPagamentoDbText: TDBText;
    APagarLabel: TLabel;
    DonoDbText: TDBText;
    Label1: TLabel;
    AtualizarIntervaloTimer: TTimer;
    TipoLabel: TLabel;
    TipoDbText: TDBText;
    Label6: TLabel;
    StatusDbText: TDBText;
    Label7: TLabel;
    DataHoraFinalDBText: TDBText;
    Label8: TLabel;
    DataHoraEntregaDBText: TDBText;
    OpcoesSpeedButton: TSpeedButton;
    SpeedButton3: TSpeedButton;
    AtualizarSpeedButton: TSpeedButton;
    procedure ExitButtonClick(Sender: TObject);
    procedure ConsumoDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure NovoPortaConsumoExecute(Sender: TObject);
    procedure PortaConsumoDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure TipoComboBoxSelect(Sender: TObject);
    procedure StatusComboBoxSelect(Sender: TObject);
    procedure AtualizarSpeedButtonClick(Sender: TObject);
    procedure OpcoesSpeedButtonClick(Sender: TObject);
  private
    ConsumoAdicionaForm : TInhConsumoAdicionaForm;
    PortaConsumoLookupForm : TInhPortaConsumoLookUpDlgForm;
    EncomendaLookupForm : TInhEncomendaLookUpDlgForm;
    DataModule : TCaixaAtendimentoDM;
    procedure AdicionaConsumo();
    procedure NovoBalcao();
  public
  end;

function CaixaAtendimentoFormNew (AOwner : TComponent) : TInhCaixaAtendimentoForm;

implementation

uses InhPortaConsumo, InhMainDM, InhCaixaFechamento, InhMain, InhDlgUtils, InhReportEncomenda;

{$R *.xfm}

function CaixaAtendimentoFormNew (AOwner : TComponent) : TInhCaixaAtendimentoForm;
var
   MyForm : TInhCaixaAtendimentoForm;
begin
   MyForm := TInhCaixaAtendimentoForm.Create(AOwner);

   // Creates DataModule
   MyForm.DataModule := TCaixaAtendimentoDM.Create(AOwner);

   // Create forms that used by this one
   MyForm.ConsumoAdicionaForm := InhConsumoAdicionaFormNew(AOwner, MyForm.DataModule);
   MyForm.PortaConsumoLookupForm := InhPortaConsumoLookUpDlgFormNew (AOwner, MyForm.DataModule.PortaConsumoDSource);
   MyForm.EncomendaLookUpForm := InhEncomendaLookUpDlgFormNew (AOwner, MyForm.DataModule.PortaConsumoDSource);

   MyForm.TipoComboBox.ItemIndex := MyForm.TipoComboBox.Items.IndexOf(GlobalConfig.ReadString('Atendimento', 'TipoPadrao', 'Todos'));
   MyForm.StatusComboBox.ItemIndex := MyForm.StatusComboBox.Items.IndexOf(GlobalConfig.ReadString('Atendimento', 'StatusPadrao', 'Aberto'));

   Result := MyForm;
end;

procedure TInhCaixaAtendimentoForm.NovoBalcao();
begin
   if (InhDlgYesNo ('Deseja criar novo Porta-Consumo tipo Balcão?')) then
      if (InhRunQuery ('INSERT INTO porta_consumo (tipo, datahora_inicial) VALUES (3, NULL)') = 1) then
         begin
           TipoComboBox.ItemIndex := 1;
           StatusComboBox.ItemIndex := 0;
           DataModule.PortaConsumoUpdateCommandText (Self.TipoComboBox.Text, Self.StatusComboBox.Text);
         end;
end;

procedure TInhCaixaAtendimentoForm.ExitButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TInhCaixaAtendimentoForm.ConsumoDbGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
if (TDbGrid(Sender).DataSource.DataSet.RecordCount = 0) then exit;
if (Shift = [ssShift]) and (Key = Key_Delete) then
   begin
      AtualizarIntervaloTimer.Enabled := False;
      InhConsumoDelete(TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsInteger,
                       InhConsumoDSetQuantidadeDescricaoValor(TDbGrid(Sender).DataSource.DataSet));
      DataModule.PortaConsumoUpdateAll();
      AtualizarIntervaloTimer.Enabled := True;
   end
else if (Shift = [ssShift]) and ((Key = Key_Return) or (Key = Key_Enter)) then
   begin
      AtualizarIntervaloTimer.Enabled := False;
      ConsumoPropriedadesDlgNewRun (Self, TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsInteger);
      DataModule.PortaConsumoUpdateAll();
      AtualizarIntervaloTimer.Enabled := True;
   end;
end;

procedure TInhCaixaAtendimentoForm.FormShow(Sender: TObject);
begin
   AtualizarIntervaloTimer.Enabled := True;
   DataModule.DMOpen;
   DataModule.PortaConsumoGoto ('');   
end;

procedure TInhCaixaAtendimentoForm.NovoPortaConsumoExecute(
  Sender: TObject);
begin
   if (InhPortaConsumoNovoForm = nil) then
      InhPortaConsumoNovoForm := TInhPortaConsumoNovoForm.Create(Application);
   InhPortaConsumoNovoForm.ShowModal;
end;

procedure TInhCaixaAtendimentoForm.PortaConsumoDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
var
   CaixaFechamentoForm : TInhCaixaFechamentoForm;
begin
   if (TDBGrid(Sender).DataSource.DataSet.RecordCount = 0) then exit;
   if (Shift = [ssShift]) and ((Key = Key_Enter) or (Key = Key_Return)) then
      begin
         AtualizarIntervaloTimer.Enabled := False;
         PortaConsumoPropriedadesDlgNewRun (Self, TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsInteger);
         DataModule.PortaConsumoUpdateAll();
         AtualizarIntervaloTimer.Enabled := True;
         Key := 0;
      end

   // Mandar porta-consumo para fechamento no caixa
   else if (Shift = []) and (Key = Key_F) then
      begin
        CaixaFechamentoForm := InhMainForm.GetCaixaForm;
        if not Assigned (CaixaFechamentoForm) then
           begin
              InhMainForm.AbrirCaixa.Execute;
              CaixaFechamentoForm := InhMainForm.GetCaixaForm;
           end;

        assert(assigned(CaixaFechamentoForm));
        assert(CaixaFechamentoForm is TInhCaixaFechamentoForm);

        CaixaFechamentoForm.AdicionaPortaConsumo(TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsString,
                                                 'id', TDbGrid(Sender).DataSource.DataSet.FieldByName('tipo').AsString);
        CaixaFechamentoForm.Show;
        DataModule.PortaConsumoGoto('');
        Key := 0;
      end

   // Imprimir Comanda Da Encomenda
   else if ((Shift = [ssCtrl]) and (Key = Key_P)) then
      begin
         if (TDbGrid(Sender).DataSource.DataSet.FieldByName('tipo').AsString = 'Encomenda') then
            InhReportEncomendaDetailsAndProducts (TDbGrid(Sender).DataSource.DataSet.FieldByName('id').AsInteger);
         Key := 0;
      end;
end;

procedure TInhCaixaAtendimentoForm.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Lowercase(Key) = 'a') then AdicionaConsumo()

   else if (Key in ['0'..'9']) then
      begin
         // Decide which lookup dialog to go for

         // Here we go for Encomenda
         if (TipoComboBox.Text = 'Encomenda') then
            if(Self.EncomendaLookUpForm.Run(Key) = True) then
               DataModule.PortaConsumoUpdateAll ()
            else
               InhDlg ('Encomenda Não Localizada.')

         // Here we go for the default one
         else
            if(Self.PortaConsumoLookupForm.Run(Key) = True) then
               DataModule.PortaConsumoUpdateAll ()
            else
               InhDlg ('Porta Consumo Não Localizado.');
      end

   else if (Lowercase(Key) = 'b') then
      NovoBalcao();
end;

procedure TInhCaixaAtendimentoForm.FormCreate(Sender: TObject);
begin
   InhFormDealWithScreen (Self);
   Self.Caption := Self.Caption + ' (' + InhAccess.usuario + ')';
end;

procedure TInhCaixaAtendimentoForm.TipoComboBoxSelect(Sender: TObject);
begin
   DataModule.PortaConsumoUpdateCommandText (Self.TipoComboBox.Text, Self.StatusComboBox.Text);
end;

procedure TInhCaixaAtendimentoForm.StatusComboBoxSelect(Sender: TObject);
begin
   DataModule.PortaConsumoUpdateCommandText (Self.TipoComboBox.Text, Self.StatusComboBox.Text);
end;

procedure TInhCaixaAtendimentoForm.AdicionaConsumo;
begin
   if (DataModule.PortaConsumoDSet.FieldByName('status').AsString = 'Aberto') then
      begin
         // Stop updating porta_consumo list
         AtualizarIntervaloTimer.Enabled := False;
         ConsumoAdicionaForm.Left := 174;
         ConsumoAdicionaForm.Top  := 370;
         ConsumoAdicionaForm.Run(DataModule.PortaConsumoDSet.FieldByName('id').AsInteger);
         // Start updating porta_consumo list
         AtualizarIntervaloTimer.Enabled := True;
      end
   else
      InhDlg ('Porta Consumo deve estar aberto para ter consumos adicionados');
end;

procedure TInhCaixaAtendimentoForm.AtualizarSpeedButtonClick(
  Sender: TObject);
begin
   DataModule.PortaConsumoGoto('');
end;

procedure TInhCaixaAtendimentoForm.OpcoesSpeedButtonClick(Sender: TObject);
begin
   InhDlgNotImplemented();
end;

end.
