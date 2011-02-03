{InhMain.pas - Inhunmi Main Screen

 Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA 02111-1307, USA.
}

unit InhMain;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QMenus, QTypes, QButtons, QActnList, QExtCtrls, InhBiblio,
  InhReportCaixa, InhAjuda, InhLogger, InhPortaConsumoUtils,

  InhPessoa, InhInstituicao, InhProduto, InhProdutoGrupo, InhDepartamento,
  InhFormaPagamento, InhCompromisso, InhEncomenda, InhPortaConsumoFixo,
  InhEncomendaTeleMarketing, InhReportPendentes, InhCaixaAtendimento,
  InhCaixaFechamento,

  // Cadastro - Movimentos/Ajuste Simples
  InhEstoqueMovimentoEntrada, InhEstoqueMovimentoSaida,
  InhEstoqueAjuste,

  // Cadastro - Movimentos/Ajuste em Grupo
  InhEstoqueMovimentoEntradaGrupo, InhEstoqueMovimentoSaidaGrupo,
  InhEstoqueMovimentoTransferenciaGrupo, InhEstoqueAjusteGrupo,

  InhEstoqueMovimentoTransferencia, InhEstoqueAjusteSimplesDlg,

  InhFiscalUtils, InhFiscalReimprime,

  Qt, QImgList, QComCtrls;

