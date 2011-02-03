unit InhStringResources;

interface

resourcestring

////////////////////////////////////////////////////////////////////////////
// InhStrRecord: Feedback to user editing records, mainly used in InhDbForm
////////////////////////////////////////////////////////////////////////////
InhStrRecordAdding = 'Novo registro sendo inserido, preencha os campos disponíveis e confirme com (CTRL + Enter)';
InhStrRecordAdded = 'Registro "%s" adicionado. Preencha os outros campos disponíveis. Confime com (CTRL + Enter)';
InhStrRecordModified = 'Registro %s foi modificado e ainda não teve suas alterações salvas.';
InhStrRecordSaved = 'Registro %s teve as alterações salvas';
InhStrRecordModifiedSaveConfirmation = 'O registro atual ainda não foi salvo. Deseja realmente sair e abandonar as alterações?';

////////////////////////////////////////////////////////////////////////////
// InhStrTeleMarketing: Used in InhEncomendaTeleMarketing
////////////////////////////////////////////////////////////////////////////
InhStrTeleMarketingTelephoneNumber = 'Digite o número de telefone do cliente';
InhStrTeleMarketingCustomersListed =  'Escolha um dos clientes listados';
InhStrTeleMarketingCustomerSelected = 'Cliente selecionado, encomenda criada';
InhStrTeleMarketingDeliveryDetailsSaved = 'Detalhes da entrega foram salvos';

////////////////////////////////////////////////////////////////////////////
// InhStrInput: User input data validation
////////////////////////////////////////////////////////////////////////////
InhStrInputInteger =  'Este campo requer um valor numérico inteiro. (Exemplos: 1, 12, 23)';
InhStrInputFloat = 'Este campo requer um valor numérico inteiro ou fracionado. (Exemplos: 1, 12.98, 76.12)';
   
////////////////////////////////////////////////////////////////////////////
// InhStrDlg: Default Messages on Misc Dialogs
////////////////////////////////////////////////////////////////////////////
InhStrDlgNotification = 'Aviso';
InhStrDlgNotImplemented = 'Desculpe, mas esta função ainda não está implementada.';

////////////////////////////////////////////////////////////////////////////
// InhStrDlgRecord: Messages on Dialogs Regarding Operations on Records
////////////////////////////////////////////////////////////////////////////
InhStrDlgRecordMasterDeleteConfirmation  = 'Tem certeza que deseja excluir este(a) %s e todas as informações relacionadas?';
InhStrDlgRecordDetailDeleteConfirmation = 'Tem certeza que deseja excluir este(a) %s?';
InhStrDlgRecordNotApplied = 'Desculpe mas não foi possível executar esta operação. Verifique o estado do servidor e suas permissões de acesso ao mesmo.';

implementation

end.
