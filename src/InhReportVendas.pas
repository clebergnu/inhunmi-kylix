unit InhReportVendas;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

   procedure InhReportResumoVendas (DataInicial : TDateTime; DataFinal : TDateTime);

var
   ListagemStatusVenda : TSQLClientDataSet;

implementation

procedure UpdateListagemStatusVenda (DataInicial : TDateTime;
                                     DataFinal : TDateTime);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (ListagemStatusVenda = nil) then
      begin
         ListagemStatusVenda := TSQLClientDataSet.Create(MainDM.MainConnection);
         ListagemStatusVenda.DBConnection := MainDM.MainConnection;
      end;

   if (ListagemStatusVenda.Active) then ListagemStatusVenda.Close;

   ListagemStatusVenda.CommandText :=
   'SELECT DISTINCT consumo.id as consumo, ' +
   'produto_grupo.id as grupo_id, produto_grupo.descricao as grupo, ' +
   'produto.id as "produto_id", produto.descricao as "produto", ' +
   'SUM(consumo.produto_quantidade) as "quantidade", SUM(consumo.valor) as "valor" ' +
   'FROM produto, produto_grupo, consumo, porta_consumo ' +
   'WHERE produto.grupo = produto_grupo.id AND consumo.produto = produto.id ' +
   'AND consumo.dono = porta_consumo.id ' +
   'AND porta_consumo.datahora_final IS NOT NULL ' +
   'AND porta_consumo.datahora_final BETWEEN ' + DataInicialString + ' AND ' + DataFinalString +
   ' GROUP BY consumo.produto ORDER BY produto.grupo, consumo.produto';

   ListagemStatusVenda.Open;
   ListagemStatusVenda.First;
end;

function InhReportResumoVendasGetVendasProdutos (DataInicial : TDateTime; DataFinal : TDateTime) : string;
var
   ResumoVendasProdutoHeader : String;
   ResumoVendasTotalGrupo : String;
   ResumoVendasTotal : String;

   GrupoAtual : integer;
   GrupoAnterior : integer;

   QuantidadeGrupo : integer;
   ValorGrupo : real;
   QuantidadeTotal : integer;
   ValorTotal : real;
begin
   UpdateListagemStatusVenda (DataInicial, DataFinal);
   if (ListagemStatusVenda.RecordCount <= 0) then exit;

   QuantidadeTotal := 0;
   ValorTotal := 0;

   ResumoVendasProdutoHeader := '    --------   ----------------------------------------   --------   ----------' + InhLineFeed +
                                '    Código     Descrição                                    Qtd.       Valor   ' + InhLineFeed +
                                '    --------   ----------------------------------------   --------   ----------' + InhLineFeed;
   ResumoVendasTotalGrupo :=    '    Total Do Grupo:                                       --------   ----------' + InhLineFeed;

   ResumoVendasTotal :=         '                                                          --------   ----------' + InhLineFeed +
                                '    Total:                                                %8u   %10.2f' + InhLineFeed +
                                '                                                          --------   ----------' + InhLineFeed;
   GrupoAnterior := 0;

   while not (ListagemStatusVenda.Eof) do
      begin
         GrupoAtual := ListagemStatusVenda.FieldValues['grupo_id'];
         QuantidadeGrupo := 0;
         ValorGrupo := 0;

         if (GrupoAtual <> GrupoAnterior) then
               Result := Result + Format ('%d - %s' + InhLineFeed,
                                         [
                                           GrupoAtual,
                                           ListagemStatusVenda.FieldValues['grupo']
                                         ]);

         Result := Result + ResumoVendasProdutoHeader;
         while (GrupoAtual = ListagemStatusVenda.FieldValues['grupo_id']) and not (ListagemStatusVenda.Eof) do
            begin
               QuantidadeGrupo := QuantidadeGrupo + ListagemStatusVenda.FieldByName('quantidade').AsInteger;
               ValorGrupo := ValorGrupo + ListagemStatusVenda.FieldByName('valor').AsFloat;

               Result := Result + Format ('    %8s   %-40s   %8s   %10.2f' + InhLineFeed,
                                         [
                                          ListagemStatusVenda.FieldValues['produto_id'],
                                          ListagemStatusVenda.FieldValues['produto'],
                                          ListagemStatusVenda.FieldValues['quantidade'],
                                          ListagemStatusVenda.FieldByName('valor').AsFloat
                                         ]);
               ListagemStatusVenda.Next;
            end;
         Result := Result + ResumoVendasTotalGrupo + Format ('%57s %8u   %10.2f', ['', QuantidadeGrupo, ValorGrupo]) + InhLineFeed;
         QuantidadeTotal := QuantidadeTotal + QuantidadeGrupo;
         ValorTotal := ValorTotal + ValorGrupo;
         GrupoAnterior := GrupoAtual;
      end;
      Result := Result + InhLineFeed + InhLineFeed + Format (ResumoVendasTotal, [QuantidadeTotal, ValorTotal]) + InhLineFeed;
end;

procedure InhReportResumoVendas (DataInicial : TDateTime; DataFinal : TDateTime);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine80);
   Writeln(TF, 'Resumo de Vendas');
   Writeln(TF, InhLine80);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Data/Hora Inicial: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', DataInicial));
   WriteLn(TF, 'Data/Hora Final:   ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', DataFinal));
   WriteLn(TF, InhLine80);
   WriteLn(TF, '');

   WriteLn(TF, InhReportResumoVendasGetVendasProdutos (DataInicial, DataFinal));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

end.