type
  TInhMainForm = class(TForm)
    MainMenu: TMainMenu;
    GrupoCadastroMenu: TMenuItem;
    Produtos1: TMenuItem;
    Pessoal1: TMenuItem;
    FormaDePagamento1: TMenuItem;
    ActionList: TActionList;
    AbrirPessoa: TAction;
    AbrirFormaPagamento: TAction;
    AbrirProduto: TAction;
    Sair: TAction;
    AbrirInstituicao: TAction;
    AbrirAtendimento: TAction;
    Instituies1: TMenuItem;
    AbrirConsumo: TAction;
    AbrirEncomenda: TAction;
    AbrirDepartamento: TAction;
    Departamentos1: TMenuItem;
    Encomendas1: TMenuItem;
    AbrirConfiguracao: TAction;
    AbrirProdutoGrupo: TAction;
    GruposdeProdutos1: TMenuItem;
    AbrirCaixa: TAction;
    GrupoGerenciamentoMenu: TMenuItem;
    Atendimento1: TMenuItem;
    AbrirNovosPortaConsumos: TAction;
    NovosPortaConsumos1: TMenuItem;
    AbrirPortaConsumo: TAction;
    AbrirReportStatusCaixa: TAction;
    GrupoRelatorioMenu: TMenuItem;
    AbrirCaixaMovimentoDlg: TAction;
    AbrirReportResumoVendas: TAction;
    Caixa1: TMenuItem;
    NovoMovimentodeCaixa2: TMenuItem;
    Atendimento2: TMenuItem;
    N2: TMenuItem;
    AbrirPortaConsumoFixo: TAction;
    PortaConsumosFixos1: TMenuItem;
    AbrirNovosPortaConsumosAutomaticos: TAction;
    CriarPortaConsumosAutomticos1: TMenuItem;
    DeletarPCAbertosNaoUsados: TAction;
    AbrirEncomendaTelemarketing: TAction;
    N3: TMenuItem;
    EncomendaTeleMarketing1: TMenuItem;
    ImageList: TImageList;
    FechamentoDePortaConsumos1: TMenuItem;
    Encomendas2: TMenuItem;
    ResumoProduo1: TMenuItem;
    ListagemPorDataHora1: TMenuItem;
    Estoque1: TMenuItem;
    TransfernciaSimples1: TMenuItem;
    MovimentoSimplesEntrada1: TMenuItem;
    MovimentoSimplesSaida1: TMenuItem;
    Estoque2: TMenuItem;
    AbrirEstoqueEntradaSimples: TAction;
    EstoqueMovimentosdeEntrada1: TMenuItem;
    AbrirEstoqueSaidaSimples: TAction;
    AbrirEstoqueTransferenciaSimples: TAction;
    MoimentosdeSada1: TMenuItem;
    Transferncias1: TMenuItem;
    N7: TMenuItem;
    NovaEntradaSimples: TAction;
    NovaSaidaSimples: TAction;
    NovaTransferenciaSimples: TAction;
    NovoAjusteSimples: TAction;
    NovoAjusteSimples1: TMenuItem;
    AbrirEstoqueAjusteSimples: TAction;
    AbrirEstoqueEntradasGrupo: TAction;
    EntradasemGrupo1: TMenuItem;
    AbrirEstoqueSaidasGrupo: TAction;
    AbrirEstoqueTransferenciasGrupo: TAction;
    AbrirEstoqueAjustesGrupo: TAction;
    PageControl: TPageControl;
    EstoqueTabSheet: TTabSheet;
    CadastroTabSheet: TTabSheet;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    RelatoriosTabSheet: TTabSheet;
    SpeedButton7: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label1: TLabel;
    Bevel1: TBevel;
    SpeedButton2: TSpeedButton;
    Label2: TLabel;
    Bevel2: TBevel;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    PontoDeVendaTabSheet: TTabSheet;
    AtendimentoSpeedButton: TSpeedButton;
    SpeedButton3: TSpeedButton;
    CaixaSpeedButton: TSpeedButton;
    N8: TMenuItem;
    SadasemGrupo1: TMenuItem;
    TransfernciasemGrupo1: TMenuItem;
    AjustesemGrupo1: TMenuItem;
    Label3: TLabel;
    Bevel3: TBevel;
    SpeedButton1: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    NovosMovimentos1: TMenuItem;
    MovimentosEmGrupo1: TMenuItem;
    SpeedButton16: TSpeedButton;
    SpeedButton19: TSpeedButton;
    SpeedButton22: TSpeedButton;
    SpeedButton23: TSpeedButton;
    SpeedButton15: TSpeedButton;
    ReportHistoricoEstoque: TAction;
    HistricodoEstoque1: TMenuItem;
    ReportStatusCaixa: TAction;
    ReportResumoVendas: TAction;
    StatusdeCaixa1: TMenuItem;
    ResumoDeVendas1: TMenuItem;
    SpeedButton24: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    SpeedButton17: TSpeedButton;
    SpeedButton27: TSpeedButton;
    SpeedButton28: TSpeedButton;
    SpeedButton30: TSpeedButton;
    SpeedButton32: TSpeedButton;
    SpeedButton33: TSpeedButton;
    SpeedButton18: TSpeedButton;
    AbrirPortaConsumoPorId: TAction;
    AbrirPortaConsumo1: TMenuItem;
    ReportProdutoTabelaPreco: TAction;
    TabeladePreos1: TMenuItem;
    ReportPendentesResumido: TAction;
    RelatriodePendentesResumido1: TMenuItem;
    FiscalReducaoZ: TAction;
    ImpressaoFiscal: TMenuItem;
    FechamentoReduoZ1: TMenuItem;
    FiscalLeituraX: TAction;
    FiscalLeituraX1: TMenuItem;
    FiscalCancelLastCoupon: TAction;
    CancelaltimoCoupon1: TMenuItem;
    FiscalReimpressaoCoupon: TAction;
    ReimpressodeCoupon1: TMenuItem;
    procedure Sair1Click(Sender: TObject);
    procedure AbrirPessoaExecute(Sender: TObject);
    procedure AbrirFormaPagamentoExecute(Sender: TObject);
    procedure AbrirProdutoExecute(Sender: TObject);
    procedure SairExecute(Sender: TObject);
    procedure AbrirInstituicaoExecute(Sender: TObject);
    procedure AbrirAtendimentoExecute(Sender: TObject);
    procedure AbrirEncomendaExecute(Sender: TObject);
    procedure AbrirDepartamentoExecute(Sender: TObject);
    procedure AbrirConfiguracaoExecute(Sender: TObject);
    procedure AbrirProdutoGrupoExecute(Sender: TObject);
    procedure AbrirCompromissoExecute(Sender: TObject);
    procedure AbrirCaixaExecute(Sender: TObject);
    procedure AbrirNovosPortaConsumosExecute(Sender: TObject);
    procedure Contedo1Click(Sender: TObject);
    procedure TelaPrincipal1Click(Sender: TObject);
    procedure AbrirReportStatusCaixaExecute(Sender: TObject);
    procedure AbrirCaixaMovimentoDlgExecute(Sender: TObject);
    procedure AbrirReportResumoVendasExecute(Sender: TObject);
    procedure SobreoInhunmi1Click(Sender: TObject);
    procedure AbrirPortaConsumoFixoExecute(Sender: TObject);
    procedure AbrirNovosPortaConsumosAutomaticosExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AbrirEncomendaTelemarketingExecute(Sender: TObject);
    procedure FormLoaded(Sender: TObject);
    procedure BancodeDados1Click(Sender: TObject);
    procedure FechamentoDePortaConsumos1Click(Sender: TObject);
    procedure ResumoProduo1Click(Sender: TObject);
    procedure ListagemPorDataHora1Click(Sender: TObject);
    procedure HistoricodeProdutos1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure AbrirEstoqueEntradaSimplesExecute(Sender: TObject);
    procedure AbrirEstoqueSaidaSimplesExecute(Sender: TObject);
    procedure AbrirEstoqueTransferenciaSimplesExecute(Sender: TObject);
    procedure NovaEntradaSimplesExecute(Sender: TObject);
    procedure NovaSaidaSimplesExecute(Sender: TObject);
    procedure NovaTransferenciaSimplesExecute(Sender: TObject);
    procedure NovoAjusteSimplesExecute(Sender: TObject);
    procedure AbrirEstoqueAjusteSimplesExecute(Sender: TObject);
    procedure AbrirEstoqueEntradasGrupoExecute(Sender: TObject);
    procedure AbrirEstoqueSaidasGrupoExecute(Sender: TObject);
    procedure AbrirEstoqueTransferenciasGrupoExecute(Sender: TObject);
    procedure AbrirEstoqueAjustesGrupoExecute(Sender: TObject);
    procedure ReportHistoricoEstoqueExecute(Sender: TObject);
    procedure ReportStatusCaixaExecute(Sender: TObject);
    procedure ReportResumoVendasExecute(Sender: TObject);
    procedure AbrirPortaConsumoPorIdExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ReportProdutoTabelaPrecoExecute(Sender: TObject);
    procedure ReportPendentesResumidoExecute(Sender: TObject);
    procedure FiscalReducaoZExecute(Sender: TObject);
    procedure FiscalLeituraXExecute(Sender: TObject);
    procedure FiscalCancelLastCouponExecute(Sender: TObject);
    procedure FiscalReimpressaoCouponExecute(Sender: TObject);
  private
    { Private declarations }
  public
    function GetAtendimentoForm() : TInhCaixaAtendimentoForm;
    function GetCaixaForm() : TInhCaixaFechamentoForm;
  end;

