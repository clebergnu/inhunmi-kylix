unit InhEstoqueTeste;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhEstoqueUtils, InhReportEstoqueProduto, QGrids,
  QDBGrids, DB, Provider, SqlExpr, DBClient, DBLocal, DBLocalS, QDBCtrls,
  InhReportEstoqueProdutoHistorico;

type
  TInhEstoqueTesteForm = class(TForm)
    ProdutoDeptoDbGrid: TDBGrid;
    ProdutoDeptoDSource: TDataSource;
    ProdutoIDEdit: TEdit;
    Button6: TButton;
    Button1: TButton;
    Button2: TButton;
    Button7: TButton;
    Button8: TButton;
    AjusteDbGrid: TDBGrid;
    ProdutoDeptoDSet: TClientDataSet;
    AjusteDSet: TClientDataSet;
    AjusteDSource: TDataSource;
    procedure Button1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhEstoqueTesteForm: TInhEstoqueTesteForm;

implementation

uses InhMainDM;

{$R *.xfm}


procedure TInhEstoqueTesteForm.Button1Click(Sender: TObject);
begin
   InhReportEstoqueProdutoHistoricoID(StrToInt(ProdutoIDEdit.Text), 0);
end;

procedure TInhEstoqueTesteForm.Button6Click(Sender: TObject);
var
   TempDSet : TClientDataSet;
begin
   TempDSet := TClientDataSet.Create(nil);
   TempDSet := InhEstoqueMatrizProdutoDepartamento (StrToInt(ProdutoIDEdit.Text), 0);
   ProdutoDeptoDSet.Data := TempDSet.Data;
   FreeAndNil(TempDSet);
end;

procedure TInhEstoqueTesteForm.Button2Click(Sender: TObject);
var
   TempDSet : TClientDataSet;
begin
   TempDSet := TClientDataSet.Create(nil);
   TempDSet := InhEstoqueMatrizDescritivaAjuste (ProdutoDeptoDSet);
   AjusteDSet.Data := TempDSet.Data;
   FreeAndNil(TempDSet);
end;

end.
