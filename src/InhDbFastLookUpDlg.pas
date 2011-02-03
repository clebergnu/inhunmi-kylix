unit InhDbFastLookUpDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QGrids, QDBGrids, QStdCtrls, QExtCtrls, QButtons, Qt, DB,
  InhBiblio;

type
  TInhDbFastLookUpDlgForm = class(TInhOkCancelDlgForm)
    PesquisaGroupBox: TGroupBox;
    ResultadosGroupBox: TGroupBox;
    TextoEdit: TEdit;
    CamposComboBox: TComboBox;
    ResultadosDBGrid: TDBGrid;
    procedure TextoEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TextoEditChange(Sender: TObject);
    procedure PrepareFieldNames;
  private
     FieldNames : array of String;
  public
  end;

  function InhDbFastLookUpDlgNew(AOwner : TComponent;
                                 DataSource : TDataSource;
                                 DataSourceSearchIndex : Integer) : TInhDbFastLookUpDlgForm;

implementation

{$R *.xfm}

function InhDbFastLookUpDlgNew(AOwner : TComponent;
                               DataSource : TDataSource;
                               DataSourceSearchIndex : Integer) : TInhDbFastLookUpDlgForm;
var
   MyForm : TInhDbFastLookUpDlgForm;
begin
   MyForm := TInhDbFastLookUpDlgForm.Create(AOwner);

   MyForm.ResultadosDBGrid.DataSource := DataSource;

   MyForm.PrepareFieldNames;
   MyForm.CamposComboBox.ItemIndex := DataSourceSearchIndex;

   Result := MyForm;
end;

procedure TInhDbFastLookUpDlgForm.TextoEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
   if (Key = Key_Down) then
      begin
         ResultadosDBGrid.SetFocus;
         ResultadosDBGrid.DataSource.DataSet.Next;
      end
   else if (Key = Key_Up) then
      begin
         ResultadosDBGrid.SetFocus;
         ResultadosDBGrid.DataSource.DataSet.Prior;
      end
   else if (Key = Key_PageDown) then
      begin
         ResultadosDBGrid.SetFocus;
         ResultadosDBGrid.DataSource.DataSet.MoveBy(5);
      end
   else if (Key = Key_PageUp) then
      begin
         ResultadosDBGrid.SetFocus;
         ResultadosDBGrid.DataSource.DataSet.MoveBy(-5);
      end;
end;

procedure TInhDbFastLookUpDlgForm.TextoEditChange(Sender: TObject);
var
   FilterType : TInhFilterOperations;   
begin
  inherited;
   if (ResultadosDbGrid.DataSource.Dataset.Fields[CamposComboBox.ItemIndex] is TStringField) then
      FilterType := ifoTexto
   else
      FilterType := ifoIgual;

   InhFilterExecute (ResultadosDbGrid.DataSource.Dataset,
                     FieldNames[CamposComboBox.ItemIndex],
                     TextoEdit.Text,
                     FilterType);
end;

procedure TInhDbFastLookUpDlgForm.PrepareFieldNames;
var
   I : integer;
begin
   inherited;
   SetLength(FieldNames, ResultadosDbGrid.DataSource.DataSet.FieldCount);
   for I := 0 to ResultadosDbGrid.DataSource.DataSet.FieldCount - 1 do
      begin
         if ResultadosDbGrid.DataSource.DataSet.Fields[I].DisplayLabel <> '' then
            CamposComboBox.Items.Add(ResultadosDbGrid.DataSource.DataSet.Fields[I].DisplayLabel)
         else
            begin
               CamposComboBox.Items.Add(ResultadosDbGrid.DataSource.DataSet.Fields[I].FieldName);
            end;
         FieldNames[I] := ResultadosDbGrid.DataSource.DataSet.Fields[I].FieldName;
      end;
end;

end.
