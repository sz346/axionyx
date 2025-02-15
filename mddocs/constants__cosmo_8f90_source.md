
# File constants\_cosmo.f90

[**File List**](files.md) **>** [**Constants**](dir_07f778f17d33213a19d33863e392ca9b.md) **>** [**constants\_cosmo.f90**](constants__cosmo_8f90.md)

[Go to the documentation of this file.](constants__cosmo_8f90.md) 


````cpp
!
! Nyx code units are defined as: 
!      Length [Mpc]
!      Velocity [km/s]
!      Mass [M_sun]
!      (+ Kelvin for temperature)
!
! Fundamental constants are taken from Chin. Phys. C, 40, 100001 (2016), see 
!          http://pdg.lbl.gov/2016/reviews/rpp2016-rev-phys-constants.pdf
!          http://pdg.lbl.gov/2016/reviews/rpp2016-rev-astrophysical-constants.pdf
!

module fundamental_constants_module

  use amrex_fort_module, only : rt => amrex_real
  implicit none

  real(rt), parameter :: pi = 3.141592653589793238d0

  ! Relation of our code units & CGS: 
  real(rt), parameter :: M_unit = 1.98848d33    ! M_sun
  real(rt), parameter :: L_unit = 3.0856776d24  ! Mpc
  real(rt), parameter :: V_unit = 1.d5          ! km/s
  real(rt), parameter :: T_unit = l_unit/v_unit ! time unit

  !
  ! Fundamental constants
  !
  real(rt), parameter :: Gconst = 6.67408e-8_rt       &       ! Newton [g^-1*s^-2*cm^3]
                                  * m_unit*t_unit**2/l_unit**3

  real(rt), parameter :: k_B    = 1.38064852e-16_rt   &       ! Boltzmann [g*cm^2/s^2*K]
                                  * t_unit**2/(m_unit*l_unit**2)

  real(rt), parameter :: hbar   = 1.0545718e-27_rt    &       ! Planck/2pi [g*cm^2/s]
                                  * t_unit/(m_unit*l_unit**2)

  real(rt), parameter :: n_A    = 6.022140857e23_rt   &       ! Avogadro's number [mol^-1]
                                  * m_unit

  real(rt), parameter :: m_proton = 1.672621e-24_rt   &       ! Proton mass [g]
                                    / m_unit

  real(rt), parameter :: sigma_T =  6.6524587158e-25_rt  &    ! Thomson cross section [cm^2]
                                    / l_unit**2

  real(rt), parameter :: c_light = 2.99792458e10_rt   &       ! Speed of light [cm/s] 
                                   / v_unit

  real(rt), parameter :: Hubble_const = 100._rt               ! Hubble constant / h

  !
  ! Useful quantities and conversions
  !
  real(rt), parameter :: mp_over_kb = m_proton/k_b

  real(rt), parameter :: density_to_cgs = m_unit / l_unit**3

  ! For internal energy
  real(rt), parameter :: e_to_cgs = v_unit**2 

  ! For source terms we convert [erg/(s*cm^3) = g/(s^3*cm)] into code units
  real(rt), parameter :: heat_from_cgs = l_unit*(t_unit**3 / m_unit)

  ! For AGN accretion rate
  real(rt), parameter :: eddington_const = 4.0d0*pi * gconst * m_proton / (sigma_t * c_light)

end module fundamental_constants_module
````

