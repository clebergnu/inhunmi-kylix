unit InhReportProduto;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

// Relatorios Disponíveis:
procedure InhReportTabelaPrecoProdutosVendidos (GrupoInicial : integer;
                                                GrupoFinal   : integer);

var
   ListagemProdutos : TSQLClientDataSet;

implementation

procedure UpdateListagemProdutos (GrupoInicial     : integer;
                                  GrupoFinal       : integer;
                                  TipoComprado     : boolean;
                                  TipoVendido      : boolean;
                                  TipoProduzido    : boolean;
                                  TipoMetaGrupo    : boolean;
                                  TipoGeneralizado : boolean);
begin
   if (ListagemProdutos = nil) then
      begin
         ListagemProdutos := TSQLClientDataSet.Create(MainDM.MainConnection);
         ListagemProdutos.DBConnection := MainDM.MainConnection;
      end;

   if (ListagemProdutos.Active) then ListagemProdutos.Close;

   ListagemProdutos.CommandText := 'SELECT produto_grupo.id as grupo_id, produto_grupo.descricao as grupo, ' +
                                   'produto.id as produto_id, produto.descricao as produto, produto.unidade as unidade, produto.preco_venda as valor ' +
                                   'FROM produto, produto_grupo ' +
                                   'WHERE produto_grupo.id = produto.grupo ' +
                                   'AND produto_grupo.id BETWEEN ' + IntToStr(GrupoInicial) + ' AND ' + IntToStr(GrupoFinal) + ' ' +
                                   'ORDER BY grupo_id, produto';

   ListagemProdutos.Open;
   ListagemProdutos.First;
end;

function InhReportTabelaPrecoGetProdutosVendidos (GrupoInicial : integer;
                                                  GrupoFinal   : integer) : string;
var
   ProdutoHeader : String;

   GrupoAtual : integer;
   GrupoAnterior : integer;
begin
   UpdateListagemProdutos(GrupoInicial, GrupoFinal, False, True, False, False, False);
   if (ListagemProdutos.RecordCount <= 0) then exit;

   ProdutoHeader := '    --------   --------------------------------------   ----------   ----------' + InhLineFeed +
                    '    Código     Descrição                                    Unid.      Valor   ' + InhLineFeed +
                    '    --------   --------------------------------------   ----------   ----------' + InhLineFeed;

   GrupoAnterior := 0;

   while not (ListagemProdutos.Eof) do
      begin
         GrupoAtual := ListagemProdutos.FieldValues['grupo_id'];
         if (GrupoAtual <> GrupoAnterior) then
            Result := Result + Format ('%d - %s' + InhLineFeed,
                                      [
                                        GrupoAtual,
                                        ListagemProdutos.FieldValues['grupo']
                                      ]);

         Result := Result + ProdutoHeader;
         while (GrupoAtual = ListagemProdutos.FieldValues['grupo_id']) and not (ListagemProdutos.Eof) do
            begin
               Result := Result + Format ('    %8s   %-38s   %10s   %10.4f' + InhLineFeed,
                                         [
                                          ListagemProdutos.FieldValues['produto_id'],
                                          ListagemProdutos.FieldValues['produto'],
                                          ListagemProdutos.FieldValues['unidade'],
                                          ListagemProdutos.FieldByName('valor').AsFloat
                                         ]);
               ListagemProdutos.Next;
            end;
         Result := Result + InhLineFeed;
         GrupoAnterior := GrupoAtual;
      end;
      Result := Result + InhLineFeed;
end;

// Relatorio Tipo Tabela de Precos
// Apenas Produtos Vendidos!
procedure InhReportTabelaPrecoProdutosVendidos (GrupoInicial : integer;
                                                GrupoFinal   : integer);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine80);
   Writeln(TF, 'Tabela de Preços - Produtos Vendidos');
   Writeln(TF, InhLine80);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Grupo Inicial: ' + IntToStr(GrupoInicial));
   WriteLn(TF, 'Grupo Final:   ' + IntToStr(GrupoFinal));
   WriteLn(TF, InhLine80);
   WriteLn(TF, '');

   WriteLn(TF, InhReportTabelaPrecoGetProdutosVendidos (GrupoInicial, GrupoFinal));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;





end.
