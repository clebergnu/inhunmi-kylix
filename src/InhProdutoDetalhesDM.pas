unit InhProdutoDetalhesDM;

interface

uses
  SysUtils, Classes, QTypes, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS;

type
  TProdutoDetalhesDM = class(TDataModule)
    ComposicaoDSet: TSQLClientDataSet;
    EquivalenciaDSet: TSQLClientDataSet;
    RendimentosPerdasDSet: TSQLClientDataSet;
    UltimasComprasDSet: TSQLClientDataSet;
    ComposicaoDSource: TDataSource;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    ComposicaoDSetid: TIntegerField;
    ComposicaoDSetdono: TIntegerField;
    ComposicaoDSetcomposicao: TIntegerField;
    ComposicaoDSetquantidade: TFloatField;
    ProdutosDSet: TSQLClientDataSet;
    ProdutosDSource: TDataSource;
    ComposicaoDSetproduto_nome: TStringField;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
  private
  public
  end;

function InhProdutoDetalhesDMNew (AOwner : TComponent) : TProdutoDetalhesDM;

implementation

{$R *.xfm}

function InhProdutoDetalhesDMNew (AOwner : TComponent) : TProdutoDetalhesDM;
var
   MyDM : TProdutoDetalhesDM;
begin
   MyDM := TProdutoDetalhesDM.Create(AOwner);

   Result := MyDM;
end;

end.
