unit InhPortaConsumoNovo;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QStdCtrls, QComCtrls, QExtCtrls, QButtons, SQLExpr, InhBiblio,
  DBLocalS;

procedure InhPortaConsumoNovoOpen();
procedure InhPortaConsumoAutomaticosOpen();

type
  TInhPortaConsumoNovoForm = class(TInhOkCancelDlgForm)
    TipoLabel: TLabel;
    TipoComboBox: TComboBox;
    VariosRadioButton: TRadioButton;
    GroupBox1: TGroupBox;
    InicialSpinEdit: TSpinEdit;
    FinalSpinEdit: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    ExcluirInvalidosCheckBox: TCheckBox;
    ExcluirAbertosCheckBox: TCheckBox;
    procedure InicialSpinEditChanged(Sender: TObject;
      NewValue: Integer);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure FinalSpinEditChanged(Sender: TObject; NewValue: Integer);
  private
     PortaConsumosAbertos : TSQLClientDataSet;
     PortaConsumosInvalidos : TSQLClientDataSet;
  public
     procedure UpdatePortaConsumosAbertos (Tipo : String);
     procedure UpdatePortaConsumosInvalidos (Tipo : String);
     function  PortaConsumosAbertosExists(Numero : integer) : boolean;
     function  PortaConsumosInvalidosExists(Numero : integer) : boolean;
  end;

var
  InhPortaConsumoNovoForm: TInhPortaConsumoNovoForm;
  PortaConsumosAutomaticos : TSQLClientDataSet;


  procedure UpdatePortaConsumosAutomaticos();  

implementation

uses InhMainDM, InhDlgUtils;

{$R *.xfm}

procedure InhPortaConsumoNovoOpen();
begin
   if InhPortaConsumoNovoForm = nil then
      InhPortaConsumoNovoForm := TInhPortaConsumoNovoForm.Create(Application);
   InhPortaConsumoNovoForm.Show;
end;

procedure TInhPortaConsumoNovoForm.InicialSpinEditChanged(
  Sender: TObject; NewValue: Integer);
begin
   if (FinalSpinEdit.Value <= NewValue) then
      FinalSpinEdit.Value := NewValue + 1;
end;

procedure TInhPortaConsumoNovoForm.OkSpeedButtonClick(Sender: TObject);
var
   Comando : String;
   Counter : integer;
   Query : TSQLDataSet;
   Inicial : integer;
   Final : integer;
const
   ComandoInicial = 'INSERT INTO porta_consumo (numero, tipo, datahora_inicial) VALUES ';
   ComandoFormatoDados = '(%d, "%s", NULL)';
   ComandoSeparador = ', ';
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;

   Comando := ComandoInicial;

   Inicial := InicialSpinEdit.Value;
   Final := FinalSpinedit.Value;

   UpdatePortaConsumosAbertos (TipoComboBox.Text);
   UpdatePortaConsumosInvalidos (TipoComboBox.Text);

   for Counter := Inicial to Final do
      begin
         if not (PortaConsumosInvalidosExists(Counter) or PortaConsumosAbertosExists(Counter)) then
            begin
               Comando := Comando + Format(ComandoFormatoDados, [Counter, TipoComboBox.Items[TipoComboBox.ItemIndex]]);
               if (Counter < Final) then Comando := Comando + ComandoSeparador;
            end;
      end;


   Query.CommandText := Comando;
   Query.ExecSQL(True);

   Query.Free;
   FreeAndNil(PortaConsumosAbertos);
   FreeAndNil(PortaConsumosInvalidos);
   Close;
end;

procedure InhPortaConsumoAutomaticosOpen();
var
   Query : TSQLDataSet;
