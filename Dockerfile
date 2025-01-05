FROM python:3.8-slim-bullseye

# Atualizando a instrução de manutenção para usar LABEL
LABEL maintainer="Odoo S.A. <info@odoo.com>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Gerar locale C.UTF-8 para PostgreSQL e dados gerais de locale
ENV LANG=C.UTF-8

# Instalar dependências necessárias, lessc, less-plugin-clean-css e wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Instalar o cliente PostgreSQL mais recente
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Instalar rtlcss (no Debian bullseye)
RUN npm install -g rtlcss

# Instalar dependências do Python, incluindo psycopg2-binary para PostgreSQL
RUN pip install --no-cache-dir psycopg2-binary

# Instalar Odoo
ENV ODOO_VERSION=14.0
ARG ODOO_RELEASE=20231106
ARG ODOO_SHA=a50db3bf2d55c64bd51b6b56a2e3d0dbafc44894
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copiar script de entrypoint e arquivo de configuração do Odoo
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Definir permissões e montar /var/lib/odoo para permitir restauração de filestore e /mnt/extra-addons para addons de usuários
RUN chmod +x /entrypoint.sh \
    && chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expor serviços do Odoo
EXPOSE 8069 8071 8072

# Definir o arquivo de configuração padrão
ENV ODOO_RC=/etc/odoo/odoo.conf

# Copiar script para aguardar o PostgreSQL
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Definir usuário padrão ao rodar o container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
