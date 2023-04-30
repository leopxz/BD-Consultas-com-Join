
-- Lista dos empregados admitidos entre 2019-01-01 e 2022-03-31, trazendo as colunas (Nome Empregado, CPF Empregado, Data Admissão,  Salário, Cidade Moradia, Número de Telefone), ordenado por data de admissão decrescente;

select emp.nome "Empregado", emp.cpf "CPF", emp.dataAdm "Data de Adimissão", emp.salario "Salário", ende.cidade "Cidade", ende.bairro "Bairro", tel.numero "Telefone"
from empregado emp
inner join endereco ende on emp.CPF = ende.Empregado_CPF
inner join telefone tel on emp.CPF = tel.Empregado_CPF
where emp.dataAdm between '2019-01-01' and '2022-03-31'
order by emp.dataAdm desc;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- Lista dos empregados que ganham menos que a média salarial dos funcionários do Posto de Gasolina, trazendo as colunas (Nome Empregado, CPF Empregado, Data Admissão,  Salário, Cidade Moradia), ordenado por nome do empregado;
select emp.nome "empregado", emp.cpf "CPF", emp.dataAdm "Data de Adimissão", emp.salario "Salário", ende.cidade "Cidade", ende.bairro "Bairro"
from empregado emp
inner join endereco ende on emp.CPF = ende.Empregado_CPF
where  emp.salario < (select avg(salario) from empregado)
order by emp.nome;

--  Lista dos empregados que são da cidade do Recife e possuem dependentes, trazendo as colunas (Nome Empregado, CPF Empregado, Data Admissão,  Salário, Cidade Moradia, Quantidade de Dependentes), ordenado por nome do empregado;
select emp.nome "empregado", emp.cpf "CPF", emp.dataAdm "Data de Adimissão", emp.salario "Salário", ende.cidade "Cidade", ende.bairro "Bairro", count(dep.empregado_cpf) "Numero de dependentes"
from empregado emp
inner join endereco ende on emp.CPF = ende.Empregado_CPF
inner join dependente dep on emp.CPF = dep.Empregado_CPF
where ende.cidade like 'recife' 
group by emp.CPF
order by emp.nome;


-- Lista dos empregados com a quantidade total de vendas já realiza por cada Empregado, trazendo as colunas (Nome Empregado, CPF Empregado, Sexo, Salário, Quantidade Vendas, Total Valor Vendido), ordenado por quantidade total de vendas realizadas;
select emp.nome "empregado", emp.cpf "CPF", emp.sexo "Sexo", emp.salario "Salário", count(vend.empregado_CPF) "QTD Vendas",case when sum(vend.valortotal) is null then 0 else sum(vend.valorTotal) end "Total vendido"
from empregado emp 
left join vendas vend on emp.CPF = vend.Empregado_CPF
group by emp.CPF
order by count(vend.empregado_CPF) desc;

-- Lista dos empregados que trabalham em cada departamento, trazendo as colunas (Nome Empregado, CPF Empregado, Salário, Nome da Ocupação, Número do Telefone do Empregado, Nome do Departamento, Local do Departamento, Número de Telefone do Departamento, Nome do Gerente), ordenado por nome do Departamento;
select emp.nome "empregado", emp.cpf "CPF", emp.salario "Salário", ocp.nome "Ocupação", case when telE.numero is null then " " else telE.numero end "Telefone Empregado", dep.nome "Departamento", dep.localdep "Local do Departamento",  case when telD.numero is null then " " else telD.numero end "Telefone Departamento", empG.nome "Gerente"
from trabalhar trab 
inner join empregado emp on trab.Empregado_CPF = emp.CPF
inner join ocupacao ocp on trab.Ocupacao_cbo = ocp.cbo
left join telefone telE on emp.CPF = telE.Empregado_CPF
left join departamento dep on trab.Departamento_idDepartamento = dep.idDepartamento
left join telefone telD on dep.idDepartamento = telD.Departamento_idDepartamento
left join gerente ger on dep.Gerente_Empregado_CPF = ger.Empregado_CPF
inner join empregado empG on ger.Empregado_CPF = empG.CPF
order by dep.nome;


-- Lista dos departamentos contabilizando o número total de empregados por departamento, trazendo as colunas (Nome Departamento, Local Departamento, Total de Empregados do Departamento, Nome do Gerente, Número do Telefone do Departamento), ordenado por nome do Departamento;
select dep.nome "Departamento", dep.localdep "Local do Departamento", count(trab.empregado_cpf) "QTD de funcionarios", empG.nome"Gerente", case when tel.numero is null then " " else tel.numero end "Telefone departamento"
from trabalhar trab 
inner join departamento dep on trab.Departamento_idDepartamento = dep.idDepartamento
left join gerente ger on dep.Gerente_Empregado_CPF = ger.Empregado_CPF
inner join empregado empG on ger.Empregado_CPF = empG.CPF
left join telefone tel on dep.idDepartamento = tel.Departamento_idDepartamento
group by dep.idDepartamento
order by dep.nome;


