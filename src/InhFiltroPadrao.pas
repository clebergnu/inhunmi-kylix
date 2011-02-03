unit InhFiltroPadrao;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QButtons, QGrids, QDBGrids, DB, DBLocalS, QActnList, QStdActns,
  QMask, Qt, InhBiblio;

type
  TInhFiltroPadraoForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CamposComboBox: TComboBox;
    CondicaoComboBox: TComboBox;
    DBGrid1: TDBGrid;
    ActionList: TActionList;
    ExecutaProcura: TAction;
    TextoEdit: TMaskEdit;
    OkButton: TSpeedButton;
    CancelarButton: TSpeedButton;
    procedure TextoEditKeyPress(Sender: TObject; var Key: Char);
    procedure OkButtonClick(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CancelarButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
     DataSource : TDataSource;
     FieldNames : array of String;
     procedure SearchExecute ();
  end;

var
  InhFiltroPadraoForm: TInhFiltroPadraoForm;

function  InhSearchFromDataSource (DataSource : TDataSource) : TModalResult;

implementation

uses InhDlgUtils;

{$R *.xfm}

function  InhSearchFromDataSource (DataSource : TDataSource) : TModalResult;
var
   DataSet : TDataSet;
   FiltroForm : TInhFiltroPadraoForm;
   I : integer;
begin
   FiltroForm := TInhFiltroPadraoForm.Create (DataSource);
   FiltroForm.DataSource := DataSource;
   DataSet := FiltroForm.DataSource.DataSet;
   SetLength(FiltroForm.FieldNames, DataSet.FieldCount);
   for I := 0 to DataSet.FieldCount - 1 do
      begin
      if DataSet.Fields[I].DisplayLabel <> '' then
         FiltroForm.CamposComboBox.Items.Add(DataSet.Fields[I].DisplayLabel)
      else
         begin
            FiltroForm.CamposComboBox.Items.Add(DataSet.Fields[I].FieldName);
         end;
      FiltroForm.FieldNames[I] := DataSet.Fields[I].FieldName;
      end;
   FiltroForm.CamposComboBox.ItemIndex := 0;
   FiltroForm.DBGrid1.DataSource := FiltroForm.DataSource;
   Result := FiltroForm.ShowModal;
   //Clean-up
   SetLength(FiltroForm.FieldNames, 0);
   FiltroForm.Free;
end;

procedure TInhFiltroPadraoForm.SearchExecute ();
var
   Campo : String;
   Field : TField;
   Texto : String;
   Operador : String;
begin
   // Se texto a procurar nao existir, "limpa a procura"
   if TextoEdit.Text = '' then
      begin
         DataSource.DataSet.Filtered := False;
         Exit;
      end;

   // TextoEdit.Texto contem texto, qual campo está selecionado?
   Campo := Self.FieldNames[CamposComboBox.ItemIndex];

   // Filtro não é sensível a caso
   DataSource.DataSet.FilterOptions := [foCaseInsensitive];

   // Pegue um referencia ao TField
   Field := DataSource.DataSet.FieldByName(Campo);

   // Com que tipo de campo estamos lidando?
   // Se for un TIntegerField, tente converter texto para string
   if (Field is TIntegerField) then
      begin
         try
            StrToInt (TextoEdit.Text);
         except
            on EConvertError do
               begin
                  InhDlg ('Este campo requer um valor numérico inteiro');
                  TextoEdit.Text := '';
                  TextoEdit.SetFocus;
                  exit;
               end;
         end;
         // Como temos um numero, nao precisamos de aspas
         Texto := TextoEdit.Text;
      end
      else if (Field is TFloatField) then
      begin
         try
            StrToFloat (TextoEdit.Text);
         except
            on EConvertError do
               begin
                  InhDlg ('Este campo requer um valor numérico');
                  TextoEdit.Text := '';
                  TextoEdit.SetFocus;
                  exit;
               end;
         end;
         // Como temos um numero, nao precisamos de aspas
         Texto := TextoEdit.Text;
      end
   else if (Field is TStringField) then
      // Temos uma string, coloque aspas para nao significar nome
      // de um outro campo
      Texto := QuotedStr(TextoEdit.Text)
   else
      Texto := QuotedStr(TextoEdit.Text);
   case CondicaoComboBox.ItemIndex of
      0 : Operador := ' = ';
      1 : Operador := ' <> ';
   end;
   DataSource.DataSet.Filter := Campo + Operador + Texto;
   DataSource.DataSet.Filtered := True;
end;

procedure TInhFiltroPadraoForm.TextoEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #13 then
      Self.SearchExecute();
end;

procedure TInhFiltroPadraoForm.OkButtonClick(Sender: TObject);
begin
   Self.ModalResult := mrOk;
end;

procedure TInhFiltroPadraoForm.DBGrid1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((Key = Key_Return) OR (Key = Key_Enter)) then
      Self.ModalResult := mrOk;
end;

procedure TInhFiltroPadraoForm.CancelarButtonClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

end.
