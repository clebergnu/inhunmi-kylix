unit InhConsumoCompostoDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QGrids, QDBGrids, QStdCtrls, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS;

procedure InhConsumoCompostoDlgOpen (Id : String; Produto : String);

type
  TInhConsumoCompostoDlgForm = class(TForm)
    ProdutoEdit: TEdit;
    Label1: TLabel;
    DBGrid1: TDBGrid;
    Label2: TLabel;
    DBGrid2: TDBGrid;
    ComposicaoDSet: TSQLClientDataSet;
    ConsumoDSet: TSQLClientDataSet;
    ComposicaoDSource: TDataSource;
    ConsumoDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    Id : String;
    { Public declarations }
  end;

var
  InhConsumoCompostoDlgForm: TInhConsumoCompostoDlgForm;

implementation

{$R *.xfm}

procedure InhConsumoCompostoDlgOpen (Id : String; Produto : String);
begin
   if (InhConsumoCompostoDlgForm = nil) then
      InhConsumoCompostoDlgForm := TInhConsumoCompostoDlgForm.Create(Application);
   InhConsumoCompostoDlgForm.Id := Id;
   InhConsumoCompostoDlgForm.ProdutoEdit.Text := Produto;
   InhConsumoCompostoDlgForm.ShowModal;
end;

procedure TInhConsumoCompostoDlgForm.FormActivate(Sender: TObject);
begin
   ComposicaoDSet.Close;
   ComposicaoDSet.Params[0].Value := Self.Id;
   ComposicaoDSet.Open;
end;

end.