var
  InhMainForm      : TInhMainForm;

  PessoaForm         : TInhPessoaForm;
  InstituicaoForm    : TInhInstituicaoForm;
  ProdutoForm        : TInhProdutoForm;
  ProdutoGrupoForm   : TInhProdutoGrupoForm;
  DepartamentoForm   : TInhDepartamentoForm;
  FormaPagamentoForm : TInhFormaPagamentoForm;
  EncomendaForm      : TInhEncomendaForm;
  CompromissoForm    : TInhCompromissoForm;
  PortaConsumoFixoForm : TInhPortaConsumoFixoForm;
  EncomendaTeleMarketingForm : TInhEncomendaTeleMarketingForm;

  CaixaAtendimentoForm : TInhCaixaAtendimentoForm;
  CaixaFechamentoForm :  TInhCaixaFechamentoForm;

  EstoqueMovimentoEntradaForm       : TInhEstoqueMovimentoEntradaForm;
  EstoqueMovimentoSaidaForm         : TInhEstoqueMovimentoSaidaForm;
  EstoqueMovimentoTransferenciaForm : TInhEstoqueMovimentoTransferenciaForm;
  EstoqueAjusteForm                 : TInhEstoqueAjusteForm;

  EstoqueMovimentoEntradaGrupoForm       : TInhEstoqueMovimentoEntradaGrupoForm;
  EstoqueMovimentoSaidaGrupoForm         : TInhEstoqueMovimentoSaidaGrupoForm;
  EstoqueMovimentoTransferenciaGrupoForm : TInhEstoqueMovimentoTransferenciaGrupoForm;
  EstoqueAjusteGrupoForm                 : TInhEstoqueAjusteGrupoForm;

