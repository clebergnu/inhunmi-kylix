unit InhGerenciaFechamentoPortaConsumos;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QGrids, QDBGrids,
  Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, QMask, QDBCtrls;

type
  TInhGerenciaFechamentoPortaConsumosForm = class(TInhOkCancelDlgForm)
    Label1: TLabel;
    TipoPortaConsumoComboBox: TComboBox;
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    PortaConsumosDSet: TSQLClientDataSet;
    PortaConsumosDSetnumero: TIntegerField;
    PortaConsumosDSetid: TIntegerField;
    PortaConsumosDSettipo: TStringField;
    PortaConsumosDSetconsumos: TFMTBCDField;
    PortaConsumosDSource: TDataSource;
    Label3: TLabel;
    PortaConsumosDSetquantidade: TAggregateField;
    QuantidadeDbEdit: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure TipoPortaConsumoComboBoxChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure InhGerenciaFechamentoPortaConsumosRun ();

implementation

uses InhPortaConsumoUtils, InhMainDM, InhBiblio, InhDlgUtils;

{$R *.xfm}

procedure InhGerenciaFechamentoPortaConsumosRun ();
var
   MyForm : TInhGerenciaFechamentoPortaConsumosForm;
begin
   MyForm := TInhGerenciaFechamentoPortaConsumosForm.Create(nil);

   MyForm.PortaConsumosDSet.Open;
   MyForm.ShowModal;
   MyForm.Free;
end;

procedure TInhGerenciaFechamentoPortaConsumosForm.FormCreate(Sender: TObject);
begin
  inherited;
   InhPortaConsumoTipoComboBoxPopulate(TipoPortaConsumoComboBox);
end;

procedure TInhGerenciaFechamentoPortaConsumosForm.OkSpeedButtonClick(
  Sender: TObject);
var
   Query : TSQLDataSet;  
begin
   if (PortaConsumosDSet.RecordCount > 0) then
      begin
         PortaConsumosDSet.DisableControls;
         Query := TSQLDataSet.Create(nil);
         Query.SQLConnection := MainDM.MainConnection;
         Query.CommandText := 'DELETE FROM porta_consumo WHERE id IN (' +
                              InhArrayOfIntToStrList(InhDataSetFieldToArrayOfInt(TSQLDataSet(PortaConsumosDSet), 'id'), ', ') + ')';
         Query.ExecSQL;
         Query.Free;
      end;
  inherited;
end;

procedure TInhGerenciaFechamentoPortaConsumosForm.TipoPortaConsumoComboBoxChange(
  Sender: TObject);
begin
  inherited;
  if (TipoPortaConsumoComboBox.ItemIndex = 0) then
     PortaConsumosDSet.Filtered := False
  else
     begin
        PortaConsumosDSet.Filter := 'tipo = ' + QuotedStr(TipoPortaConsumoComboBox.Text);
        PortaConsumosDset.Filtered := True;
     end;
end;

end.