begin
   if (InhDlgYesNo('Confirma a criação de todos os Porta-Consumos "automáticos"?') = False) then
      exit;

   UpdatePortaConsumosAutomaticos;
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;

   while not (PortaConsumosAutomaticos.Eof) do
      begin
         if (PortaConsumosAutomaticos.FieldByName('dono').AsInteger > 0) then
            begin
               Query.CommandText := Format('INSERT INTO porta_consumo (numero, tipo, dono, datahora_inicial) VALUES (%d, "%s", %d, NULL)',
                                          [PortaConsumosAutomaticos.FieldByName('numero').AsInteger,
                                           PortaConsumosAutomaticos.FieldByName('tipo').AsString,
                                           PortaConsumosAutomaticos.FieldByName('dono').AsInteger]);
               Query.ExecSQL(True);
            end
         else
            begin
               Query.CommandText := Format('INSERT INTO porta_consumo (numero, tipo, datahora_inicial) VALUES (%d, "%s", NULL)',
                                          [PortaConsumosAutomaticos.FieldByName('numero').AsInteger,
                                           PortaConsumosAutomaticos.FieldByName('tipo').AsString]);
               Query.ExecSQL(True);
            end;

         PortaConsumosAutomaticos.Next;
      end;


   Query.Free;
end;

procedure TInhPortaConsumoNovoForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   Close;
end;

procedure TInhPortaConsumoNovoForm.FinalSpinEditChanged(Sender: TObject;
  NewValue: Integer);
begin
  inherited;
   if (NewValue <= InicialSpinEdit.Value ) then
      InicialSpinEdit.Value := NewValue - 1;
end;

procedure TInhPortaConsumoNovoForm.UpdatePortaConsumosAbertos(Tipo : String);
begin
   if PortaConsumosAbertos = nil then
      begin
         PortaConsumosAbertos := TSQLClientDataSet.Create(InhPortaConsumoNovoForm);
         PortaConsumosAbertos.DBConnection := MainDM.MainConnection;
      end;

   if PortaConsumosAbertos.Active then PortaConsumosAbertos.Close;

   PortaConsumosAbertos.CommandText := 'SELECT numero FROM porta_consumo WHERE status="Aberto" AND tipo="' + Tipo + '"';
   PortaConsumosAbertos.Open;
   PortaConsumosAbertos.First;
end;

procedure UpdatePortaConsumosAutomaticos();
begin
   if PortaConsumosAutomaticos = nil then
      begin
         PortaConsumosAutomaticos := TSQLClientDataSet.Create(InhPortaConsumoNovoForm);
         PortaConsumosAutomaticos.DBConnection := MainDM.MainConnection;
      end;

   if PortaConsumosAutomaticos.Active then PortaConsumosAutomaticos.Close;

   PortaConsumosAutomaticos.CommandText := 'SELECT numero, tipo, dono FROM porta_consumo_fixo WHERE tipo_automatico="Sim" ORDER BY numero';
   PortaConsumosAutomaticos.Open;
   PortaConsumosAutomaticos.First;
end;

procedure TInhPortaConsumoNovoForm.UpdatePortaConsumosInvalidos(Tipo : String);
begin
   if PortaConsumosInvalidos = nil then
      begin
         PortaConsumosInvalidos := TSQLClientDataSet.Create(InhPortaConsumoNovoForm);
         PortaConsumosInvalidos.DBConnection := MainDM.MainConnection;
      end;

   if PortaConsumosInvalidos.Active then PortaConsumosInvalidos.Close;

   PortaConsumosInvalidos.CommandText := 'SELECT numero FROM porta_consumo_fixo WHERE tipo_invalido="Sim" AND tipo="' + Tipo + '"';
   PortaConsumosInvalidos.Open;
end;

function TInhPortaConsumoNovoForm.PortaConsumosAbertosExists(
  Numero: integer): boolean;
begin
   if (ExcluirAbertosCheckBox.Checked) then
      begin
         Result := PortaConsumosAbertos.Locate('numero', VarArrayOf([IntToStr(Numero)]), []);
      end
   else
      Result := False;
end;

function TInhPortaConsumoNovoForm.PortaConsumosInvalidosExists(
  Numero: integer): boolean;
begin
   if (InhPortaConsumoNovoForm.ExcluirInvalidosCheckBox.Checked) then
      begin
         Result := PortaConsumosInvalidos.Locate('numero', VarArrayOf([IntToStr(Numero)]), []);
      end
   else
      Result := False;
end;

end.
