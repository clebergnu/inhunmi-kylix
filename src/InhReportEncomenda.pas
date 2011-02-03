unit InhReportEncomenda;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

type
   TInhReportEncomenda = procedure (IDEncomenda : Integer) of object; 

// Relatorios Disponíveis:
procedure InhReportEncomendaDetailsAndProductsAndProducao (IDEncomenda : Integer);
procedure InhReportEncomendaDetailsAndProducts (IDEncomenda : Integer);
procedure InhReportEncomendaDetails (IDEncomenda : Integer);
procedure InhReportEncomendaProducao (IDEncomenda : Integer);

// Utility Function (kind of callback hooked up to a menu)
procedure InhReportEncomendaByReportID (ReportID : integer; IDEncomenda : integer);

// Exported Functions
function InhReportEncomendaGetDetails (IDEncomenda : integer) : String;
function InhReportEncomendaGetConsumos (IDEncomenda : integer) : string;

var
   Encomenda        : TSQLClientDataSet;
   Telefones        : TSQLClientDataSet;
   ProdutosProducao : TSQLClientDataSet;

implementation

uses
   InhReportPortaConsumo;

procedure InhReportEncomendaByReportID (ReportID : integer; IDEncomenda : integer);
begin
   case ReportID of
      0: InhReportEncomendaDetailsAndProductsAndProducao(IDEncomenda);
      1: InhReportEncomendaDetailsAndProducts(IDEncomenda);
      2: InhReportEncomendaDetails(IDEncomenda);
      3: InhReportEncomendaProducao(IDEncomenda);
   end;
end;

procedure UpdateTelefones (IDPessoaInstituicao : integer);
begin
   if (Telefones = nil) then
      begin
         Telefones := TSQLClientDataSet.Create(MainDM.MainConnection);
         Telefones.DBConnection := MainDM.MainConnection;
      end;

   if (Telefones.Active) then Telefones.Close;

   Telefones.CommandText := 'SELECT CONCAT("(", pessoa_instituicao_telefone.ddd, ") ", pessoa_instituicao_telefone.numero, " (", pessoa_instituicao_telefone.tipo, ")") as telefone ' +
                            'FROM pessoa_instituicao_telefone ' +
                            'WHERE pessoa_instituicao_telefone.dono = ' + IntToStr(IDPessoaInstituicao);
   Telefones.Open;
   Telefones.First;
end;

procedure UpdateEncomenda (IDEncomenda : integer);
begin
   if (Encomenda = nil) then
      begin
         Encomenda := TSQLClientDataSet.Create(MainDM.MainConnection);
         Encomenda.DBConnection := MainDM.MainConnection;
      end;

   if (Encomenda.Active) then Encomenda.Close;

   Encomenda.CommandText := 'SELECT porta_consumo.id, porta_consumo.status, porta_consumo.datahora, ' +
                            'porta_consumo.datahora_inicial, porta_consumo.datahora_final, ' +
                            'encomenda.tipo_entrega, encomenda.local_entrega, encomenda.taxa_entrega, ' +
                            'encomenda.observacoes, encomenda.datahora_entrega, encomenda.usuario, ' +
                            'pessoa_instituicao.nome AS cliente, ' +
                            'porta_consumo.dono as dono ' +
                            'FROM porta_consumo, encomenda, pessoa_instituicao ' +
                            'WHERE porta_consumo.id = encomenda.dono AND porta_consumo.dono = pessoa_instituicao.id ' +
                            'AND porta_consumo.id = ' + IntToStr(IDencomenda);

   Encomenda.Open;
   Encomenda.First;
end;

procedure UpdateProdutosProducao (IDEncomenda : integer);
begin
   if (ProdutosProducao = nil) then
      begin
         ProdutosProducao := TSQLClientDataSet.Create(MainDM.MainConnection);
         ProdutosProducao.DBConnection := MainDM.MainConnection;
      end;

   if (ProdutosProducao.Active) then ProdutosProducao.Close;

   ProdutosProducao.CommandText := 'SELECT departamento.nome as departamento, SUM(consumo.produto_quantidade) as quantidade, ' +
                                   'CONCAT(produto.descricao, " (", produto.unidade, ")") as produto FROM consumo, produto, departamento ' +
                                   'WHERE consumo.produto = produto.id AND produto.departamento_producao = departamento.id ' +
                                   'AND consumo.dono = ' + IntToStr(IDEncomenda) + ' GROUP BY produto ORDER BY departamento, produto';

   ProdutosProducao.Open;
   ProdutosProducao.First;
end;


function InhReportEncomendaGetTelefones (IDPessoaInstituicao : integer) : String;
begin
   Result := '';
   UpdateTelefones(IDPessoaInstituicao);

   if (Telefones.RecordCount = 0) then exit;

   while not (Telefones.Eof) do
      begin
         Result := Result + '      ' + Telefones.FieldByName('telefone').AsString + InhLineFeed;
         Telefones.Next;
      end;
end;



function InhReportEncomendaGetDetails (IDEncomenda : integer) : String;
var
   EntregaDetails : String;
