unit InhLookupPadrao;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QButtons, QStdCtrls, QGrids, QDBGrids, DB, DBLocalS, InhBiblio, Qt;

function InhLookupFromDataSource (DataSource : TDataSource; Campo : String) : TModalResult;

type
  TInhLookupPadraoForm = class(TForm)
    GroupBox1: TGroupBox;
    TextoEdit: TEdit;
    GroupBox2: TGroupBox;
    OkButton: TSpeedButton;
    CancelarButton: TSpeedButton;
    ResultadosDbGrid: TDBGrid;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelarButtonClick(Sender: TObject);
    procedure ResultadosDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TextoEditChange(Sender: TObject);
    procedure TextoEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
     Campo : String;
    { Public declarations }
  end;

var
  InhLookupPadraoForm: TInhLookupPadraoForm;

implementation

{$R *.xfm}

function InhLookupFromDataSource (DataSource : TDataSource; Campo : String) : TModalResult;
var
   Form : TInhLookupPadraoForm;
begin
   Form := TInhLookupPadraoForm.Create(Application);
   Form.ResultadosDbGrid.DataSource := DataSource;
   Form.Campo := Campo;
   Result := Form.ShowModal;
   Form.Free;
end;

procedure TInhLookupPadraoForm.OkButtonClick(Sender: TObject);
begin
   Self.ModalResult := mrOk;
end;

procedure TInhLookupPadraoForm.CancelarButtonClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TInhLookupPadraoForm.ResultadosDbGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((Key = Key_Return) or (Key = Key_Enter)) then
      Self.ModalResult := mrOk;
end;

procedure TInhLookupPadraoForm.TextoEditChange(Sender: TObject);
begin
   InhFilterExecute (Self.ResultadosDbGrid.DataSource.Dataset,
                     Self.Campo, TextoEdit.Text, ifoTexto);
end;

procedure TInhLookupPadraoForm.TextoEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if ((Key = Key_Return) or (Key = Key_Enter)) then
      Self.ModalResult := mrOk
   else if (Key = Key_Down) then
      begin
         ResultadosDBGrid.SetFocus;
         ResultadosDBGrid.DataSource.DataSet.Next;
      end
   else if (Key = Key_Up) then
      begin
         ResultadosDBGrid.SetFocus;
         ResultadosDBGrid.DataSource.DataSet.Prior;
      end
end;

procedure TInhLookupPadraoForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Shift = []) and ((Key = Key_Enter) or (Key = Key_Return)) then
      OkButton.Click
   else if (Shift = []) and (Key = Key_Escape) then
      CancelarButton.Click;
end;

end.
