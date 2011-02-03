--General User
INSERT INTO user (Host, User, Password) VALUES ('%', 'username', PASSWORD(''));

-- Administrador
INSERT INTO db VALUES ('%', 'inhunmi', 'username', 'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y');
USE inhunmi;
INSERT INTO acesso VALUES (0, 'username', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim', 'Sim');


-- Atendimento
INSERT INTO tables_priv VALUES ('%','inhunmi','atend','acesso', 'administrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','atend','porta_consumo','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','atend','produto','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','atend','pessoa_instituicao','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','atend','consumo','adiministrador', NULL,'Select,Insert','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','atend','porta_consumo_pagamento','adiministrador', NULL,'Select','Select');
USE inhunmi;
INSERT INTO acesso (id, usuario, atendimento) VALUES (0, 'atend', 'Sim');


-- Caixa

INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','acesso','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','porta_consumo','adiministrador', NULL,'Select,Insert','Update');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','produto','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','pessoa_instituicao','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','pessoa_instituicao_pessoa','adiministrador', NULL,'Select','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','consumo','adiministrador', NULL,'Select,Insert','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','porta_consumo_pagamento','adiministrador', NULL,'Select,Insert','Select');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','caixa_movimento','adiministrador', NULL,'Insert','');
INSERT INTO tables_priv VALUES ('%','inhunmi','caixa','forma_pagamento','adiministrador', NULL,'Select','Select');

INSERT INTO columns_priv VALUES ('%', 'inhunmi', 'caixa', 'porta_consumo', 'dono', NULL, 'Update');
INSERT INTO columns_priv VALUES ('%', 'inhunmi', 'caixa', 'porta_consumo', 'status', NULL, 'Update');
INSERT INTO columns_priv VALUES ('%', 'inhunmi', 'caixa', 'porta_consumo', 'usuario', NULL, 'Update')
INSERT INTO columns_priv VALUES ('%', 'inhunmi', 'caixa', 'porta_consumo', 'status_anterior', NULL, 'Update');
INSERT INTO columns_priv VALUES ('%', 'inhunmi', 'caixa', 'porta_consumo', 'datahora_final', NULL, 'Update');


USE inhunmi;
INSERT INTO acesso (id, usuario, atendimento, caixa) VALUES (0, 'atend', 'Sim', 'Sim');