implementation

uses
  InhMainDM,  InhAcesso, InhConfig, InhPortaConsumoNovo,
  InhCaixaMovimentoDlg, InhReportViewer, InhReportStatusCaixaDlg, InhReportResumoVendasDlg,
  InhReportProdutoTabelaPrecoVendido, InhDlgUtils, InhDbDriverInfo, InhGerenciaFechamentoPortaConsumos,
  InhReportEncomendaProducaoResumoDlg, InhReportEncomendaListagemHoraDlg,
  InhEstoqueTeste, InhEstoqueTranferenciaSimplesDlg, InhEstoqueMovimentoEntradaSimplesDlg, InhEstoqueMovimentoSimplesDlg,
  InhPortaConsumoPropriedadesDlg,

  InhReportEstoqueProdutoHistorico;

{$R *.xfm}

procedure TInhMainForm.Sair1Click(Sender: TObject);
begin
   Application.Terminate;
end;

procedure TInhMainForm.AbrirPessoaExecute(Sender: TObject);
begin
   if not Assigned(PessoaForm) then
      PessoaForm := PessoaFormNew();
   if not PessoaForm.Visible then
      InhFormDealWithScreen(TForm(PessoaForm));
   PessoaForm.Show;
end;

procedure TInhMainForm.AbrirInstituicaoExecute(Sender: TObject);
begin
   if not Assigned(InstituicaoForm) then
      InstituicaoForm := InstituicaoFormNew();
   if not InstituicaoForm.Visible then
      InhFormDealWithScreen(TForm(InstituicaoForm));
   InstituicaoForm.Show;
end;

procedure TInhMainForm.AbrirProdutoExecute(Sender: TObject);
begin
   if not Assigned(ProdutoForm) then
      ProdutoForm := ProdutoFormNew();
   if not ProdutoForm.Visible then
      InhFormDealWithScreen(TForm(ProdutoForm));
   ProdutoForm.Show();
end;

procedure TInhMainForm.AbrirProdutoGrupoExecute(Sender: TObject);
begin
   if not Assigned(ProdutoGrupoForm) then
      ProdutoGrupoForm := ProdutoGrupoFormNew();
   if not ProdutoGrupoForm.Visible then
      InhFormDealWithScreen(TForm(ProdutoGrupoForm));
   ProdutoGrupoForm.Show();
end;

procedure TInhMainForm.AbrirDepartamentoExecute(Sender: TObject);
begin
  if not Assigned(DepartamentoForm) then
     DepartamentoForm := DepartamentoFormNew();
   if not DepartamentoForm.Visible then
      InhFormDealWithScreen(TForm(DepartamentoForm));
  DepartamentoForm.Show();
end;

procedure TInhMainForm.AbrirFormaPagamentoExecute(Sender: TObject);
begin
   if not Assigned(FormaPagamentoForm) then
      FormaPagamentoForm := FormaPagamentoFormNew();
   if not FormaPagamentoForm.Visible then
      InhFormDealWithScreen(TForm(FormaPagamentoForm));
   FormaPagamentoForm.Show();
end;

