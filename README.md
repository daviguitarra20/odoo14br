## ODOO 14 ##

git clone -b 14.0 --single-branch --depth=1 https://github.com/odoo/odoo.git

## MODULOS PARA SETEM BAIXADOS : ##

git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/reporting-engine.git


git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/server-ux.git


git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/mis-builder.git


git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/account-payment.git


git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/web.git



git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/bank-payment.git



git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/l10n-brazil.git


git clone -b 14.0 --single-branch --depth=1  https://github.com/OCA/helpdesk.git


###  Para criar a imagen docker use :

docker build -t  NOME_DA_IMAGEN .

### Para adicionar um submodulo com a branch desejada:

git submodule add -b 14.0 URL-do-repositorio caminho/opcional


### Para baixar ou atualizar os extra-addons:
git submodule update --init --depth=1