begin
   UpdateEncomenda(IDEncomenda);


   if (Encomenda.FieldByName('tipo_entrega').AsString = 'Sim') then
      EntregaDetails := '================= E N T R E G A ================' + InhLineFeed + InhLineFeed +
                        'End. Entrega: ' + Encomenda.FieldByName('local_entrega').AsString + InhLineFeed +
                        'Taxa Entrega: R$ ' + Format ('%-8.2f', [Encomenda.FieldByName('taxa_entrega').AsFloat]) + InhLineFeed +
                        InhLineFeed + InhLineFeed
   else
      EntregaDetails := InhLineFeed + InhLineFeed;

   Result := '=============== E N C O M E N D A ==============' +  InhLineFeed + InhLineFeed +
             'Código da Encomenda : ' + Encomenda.FieldByName('id').AsString + InhLineFeed +
             'Data/Hora de Entrega:    ' + Encomenda.FieldByName('datahora_entrega').AsString + InhLineFeed +
             'Data/Hora de Abertura:   ' + Encomenda.FieldByName('datahora_inicial').AsString + InhLineFeed +
             'Data/Hora de Fechamento: ' + Encomenda.FieldByName('datahora_final').AsString + InhLineFeed +
             'Status: ' + Encomenda.FieldByName('status').AsString + InhLineFeed +
             'Observações: ' + Encomenda.FieldByName('observacoes').AsString + InhLineFeed + InhLineFeed +
             '================= C L I E N T E ================' +  InhLineFeed +
             'Nome: ' + Encomenda.FieldByName('cliente').AsString + InhLineFeed +
             InhReportEncomendaGetTelefones (Encomenda.FieldByName('dono').AsInteger) + InhLineFeed +
             InhLineFeed + InhLineFeed +
             EntregaDetails;
end;

function InhReportEncomendaGetConsumos (IDEncomenda : integer) : string;
var
   Total : Currency;
   TaxaEntrega : Currency;
begin
   Result := InhReportPortaConsumoGetConsumos (IDEncomenda, Total);

   TaxaEntrega := Encomenda.FieldByName('taxa_entrega').AsCurrency;
   Total := Total + TaxaEntrega;

   if (Encomenda.FieldByName('tipo_entrega').AsString = 'Sim') and (TaxaEntrega > 0) then
         Result := Result +
                   InhLine48SubTotal + InhLineFeed +
                   Format('Taxa de Entrega:%32.2f', [TaxaEntrega]) + InhLineFeed +
                   InhLine48SubTotal + InhLineFeed +
                   Format('Total:%42.2f', [Total]) + InhLineFeed;
end;


function InhReportEncomendaProducaoGetProdutos (IDEncomenda : integer) : String;
var
   EncomendaInfo : String;
   DepartamentoAtual : String;
   DepartamentoAnterior : String;
begin
   UpdateProdutosProducao (IDEncomenda);
   if (ProdutosProducao.RecordCount <= 0) then exit;
   UpdateEncomenda(IDEncomenda);

   EncomendaInfo := InhSingleLine48 + InhLineFeed +
                    'Código da Encomenda : ' + Encomenda.FieldByName('id').AsString + InhLineFeed +
                    'Data/Hora de Entrega: ' + Encomenda.FieldByName('datahora_entrega').AsString + InhLineFeed +
                    'Cliente: ' + Encomenda.FieldByName('cliente').AsString + InhLineFeed;

   DepartamentoAnterior := '';

   while not (ProdutosProducao.Eof) do
      begin
         DepartamentoAtual := ProdutosProducao.FieldValues['departamento'];

         if (DepartamentoAtual <> DepartamentoAnterior) then
               Result := Result + EncomendaInfo +
                         InhSingleLine48 + InhLineFeed +
                         ProdutosProducao.FieldValues['departamento'] + InhLineFeed +
                         InhSingleLine48 + InhLineFeed;

         while (DepartamentoAtual = ProdutosProducao.FieldValues['departamento']) and not (ProdutosProducao.Eof) do
            begin
               Result := Result + Format ('%8s %-39s' + InhLineFeed,
                                         [
                                          ProdutosProducao.FieldValues['quantidade'],
                                          ProdutosProducao.FieldValues['produto']
                                         ]);
               ProdutosProducao.Next;
            end;
         Result := Result + InhLineFeed + InhLineFeed + InhLineFeed;
         DepartamentoAnterior := DepartamentoAtual;
      end;
      Result := Result + InhLineFeed + InhLineFeed;
end;

procedure InhReportEncomendaProducao (IDEncomenda : Integer);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   WriteLn(TF, InhReportEncomendaProducaoGetProdutos(IDEncomenda));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

procedure InhReportEncomendaDetails (IDEncomenda : Integer);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   WriteLn(TF, InhReportEncomendaGetDetails (IDEncomenda));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

procedure InhReportEncomendaDetailsAndProducts (IDEncomenda : Integer);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   WriteLn(TF, InhReportEncomendaGetDetails (IDEncomenda));
   WriteLn(TF, '================ P R O D U T O S ===============' + InhLineFeed);
   WriteLn(TF, InhReportEncomendaGetConsumos (IDEncomenda));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

procedure InhReportEncomendaDetailsAndProductsAndProducao (IDEncomenda : Integer);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   WriteLn(TF, InhReportEncomendaGetDetails (IDEncomenda));
   WriteLn(TF, '================ P R O D U T O S ===============' + InhLineFeed);
   WriteLn(TF, InhReportEncomendaGetConsumos (IDEncomenda));

   WriteLn(TF, InhLineFeed + InhLineFeed +
               '================ P R O D U Ç Ã O ==============='
               + InhLineFeed + InhLineFeed);
   WriteLn(TF, InhReportEncomendaProducaoGetProdutos(IDEncomenda));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

end.
