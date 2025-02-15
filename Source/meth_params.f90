
! This module stores the runtime parameters.  
! These parameter are initialized in set_method_params().

module meth_params_module

  use amrex_fort_module, only : rt => amrex_real

  implicit none

  real(rt), save :: difmag        ! used only in consup to weight the divu contributin
  integer , save :: iorder        ! used only in uslope and uflaten

  real(rt), save, public  :: gamma_const, gamma_minus_1

  integer, parameter     :: NHYP    = 4
  integer, parameter     :: MAXADV  = 5

  ! NTHERM: number of thermodynamic variables
  integer         , save :: NTHERM, NVAR, NDIAG
  integer         , save :: URHO, UMX, UMY, UMZ, UEDEN, UEINT, UFA, UFS, UFX
  integer         , save :: TEMP_COMP, NE_COMP, ZHI_COMP

  ! QTHERM: number of primitive variables
  integer         , save :: QTHERM, QVAR
  integer         , save :: QRHO, QU, QV, QW, QPRES, QREINT, QFA, QFS
  
  integer         , save :: nadv

  real(rt)        , save :: small_dens, small_temp, small_pres  

  integer         , save :: ppm_type
  integer         , save :: ppm_reference
  integer         , save :: ppm_flatten_before_integrals
  integer         , save :: use_colglaz
  integer         , save :: use_flattening
  integer         , save :: version_2
  integer         , save :: corner_coupling
  integer         , save :: use_const_species
  integer         , save :: normalize_species
  integer         , save :: heat_cool_type
  integer         , save :: inhomo_reion
  integer         , save :: grav_source_type
  
  ! indices for the axion field 
  integer         , save :: NAXVAR
  integer         , save :: UAXDENS, UAXRE, UAXIM, UAXPHAS


  integer, save :: npassive
  integer, save, allocatable :: qpass_map(:), upass_map(:)

end module meth_params_module
