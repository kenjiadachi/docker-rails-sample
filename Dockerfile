# Docker公式のRubyイメージを使う
FROM ruby:2.6.1-stretch

# アプリケーションを配置するディレクトリ
WORKDIR /app

# 以下前例
# # Node.jsのv10系列とYarnの安定板をインストールする
# RUN curl -sSfL https://deb.nodesource.com/setup_10.x | bash - \
#     && curl -sSfL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#     && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#     && apt-get update \
#     && apt-get install -y \
#         nodejs \
#         yarn \
#     && rm -rf /var/lib/apt/lists/*

# 以下前例2
# # インストールするNodeとYarnのversion
# # NODE_SHA256SUMの値はhttps://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txtを参照のこと
# ENV \
#   NODE_VERSION=v10.15.3 \
#   NODE_DISTRO=linux-x64 \
#   NODE_SHA256SUM=faddbe418064baf2226c2fcbd038c3ef4ae6f936eb952a1138c7ff8cfe862438 \
#   YARN_VERSION=1.15.2
#
# # YarnのinstallでNode.jsのversionをcheckしているので、先にinstall先にPATHを通しておく
# ENV PATH=/opt/node-${NODE_VERSION}-${NODE_DISTRO}/bin:/opt/yarn-v${YARN_VERSION}/bin:${PATH}
#
# # Node.jsとYarnをinstallする
# RUN curl -sSfLO https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz \
#   && echo "${NODE_SHA256SUM} node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz" | sha256sum -c - \
#   && tar -xJ -f node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz -C /opt \
#   && rm -v node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz \
#   && curl -o - -sSfL https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION} \
#   && mv /root/.yarn /opt/yarn-v${YARN_VERSION}

# Bundlerでgemをインストールする
ARG BUNDLE_INSTALL_ARGS="-j 4"
COPY Gemfile Gemfile.lock ./
RUN bundle config --local disable_platform_warnings true \
  && bundle install ${BUNDLE_INSTALL_ARGS}

# nodeのイメージからNode.jsとYarnをコピーする
COPY --from=node:10.15.3-stretch /usr/local/ /usr/local/
COPY --from=node:10.15.3-stretch /opt/ /opt/

COPY package.json yarn.lock ./
RUN yarn install

# エントリポイントを指定する
COPY docker-entrypoint*.sh /
RUN chmod +x /docker-entrypoint*.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# アプリケーションのファイルをコピーする
COPY . ./

# サービスを実行するコマンドとポートを設定する
CMD ["rails", "server", "-b", "0.0.0.0"]
EXPOSE 3000