--  Lista das formas de pagamentos mais utilizadas nas Vendas, informando quantas vendas cada forma de pagamento já foi relacionada, trazendo as colunas (Tipo Forma Pagamento, Quantidade Vendas, Total Valor Vendido), ordenado por quantidade total de vendas realizadas;
select fpag.tipopag, count(fpag.tipoPag) "QTD Vendas",case when sum(vend.valorTotal) is null then 0 else sum(vend.valorTotal) end "Total vendido"
from vendas vend 
inner join formapag fpag on vend.idVendas = fpag.Vendas_idVendas
inner join empregado emp on vend.Empregado_CPF = emp.CPF
group by fpag.tipoPag
order by count(fpag.tipoPag) desc;


-- Lista das Vendas, informando o detalhamento de cada venda quanto os seus itens, trazendo as colunas (Data Venda, Nome Produto, Quantidade ItensVenda, Valor Produto, Valor Total Venda, Nome Empregado, Nome do Departamento), ordenado por Data Venda;
select vend.datavenda "Data da Venda", est.nome "Produto", itvend.qtdProduto " Quantidade de Itens", round(est.valor, 4) "Valor do Produto", round((itvend.qtdProduto * est.valor), 2)"Valor total da venda", emp.nome "Empregado resp.", dep.nome "Departamento"
from itensvenda itvend 
inner join vendas vend on itvend.Vendas_idVendas = vend.idVendas
inner join estoque est on itvend.Estoque_idProduto = est.idProduto
inner join empregado emp on vend.Empregado_CPF = emp.CPF
inner join trabalhar trab on emp.CPF = trab.Empregado_CPF
inner join departamento dep on trab.Departamento_idDepartamento = dep.idDepartamento
group by est.idProduto
order by vend.dataVenda;

-- Balaço das Vendas, informando a soma dos valores vendidos por dia, trazendo as colunas (Data Venda, Quantidade de Vendas, Valor Total Venda), ordenado por Data Venda;
select vend.datavenda "Data da venda", itvend.qtdproduto "Quantidade de itens", sum(vend.valortotal) "Valor total da venda"
from vendas vend 
inner join itensvenda itvend on vend.idVendas = itvend.Vendas_idVendas
group by vend.idVendas
order by vend.dataVenda;

-- Lista dos Produtos, informando qual Fornecedor de cada produto, trazendo as colunas (Nome Produto, Valor Produto, Categoria do Produto, Nome Fornecedor, Email Fornecedor, Telefone Fornecedor), ordenado por Nome Produto;
select est.nome "Produto", round(est.valor, 4) "Valor do Produto", est.categoria "Categoria do Produto", forn.nome "Fornecedor", forn.email "Email do Fornecedor", tel.numero "Telefone do Fornecedor"
from compras comp 
inner join fornecedor forn on comp.`Fornecedor_cnpj/cpf` = forn.`cnpj/cpf`
inner join estoque est on comp.Estoque_idProduto = est.idProduto
inner join telefone tel on forn.`cnpj/cpf` = tel.`Fornecedor_cnpj/cpf`
order by est.nome;

-- Lista dos Produtos mais vendidos, informando a quantidade (total) de vezes que cada produto participou em vendas, trazendo as colunas (Nome Produto, Quantidade (Total) Vendas), ordenado por quantidade de vezes que o produto participou em vendas;
select est.nome "Produto", count(itvend.qtdProduto)
from itensvenda itvend 
inner join estoque est on itvend.Estoque_idProduto = est.idProduto
group by est.idProduto
order by count(itvend.qtdProduto) desc;

-- Lista das vendas por departamentos contabilizando o número total de vendas por departamento, trazendo as colunas (Nome Departamento, Local Departamento, Nome do Gerente,  Total de Vendas,  Valor Total das Vendas), ordenado por nome do Departamento;
select dep.nome "Departamento", dep.localdep "Local do Departamento", empG.nome "Gerente", count(vend.idvendas) "total de vendas", case when sum(vend.valortotal) is null then 0 else sum(vend.valortotal) end "Volar total das Vendas"
from trabalhar trab
right join departamento dep on trab.Departamento_idDepartamento = dep.idDepartamento
left join gerente ger on dep.Gerente_Empregado_CPF = ger.Empregado_CPF
inner join empregado empG on empG.CPF = ger.Empregado_CPF
inner join empregado emp on trab.Empregado_CPF = emp.CPF
left join vendas vend on emp.CPF = vend.Empregado_CPF
group by emp.CPF
order by dep.nome;