procedure TInhMainForm.AbrirEncomendaExecute(Sender: TObject);
begin
   if not Assigned(EncomendaForm) then
      EncomendaForm := EncomendaFormNew();
   if not EncomendaForm.Visible then
      InhFormDealWithScreen(TForm(EncomendaForm));
   EncomendaForm.Show();
end;

procedure TInhMainForm.AbrirCompromissoExecute(Sender: TObject);
begin
   if not Assigned(CompromissoForm) then
      CompromissoForm := CompromissoFormNew();
   if not CompromissoForm.Visible then
      InhFormDealWithScreen(TForm(CompromissoForm));
   CompromissoForm.Show();
end;

procedure TInhMainForm.AbrirPortaConsumoFixoExecute(Sender: TObject);
begin
   if not Assigned(PortaConsumoFixoForm) then
      PortaConsumoFixoForm := PortaConsumoFixoFormNew();
   if not PortaConsumoFixoForm.Visible then
      InhFormDealWithScreen(TForm(PortaConsumoFixoForm));
   PortaConsumoFixoForm.Show();
end;

procedure TInhMainForm.AbrirAtendimentoExecute(Sender: TObject);
begin
   if not Assigned(CaixaAtendimentoForm) then
      CaixaAtendimentoForm := CaixaAtendimentoFormNew(Self);
   if not CaixaAtendimentoForm.Visible then
      InhFormDealWithScreen(TForm(CaixaAtendimentoForm));
   CaixaAtendimentoForm.Show;
end;

procedure TInhMainForm.AbrirConfiguracaoExecute(Sender: TObject);
begin
//   InhConfigFormOpen();
end;

procedure TInhMainForm.SairExecute(Sender: TObject);
begin
   if (InhDlgYesNo ('Deseja realmente fechar o programa?')) then
      Application.Terminate;
end;

procedure TInhMainForm.AbrirCaixaExecute(Sender: TObject);
begin
   if not Assigned(CaixaFechamentoForm) then
      CaixaFechamentoForm := CaixaFechamentoFormNew(Self);
   if not CaixaFechamentoForm.Visible then
      InhFormDealWithScreen(TForm(CaixaFechamentoForm));
   CaixaFechamentoForm.Show;
end;

procedure TInhMainForm.AbrirNovosPortaConsumosExecute(Sender: TObject);
begin
   InhPortaConsumoNovoOpen();
end;

procedure TInhMainForm.AbrirReportStatusCaixaExecute(Sender: TObject);
begin
   InhReportStatusCaixaDlgRun ();
end;

procedure TInhMainForm.AbrirCaixaMovimentoDlgExecute(Sender: TObject);
begin
   InhCaixaMovimentoDlgRun ();
end;

procedure TInhMainForm.AbrirReportResumoVendasExecute(Sender: TObject);
begin
   InhReportResumoVendasDlgRun ();
end;

procedure TInhMainForm.TelaPrincipal1Click(Sender: TObject);
begin
   InhAjudaRun ('capitulo_tela_principal');
end;

procedure TInhMainForm.Contedo1Click(Sender: TObject);
begin
   InhAjudaRun ('');
end;

procedure TInhMainForm.SobreoInhunmi1Click(Sender: TObject);
begin
   InhAJudaRun('oquee');
end;

procedure TInhMainForm.AbrirNovosPortaConsumosAutomaticosExecute(
  Sender: TObject);
begin
   InhPortaConsumoAutomaticosOpen();
end;

procedure TInhMainForm.FormShow(Sender: TObject);
begin
   Self.Caption := Self.Caption + ' (' + InhAccess.usuario + ')';
end;

procedure TInhMainForm.AbrirEncomendaTelemarketingExecute(Sender: TObject);
begin
   if not Assigned(EncomendaTeleMarketingForm) then
      EncomendaTeleMarketingForm := EncomendaTeleMarketingFormNew(Self);
   if not EncomendaTeleMarketingForm.Visible then
      InhFormDealWithScreen(TForm(EncomendaTeleMarketingForm));
   EncomendaTeleMarketingForm.Show();
end;


