# Estágio de build
FROM node:18-alpine AS builder

WORKDIR /app

# Copia os arquivos de dependência
COPY package*.json ./
COPY yarn.lock ./

# Instala as dependências
RUN yarn install --frozen-lockfile

# Copia o código fonte
COPY . .

# Gera o build de produção
RUN yarn build

# Estágio de produção
FROM node:18-alpine

WORKDIR /app

# Copia apenas os arquivos necessários do estágio de build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Expõe a porta do servidor
EXPOSE 3000

# Define variáveis de ambiente para produção
ENV NODE_ENV=production

# Healthcheck para monitoramento
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Inicia o servidor
CMD ["node", "dist/main"]
