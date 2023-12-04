# Implementação de Arquitetura Cloud na AWS com Terraform

O objetivo do projeto é provisionar uma arquitetura na AWS utilizando o Terraform, que englobe o uso de um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados RDS.

### Região

A Nuvem AWS abrange 102 zonas de disponibilidade em 32 regiões geográficas por todo o mundo, com planos já divulgados para mais 15 zonas de disponibilidade e outras 5 regiões da AWS no Canadá, na Alemanha, na Malásia, na Nova Zelândia e na Tailândia.  

Dito isso, temos uma gama vasta de possíveis regiões a serem escolhida, para este projeto a região escolhida foi a Virgínia do Norte (us-east-1), devido principalmente aos seguintes fatores:
    *Redundância e Resiliência*: A região us-east-1 possui várias zonas de disponibilidade, permitindo a construção de arquiteturas altamente disponíveis e resilientes.
    *Histórico de Confiabilidade*: Devido à sua longa existência, a região us-east-1 tem um histórico comprovado de confiabilidade e estabilidade.

# Infraestrutura da AWS para Ambiente de Produção

Este repositório contém scripts Terraform para criar uma infraestrutura básica na Amazon Web Services (AWS) destinada a um ambiente de produção. A seguir, uma explicação das principais características da configuração:

### Virtual Private Cloud (VPC)

Foi criada uma VPC (Virtual Private Cloud) com o bloco CIDR `10.0.0.0/16`, permitindo a segmentação de recursos de rede. A VPC está configurada para oferecer suporte a resolução DNS e hostnames DNS.

### Sub-redes Públicas

Duas sub-redes públicas foram estabelecidas para alocar recursos que necessitam de acessibilidade direta à internet. Cada sub-rede possui seu bloco CIDR exclusivo (`10.0.1.0/24` e `10.0.2.0/24`) e está associada a uma zona de disponibilidade específica.

### Sub-redes Privadas

Outras duas sub-redes foram configuradas como privadas (`10.0.3.0/24` e `10.0.4.0/24`), destinadas a recursos que não precisam de acesso direto à internet. Cada sub-rede privada está associada a uma zona de disponibilidade.

### Tabelas de Roteamento

Foram criadas tabelas de roteamento separadas para sub-redes públicas e privadas, permitindo um controle preciso sobre o tráfego. As sub-redes estão associadas às tabelas de roteamento correspondentes.

### Gateway de Internet

Um Gateway de Internet foi configurado para fornecer conectividade à internet para as sub-redes públicas. Rotas adequadas foram definidas nas tabelas de roteamento públicas para garantir a rota correta do tráfego.

### Gateway NAT

Um Gateway NAT foi implementado para permitir que instâncias em sub-redes privadas acessem a internet para atualizações e downloads, sem expor diretamente seus endereços IP. Foi associado um endereço IP elástico a este Gateway NAT.


## Balanceador de Carga para Aplicações em Produção

O ALB é como um "tráfego manager" que direciona os pedidos dos usuários para diferentes partes da sua aplicação, garantindo que tudo funcione sem problemas.

### Características Principais

- **Nome:** "prod"
- **Tipo:** Balanceador de Carga de Aplicação
- **Acesso Interno:** Não
- **Sub-redes:** [Sub-rede Pública 1, Sub-rede Pública 2]

## Como Funciona

O ALB escuta o tráfego na porta 80 (usada para acessar sites) e encaminha esses pedidos para a parte correta da sua aplicação. Isso ajuda a manter tudo equilibrado e funcionando sem problemas.

## Segurança

Há também uma configuração de segurança para garantir que apenas o tráfego necessário seja permitido.

Esta configuração ajuda a garantir que sua aplicação seja escalável, confiável e segura na nuvem da AWS.
