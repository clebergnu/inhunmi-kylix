unit InhEncomendaTeleMarketingDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  Variants,

  InhBiblio, InhConfig;

type
  TEncomendaTeleMarketingDM = class(TDataModule)
    ClienteDSet: TSQLClientDataSet;
    ClienteDSource: TDataSource;
    ConsumoDSet: TSQLClientDataSet;
    ConsumoDSource: TDataSource;
    PortaConsumoDSet: TSQLClientDataSet;
    EncomendaDSet: TSQLClientDataSet;
    PortaConsumoDSource: TDataSource;
    EncomendaDSource: TDataSource;
    PortaConsumoDSetid: TIntegerField;
    PortaConsumoDSetnumero: TIntegerField;
    PortaConsumoDSettipo: TStringField;
    PortaConsumoDSetstatus: TStringField;
    PortaConsumoDSetdatahora: TSQLTimeStampField;
    PortaConsumoDSetdatahora_inicial: TSQLTimeStampField;
    PortaConsumoDSetdatahora_final: TSQLTimeStampField;
    PortaConsumoDSetdono: TIntegerField;
    PortaConsumoDSetusuario: TIntegerField;
    PortaConsumoDSetstatus_anterior: TStringField;
    EncomendaDSetdono: TIntegerField;
    EncomendaDSettipo_entrega: TStringField;
    EncomendaDSetlocal_entrega: TStringField;
    EncomendaDSettaxa_entrega: TFloatField;
    EncomendaDSetobservacoes: TStringField;
    EncomendaDSetdatahora_entrega: TSQLTimeStampField;
    EncomendaDSetusuario: TIntegerField;
    ConsumoDSetid: TIntegerField;
    ConsumoDSetdono: TIntegerField;
    ConsumoDSetproduto: TIntegerField;
    ConsumoDSetproduto_quantidade: TIntegerField;
    ConsumoDSetvalor: TFloatField;
    ConsumoDSetusuario: TIntegerField;
    ProdutosDSet: TSQLClientDataSet;
    ProdutosDSource: TDataSource;
    ProdutosDSetid: TIntegerField;
    ProdutosDSettipo_comprado: TStringField;
    ProdutosDSettipo_vendido: TStringField;
    ProdutosDSettipo_produzido: TStringField;
    ProdutosDSettipo_meta_grupo: TStringField;
    ProdutosDSettipo_generalizado: TStringField;
    ProdutosDSetdescricao: TStringField;
    ProdutosDSetunidade: TStringField;
    ProdutosDSetgrupo: TIntegerField;
    ProdutosDSetdepartamento_compra: TIntegerField;
    ProdutosDSetdepartamento_venda: TIntegerField;
    ProdutosDSetdepartamento_producao: TIntegerField;
    ProdutosDSetdepartamento_estoque: TIntegerField;
    ProdutosDSetpreco_venda: TFloatField;
    ProdutosDSetestoque_minimo: TIntegerField;
    ConsumoDSetproduto_descricao: TStringField;
    ConsumoDSettotal: TAggregateField;
    EnderecoDSet: TSQLClientDataSet;
    EnderecoDSource: TDataSource;
    ConsumoDSetdepartamento_venda: TIntegerField;
    ConsumoDSetdatahora_inicial: TSQLTimeStampField;
    procedure ConsumoDSetBeforePost(DataSet: TDataSet);
  private
  public
    procedure ClienteSelecionado (PessoaInstituicaoID : integer);
    procedure CriarEncomenda ();
    procedure AbrirConsumos ();
    procedure DMClose();
  end;

implementation

uses InhEncomendaUtils;

{$R *.xfm}

procedure TEncomendaTeleMarketingDM.AbrirConsumos;
begin
   assert (PortaConsumoDSet.RecordCount = 1);

   if ConsumoDSet.Active then ConsumoDSet.Close;

   if ProdutosDSet.Active then ProdutosDSet.Close;
   ProdutosDSet.Open;

   ConsumoDSet.Params[0].Value := PortaConsumoDSet.FieldByName('id').AsInteger;
   ConsumoDSet.Open;
end;

procedure TEncomendaTeleMarketingDM.ClienteSelecionado(
  PessoaInstituicaoID: integer);
begin

end;

procedure TEncomendaTeleMarketingDM.CriarEncomenda;
begin
   assert (PortaConsumoDSet.RecordCount = 1);

   EncomendaDSet.Params[0].Value := PortaConsumoDSet.FieldByName('id').AsInteger;
   EncomendaDSet.Open;
   EncomendaDSet.Append;
   EncomendaDSet.FieldByName('dono').Value := PortaConsumoDSet.FieldByName('id').AsInteger;
   EncomendaDSet.FieldByName('usuario').Value := InhAccess.id;
end;

procedure TEncomendaTeleMarketingDM.DMClose;
begin
   ClienteDSet.Close;
   ConsumoDSet.Close;

   PortaConsumoDSet.Close;
   EncomendaDSet.Close;
end;

procedure TEncomendaTeleMarketingDM.ConsumoDSetBeforePost(
  DataSet: TDataSet);
var
   ValorProduto : Currency;
begin
   if DataSet.State in [dsInsert] then
      begin
         DataSet.FieldByName('dono').AsInteger := PortaConsumoDSet.FieldByName('id').AsInteger;
         DataSet.FieldByName('usuario').AsString := InhAccess.id;
         DataSet.FieldByName('datahora_inicial').AsDateTime := Now();
         DataSet.FieldByName('departamento_venda').AsString := LocalConfig.ReadString('Atendimento', 'DepartamentoVenda', '');
      end;

   ValorProduto := StrToCurr(ProdutosDset.Lookup('id', VarArrayOf([DataSet.FieldByName('produto').AsInteger]), 'preco_venda'));
   DataSet.FieldByName('valor').AsCurrency := ValorProduto * DataSet.FieldByName('produto_quantidade').AsInteger;
end;

end.
