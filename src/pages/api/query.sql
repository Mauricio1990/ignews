select
    EntCod,
    Id,
    Guid,
    EntCpfCgc,
    PotCliCod,
    EntDatNas,
    EntBvt,
    EntBvtRemC,
    IdFilialCadastro,
    EntCobExt,
    EntBvtDat into #clientesAptos
from
    ENT001 WITH (NOLOCK)
where
    EntFisJur = 0
    and PotCliCod IN ('F', 'L', 'Q')
    and (
        EntBvt = 0
        OR EntBvt IS NULL
    )
select
    e.EntCod,
    e.Id,
    e.Guid,
    e.EntCpfCgc,
    e.PotCliCod,
    e.EntDatNas,
    e.EntBvt,
    e.EntBvtRemC,
    e.IdFilialCadastro,
    c.CobExtIna,
    c.CobExtCod,
    c.CobExtIncS,
    c.CobExtSpcI,
    e.EntCobExt,
    RecDatVct,
    EntBvtDat into #clientes
FROM
    #clientesAptos e 
    INNER JOIN COB100 c (NOLOCK) on c.CobExtCod = e.EntCobExt
    INNER JOIN REC003 r (NOLOCK) on e.EntCod = r.RecEntCod
    AND r.EmpCod = '1'
    AND r.RecSta = 'A'
    AND r.TipDocCod IN ('10', '208', '200', '17', '69')
    AND r.RecDatVct <= DATEADD(d, -10, GETDATE())
    AND r.RecDatVct >= DATEADD(mm, -11, DATEADD(YYYY, -4, GETDATE()))
    AND r.RecDatEmi >= DATEADD(YEAR, 18, e.EntDatNas)
where
    (
        EntBvt = 0
        OR EntBvt IS NULL
    )
select
    distinct top 10000 EntCod AS Codigo,
    Id AS Id,
    Guid,
    EntCpfCgc AS DocumentoCliente,
    PotCliCod AS CodigoPotencial,
    EntDatNas AS DataNascimento,
    EntBvt AS SCPC,
    EntBvtRemC AS SCPCCodigoRemessa,
    EntBvtDat AS Datascpc,
    isnull(IdFilialCadastro, 53) AS IdFilialOrigem,
    min(RecDatVct)
FROM
    #clientes d (nolock)
WHERE
    (
        CobExtCod is null
        or (
            EntCobExt = 0
            OR (
                EntCobExt <> 0
                and (
                    CobExtIncS = 1
                    OR CobExtSpcI = 1
                )
            )
        )
    )
GROUP BY
    EntCod,
    Id,
    Guid,
    EntCpfCgc,
    PotCliCod,
    EntDatNas,
    EntBvt,
    EntBvtRemC,
    EntBvtDat,
    IdFilialCadastro
ORDER BY
    min(RecDatVct)