function TInhMainForm.GetAtendimentoForm: TInhCaixaAtendimentoForm;
begin
   Result := CaixaAtendimentoForm;
end;

function TInhMainForm.GetCaixaForm: TInhCaixaFechamentoForm;
begin
   Result := CaixaFechamentoForm;
end;

procedure TInhMainForm.FormLoaded(Sender: TObject);
begin
   InhFormDealWithScreen (TForm(Self));
end;

procedure TInhMainForm.BancodeDados1Click(Sender: TObject);
begin
   InhDbDriverInfoDlgRun();
end;

procedure TInhMainForm.FechamentoDePortaConsumos1Click(Sender: TObject);
begin
   InhGerenciaFechamentoPortaConsumosRun();
end;

procedure TInhMainForm.ResumoProduo1Click(Sender: TObject);
begin
   InhReportEncomendaProducaoResumoDlgRun(Self);
end;

procedure TInhMainForm.ListagemPorDataHora1Click(Sender: TObject);
begin
   InhReportEncomendaProducaoListagemHoraDlgRun (Self);
end;

procedure TInhMainForm.HistoricodeProdutos1Click(Sender: TObject);
begin
   InhReportEstoqueProdutoHistoricoID (0, 0);
end;

procedure TInhMainForm.SpeedButton4Click(Sender: TObject);
begin
   InhReportEstoqueProdutoHistoricoID (0, 0);
end;


procedure TInhMainForm.AbrirEstoqueEntradaSimplesExecute(
  Sender: TObject);
begin
   if not Assigned(EstoqueMovimentoEntradaForm) then
      EstoqueMovimentoEntradaForm := EstoqueMovimentoEntradaFormNew();
   if not EstoqueMovimentoEntradaForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueMovimentoEntradaForm));
   EstoqueMovimentoEntradaForm.Show();
end;

procedure TInhMainForm.AbrirEstoqueSaidaSimplesExecute(Sender: TObject);
begin
   if not Assigned(EstoqueMovimentoSaidaForm) then
      EstoqueMovimentoSaidaForm := EstoqueMovimentoSaidaFormNew();
   if not EstoqueMovimentoSaidaForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueMovimentoSaidaForm));
   EstoqueMovimentoSaidaForm.Show();
end;

procedure TInhMainForm.AbrirEstoqueTransferenciaSimplesExecute(
  Sender: TObject);
begin
   if not Assigned(EstoqueMovimentoTransferenciaForm) then
      EstoqueMovimentoTransferenciaForm := EstoqueMovimentoTransferenciaFormNew();
   if not EstoqueMovimentoTransferenciaForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueMovimentoTransferenciaForm));
   EstoqueMovimentoTransferenciaForm.Show();
end;

procedure TInhMainForm.AbrirEstoqueAjusteSimplesExecute(Sender: TObject);
begin
   if not Assigned(EstoqueAjusteForm) then
      EstoqueAjusteForm := EstoqueAjusteFormNew();
   if not EstoqueAjusteForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueAjusteForm));
   EstoqueAjusteForm.Show();
end;

procedure TInhMainForm.NovaEntradaSimplesExecute(Sender: TObject);
begin
   InhEstoqueMovimentoEntradaSimplesDlgRun();
end;

procedure TInhMainForm.NovaSaidaSimplesExecute(Sender: TObject);
begin
  InhEstoqueMovimentoSimplesDlgRun (ietmSaida);
end;

procedure TInhMainForm.NovaTransferenciaSimplesExecute(Sender: TObject);
begin
   InhEstoqueTransferenciaSimplesDlgRun();
end;

procedure TInhMainForm.NovoAjusteSimplesExecute(Sender: TObject);
begin
   InhEstoqueAjusteSimplesDlgRun();
end;


procedure TInhMainForm.AbrirEstoqueEntradasGrupoExecute(Sender: TObject);
begin
   if not Assigned(EstoqueMovimentoEntradaGrupoForm) then
      EstoqueMovimentoEntradaGrupoForm := EstoqueMovimentoEntradaGrupoFormNew();
   if not EstoqueMovimentoEntradaGrupoForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueMovimentoEntradaGrupoForm));
   EstoqueMovimentoEntradaGrupoForm.Show();
