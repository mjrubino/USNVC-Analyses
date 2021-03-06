/*
  First attempt at combining NVC land cover data with boundary, GAP landfire,
  and PADUS for summarizing across NVC groups and classes
*/

USE GAP_AnalyticDB;
GO

/*
  Join the boundary and PADUS tables to get GAP status levels and
  join that with the boundary x gap landfire table to pull out the 
  cell counts for boundary polygons intersected with PADUS
*/
WITH
BoundaryPAD AS 
	(SELECT 
		padus1_4.d_gap_sts, 
		padus1_4.gap_sts,
		lu_boundary_gap_landfire.gap_landfire as glf_index,
		lu_boundary_gap_landfire.count
	FROM	lu_boundary_gap_landfire INNER JOIN lu_boundary
	ON		lu_boundary_gap_landfire.boundary = lu_boundary.value INNER JOIN padus1_4
	ON		lu_boundary.padus1_4 = padus1_4.objectid
	),


/*
  Join the boundary-landfire and landfire tables to provide a link
  to NVC groups and classes info and count data
*/
NVC AS
	(SELECT lu_boundary_gap_landfire.gap_landfire, 
			gap_landfire.value,
			lu_boundary_gap_landfire.count, 
			gap_landfire.cl,
			gap_landfire.nvc_class, 
			gap_landfire.gr,
			gap_landfire.nvc_group,
			gap_landfire.ecosys_lu
		FROM lu_boundary_gap_landfire INNER JOIN gap_landfire
		ON lu_boundary_gap_landfire.gap_landfire = gap_landfire.value
	)



SELECT BoundaryPAD.gap_sts  as PADStatus,
	   NVC.gap_landfire  as glf_index,
	   NVC.cl  as ClassCode, NVC.nvc_class as NVCClass,
	   NVC.gr as GroupCode, NVC.nvc_group as NVCGroup,
	   NVC.ecosys_lu,
	   SUM(BoundaryPAD.count) as nCellSum,
	   SUM(BoundaryPAD.count) * 0.0009 as km2
FROM   BoundaryPAD INNER JOIN nvc 
ON	   BoundaryPAD.glf_index = NVC.gap_landfire
GROUP BY BoundaryPAD.gap_sts,
		NVC.ecosys_lu,
		NVC.gap_landfire,
		NVC.cl,
		NVC.nvc_class,
		NVC.gr,
		NVC.nvc_group


GO