end;

procedure TInhMainForm.AbrirEstoqueSaidasGrupoExecute(Sender: TObject);
begin
   if not Assigned(EstoqueMovimentoSaidaGrupoForm) then
      EstoqueMovimentoSaidaGrupoForm := EstoqueMovimentoSaidaGrupoFormNew();
   if not EstoqueMovimentoSaidaGrupoForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueMovimentoSaidaGrupoForm));
   EstoqueMovimentoSaidaGrupoForm.Show();
end;

procedure TInhMainForm.AbrirEstoqueTransferenciasGrupoExecute(
  Sender: TObject);
begin
   if not Assigned(EstoqueMovimentoTransferenciaGrupoForm) then
      EstoqueMovimentoTransferenciaGrupoForm := EstoqueMovimentoTransferenciaGrupoFormNew();
   if not EstoqueMovimentoTransferenciaGrupoForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueMovimentoTransferenciaGrupoForm));
   EstoqueMovimentoTransferenciaGrupoForm.Show();
end;

procedure TInhMainForm.AbrirEstoqueAjustesGrupoExecute(Sender: TObject);
begin
   if not Assigned(EstoqueAjusteGrupoForm) then
      EstoqueAjusteGrupoForm := EstoqueAjusteGrupoFormNew();
   if not EstoqueAjusteGrupoForm.Visible then
      InhFormDealWithScreen(TForm(EstoqueAjusteGrupoForm));
   EstoqueAjusteGrupoForm.Show();
end;

procedure TInhMainForm.ReportHistoricoEstoqueExecute(Sender: TObject);
begin
   InhReportEstoqueProdutoHistoricoID (0, 0);
end;

procedure TInhMainForm.ReportStatusCaixaExecute(Sender: TObject);
begin
   InhReportStatusCaixaDlgRun ();
end;

procedure TInhMainForm.ReportResumoVendasExecute(Sender: TObject);
begin
   InhReportResumoVendasDlgRun ();
end;

procedure TInhMainForm.AbrirPortaConsumoPorIdExecute(Sender: TObject);
var
   Id : integer;
begin
   Id := InputBox('Abrir Porta-Consumo', 'Código:', -1, 1, 99999999, 1);
   if (Id >= 1) and (Id <= 99999999) then
      PortaConsumoPropriedadesDlgNewRun (Self, Id)
   else
      InhDlg ('Erro: Código Inválido');
end;

procedure TInhMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Shift = [ssAlt] then
      begin
         case Key of
            Key_1 : PageControl.ActivePageIndex := 0;
            Key_2 : PageControl.ActivePageIndex := 1;
            Key_3 : PageControl.ActivePageIndex := 2;
            Key_4 : PageControl.ActivePageIndex := 3;
         end;
      end;
end;

procedure TInhMainForm.ReportProdutoTabelaPrecoExecute(Sender: TObject);
begin
   InhReportProdutoTabelaPrecoVendidoDlgRun();
end;

procedure TInhMainForm.ReportPendentesResumidoExecute(Sender: TObject);
begin
   InhReportPendentesAReceberResumido ();
end;

procedure TInhMainForm.FiscalReducaoZExecute(Sender: TObject);
begin
   InhFiscalSummarizeAndClose();
end;

procedure TInhMainForm.FiscalLeituraXExecute(Sender: TObject);
begin
   InhFiscalSummarize();
end;

procedure TInhMainForm.FiscalCancelLastCouponExecute(Sender: TObject);
begin
   InhFiscalCancelLastCoupon();
end;

procedure TInhMainForm.FiscalReimpressaoCouponExecute(Sender: TObject);
begin
   if (InhDlgYesNo('Deseja re-emitir o coupon fiscal do seu ultimo fechamento?')) then
         FiscalReimprimeUltimoCoupon();
end;

end.
