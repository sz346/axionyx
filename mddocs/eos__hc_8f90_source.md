
# File eos\_hc.f90

[**File List**](files.md) **>** [**EOS**](dir_2a6406f09975eea078703cc63b0e3416.md) **>** [**eos\_hc.f90**](eos__hc_8f90.md)

[Go to the documentation of this file.](eos__hc_8f90.md) 


````cpp
! Calculates temperature and free electron density using Newton-Raphson solver
!
!     Equilibrium ionization fractions, optically thin media, based on:
!     Katz, Weinberg & Hernquist, 1996: Astrophysical Journal Supplement v.105, p.19
!
! Units are CGS, **BUT** 6 fractions: ne, nh0, nhp, nhe0, nhep, nhepp
!       are in units of nh (hydrogen number density)
!

module eos_module

  use amrex_fort_module, only : rt => amrex_real
  use iso_c_binding, only: c_double

  implicit none

  ! Routines:
  public  :: nyx_eos_given_rt, nyx_eos_given_rt_vec, nyx_eos_t_given_re, nyx_eos_t_given_re_vec, eos_init_small_pres
  public  :: nyx_eos_nh0_and_nhep, iterate_ne, iterate_ne_vec
  private :: ion_n

  real(rt), public :: xacc ! EOS Newton-Raphson convergence tolerance
  real(c_double), public :: vode_rtol, vode_atol_scaled ! VODE integration tolerances

  contains

      subroutine fort_setup_eos_params (xacc_in, vode_rtol_in, vode_atol_scaled_in) &
                                       bind(c, name='fort_setup_eos_params')
        use amrex_fort_module, only : rt => amrex_real
        implicit none
        real(rt), intent(in) :: xacc_in, vode_rtol_in, vode_atol_scaled_in

        xacc = xacc_in
        vode_rtol = vode_rtol_in
        vode_atol_scaled = vode_atol_scaled_in

      end subroutine fort_setup_eos_params

     ! ****************************************************************************

      subroutine eos_init_small_pres(R, T, Ne, P, a)

        use amrex_fort_module, only : rt => amrex_real
        use atomic_rates_module, ONLY: yhelium
        use fundamental_constants_module, only: mp_over_kb

        implicit none

        real(rt), intent(  out) :: P
        real(rt), intent(in   ) :: R, T, Ne
        real(rt), intent(in   ) :: a

        real(rt) :: mu

        mu = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne)
        p  = r*t / (mp_over_kb * mu)

      end subroutine eos_init_small_pres

     ! ****************************************************************************

      subroutine nyx_eos_soundspeed(c, R, e)

        use meth_params_module, only: gamma_const, gamma_minus_1

        implicit none

        real(rt), intent(in   ) :: R, e
        real(rt), intent(  out) :: c

        ! sound speed: c^2 = gamma*P/rho
        c = sqrt(gamma_const * gamma_minus_1 *e)

      end subroutine nyx_eos_soundspeed

     ! ****************************************************************************

      subroutine nyx_eos_s_given_re(S, R, T, Ne, a)

        use amrex_constants_module, only: m_pi
        use atomic_rates_module, ONLY: yhelium
        use fundamental_constants_module, only: mp_over_kb
        use fundamental_constants_module, only: k_b, hbar, m_proton
        implicit none

        real(rt),          intent(  out) :: S
        real(rt),          intent(in   ) :: R, T, Ne, a

        real(rt) :: mu, dens, t1, t2, t3

        mu = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne)
        dens = r/(a*a*a)

        ! Entropy (per gram) of an ideal monoatomic gas (Sactur-Tetrode equation)
        ! NOTE: this expression is only valid for gamma = 5/3.
        t1 = (mu*m_proton);            t1 = t1*t1*sqrt(t1)
        t2 = (k_b*t);                  t2 = t2*sqrt(t2)
        t3 = (2.0d0*m_pi*hbar*hbar);   t3 = t3*sqrt(t3)

        s = (1.d0 / (mu*mp_over_kb)) * (2.5d0 + log(t1/dens*t2/t3))

      end subroutine nyx_eos_s_given_re

     ! ****************************************************************************

      subroutine nyx_eos_given_rt(e, P, R, T, Ne, a)

        use atomic_rates_module, ONLY: yhelium
        use fundamental_constants_module, only: mp_over_kb
        use meth_params_module, only: gamma_minus_1
        implicit none

        double precision,          intent(  out) :: e, P
        double precision,          intent(in   ) :: R, T, Ne
        double precision,          intent(in   ) :: a

        double precision :: mu

        mu = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne)
        e  = t / (gamma_minus_1 * mp_over_kb * mu)

        p  = gamma_minus_1 * r * e

      end subroutine nyx_eos_given_rt

     ! ****************************************************************************

      subroutine nyx_eos_given_rt_vec(e, P, R, T, Ne, a, veclen)

        use atomic_rates_module, ONLY: yhelium
        use fundamental_constants_module, only: mp_over_kb
        use meth_params_module, only: gamma_minus_1
        implicit none

        integer, intent(in) :: veclen
        real(rt), dimension(veclen), intent(  out) :: e, P
        real(rt), dimension(veclen), intent(in   ) :: R, T, Ne
        real(rt),          intent(in   ) :: a

        real(rt), dimension(veclen) :: mu
        integer :: i

        do i = 1, veclen
          mu(i) = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne(i))
          e(i)  = t(i) / (gamma_minus_1 * mp_over_kb * mu(i))
  
          p(i)  = gamma_minus_1 * r(i) * e(i)
        end do

      end subroutine nyx_eos_given_rt_vec

     ! ****************************************************************************

      subroutine nyx_eos_t_given_re(JH, JHe, T, Ne, R_in, e_in, a, species)

      use atomic_rates_module, ONLY: xhydrogen, mproton
      use fundamental_constants_module, only: density_to_cgs, e_to_cgs

      ! In/out variables
      integer,    intent(in)    :: JH, JHe
      real(rt),   intent(inout) :: T, Ne
      real(rt),   intent(in   ) :: R_in, e_in
      real(rt),   intent(in   ) :: a
      real(rt), optional, intent(out) :: species(5)

      double precision :: nh, nh0, nhep, nhp, nhe0, nhepp
      double precision :: z, rho, U

      ! This converts from code units to CGS
      rho = r_in * density_to_cgs / a**3
        u = e_in * e_to_cgs
      nh  = rho*xhydrogen/mproton

      z   = 1.d0/a - 1.d0

      call iterate_ne(jh, jhe, z, u, t, nh, ne, nh0, nhp, nhe0, nhep, nhepp)

      if (present(species)) then
         species(1) = nh0
         species(2) = nhp
         species(3) = nhe0
         species(4) = nhep
         species(5) = nhepp
      endif

      end subroutine nyx_eos_t_given_re

     ! ****************************************************************************

      subroutine nyx_eos_t_given_re_vec(T, Ne, R_in, e_in, a, veclen)

      use amrex_fort_module, only : rt => amrex_real
      use atomic_rates_module, ONLY: xhydrogen, mproton
      use fundamental_constants_module, only: density_to_cgs, e_to_cgs

      ! In/out variables
      integer, intent(in) :: veclen
      real(rt), dimension(veclen), intent(inout) :: T, Ne
      real(rt), dimension(veclen), intent(in   ) :: R_in, e_in
      real(rt),                    intent(in   ) :: a

      real(rt), dimension(veclen) :: nh, nh0, nhep, nhp, nhe0, nhepp, rho, U
      real(rt) :: z

      ! This converts from code units to CGS
      rho = r_in * density_to_cgs / a**3
        u = e_in * e_to_cgs
      nh  = rho*xhydrogen/mproton

      z   = 1.d0/a - 1.d0

      call iterate_ne_vec(z, u, t, nh, ne, nh0, nhp, nhe0, nhep, nhepp, veclen)

      end subroutine nyx_eos_t_given_re_vec

     ! ****************************************************************************

      subroutine nyx_eos_nh0_and_nhep(JH, JHe, z, rho, e, nh0, nhep)
      ! This is for skewers analysis code, input is in CGS

      use atomic_rates_module, only: xhydrogen, mproton

      ! In/out variables
      integer, intent(in) :: JH, Jhe
      real(rt),           intent(in   ) :: z, rho, e
      real(rt),           intent(  out) :: nh0, nhep

      real(rt) :: nh, nhp, nhe0, nhepp, T, ne

      nh  = rho*xhydrogen/mproton
      ne  = 1.0d0 ! Guess

      call iterate_ne(jh, jhe, z, e, t, nh, ne, nh0, nhp, nhe0, nhep, nhepp)

      nh0  = nh*nh0
      nhep = nh*nhep

      end subroutine nyx_eos_nh0_and_nhep

     ! ****************************************************************************

      subroutine iterate_ne_vec(z, U, t, nh, ne, nh0, nhp, nhe0, nhep, nhepp, veclen)

      use atomic_rates_module, ONLY: this_z, yhelium, boltzmann, mproton, tcoolmax_r
      use meth_params_module, only: gamma_minus_1
      use amrex_error_module, only: amrex_abort

      integer :: i

      integer, intent(in) :: veclen
      real(rt), intent (in   ) :: z
      real(rt), dimension(veclen), intent(in) :: U, nh
      real(rt), dimension(veclen), intent (inout) :: ne
      real(rt), dimension(veclen), intent (  out) :: t, nh0, nhp, nhe0, nhep, nhepp

      real(rt), parameter :: xacc = 1.0d-6

      integer, dimension(veclen)  :: JH, JHe
      real(rt), dimension(veclen) :: f, df, eps, mu
      real(rt), dimension(veclen) :: nhp_plus, nhep_plus, nhepp_plus
      real(rt), dimension(veclen) :: dnhp_dne, dnhep_dne, dnhepp_dne, dne
      real(rt), dimension(veclen):: U_in, t_in, nh_in, ne_in
      real(rt), dimension(veclen) :: nhp_out, nhep_out, nhepp_out
      integer :: vec_count, orig_idx(veclen)
      integer :: ii
      character(len=128) :: errmsg

      ! Check if we have interpolated to this z
      if (abs(z-this_z) .gt. xacc*z) then
          write(errmsg, *) "iterate_ne_vec(): Wrong redshift! z = ", z, " but this_z = ", this_z
          call amrex_abort(errmsg)
      end if

      ii = 0
      ne(1:veclen) = 1.0d0 ! 0 is a bad guess
      jh(1:veclen) = 0.0d0
      jhe(1:veclen) = 0.0d0

      do  ! Newton-Raphson solver
         ii = ii + 1

         ! Ion number densities
         do i = 1, veclen
           mu(i) = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne(i))
           t(i)  = gamma_minus_1*mproton/boltzmann * u(i) * mu(i)
         end do
         vec_count = 0
         do i = 1, veclen
           if (t(i) .ge. tcoolmax_r) then ! Fully ionized plasma
             nhp(i)   = 1.0d0
             nhep(i)  = 0.0d0
             nhepp(i) = yhelium
           else
             vec_count = vec_count + 1
             u_in(vec_count) = u(i)
             t_in(vec_count) = t(i)
             nh_in(vec_count) = nh(i)
             ne_in(vec_count) = ne(i)
             orig_idx(vec_count) = i
           endif
         end do

         call ion_n_vec(jh(1:vec_count), &
                    jhe(1:vec_count), &
                    u_in(1:vec_count), &
                    nh_in(1:vec_count), &
                    ne_in(1:vec_count), &
                    nhp_out(1:vec_count), &
                    nhep_out(1:vec_count), &
                    nhepp_out(1:vec_count), &
                    t_in(1:vec_count), &
                    vec_count)
         nhp(orig_idx(1:vec_count)) = nhp_out(1:vec_count)
         nhep(orig_idx(1:vec_count)) = nhep_out(1:vec_count)
         nhepp(orig_idx(1:vec_count)) = nhepp_out(1:vec_count)

         ! Forward difference derivatives
         do i = 1, veclen
           if (ne(i) .gt. 0.0d0) then
              eps(i) = xacc*ne(i)
           else
              eps(i) = 1.0d-24
           endif
         end do
         do i = 1, veclen
           mu(i) = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne(i)+eps(i))
           t(i)  = gamma_minus_1*mproton/boltzmann * u(i) * mu(i)
         end do
         vec_count = 0
         do i = 1, veclen
           if (t(i) .ge. tcoolmax_r) then ! Fully ionized plasma
             nhp_plus(i)   = 1.0d0
             nhep_plus(i)  = 0.0d0
             nhepp_plus(i) = yhelium
           else
             vec_count = vec_count + 1
             u_in(vec_count) = u(i)
             t_in(vec_count) = t(i)
             nh_in(vec_count) = nh(i)
             ne_in(vec_count) = ne(i)+eps(i)
             orig_idx(vec_count) = i
           endif
         end do

         call ion_n_vec(jh(1:vec_count), &
                    jhe(1:vec_count), &
                    u_in(1:vec_count), &
                    nh_in(1:vec_count), &
                    ne_in(1:vec_count), &
                    nhp_out(1:vec_count), &
                    nhep_out(1:vec_count), &
                    nhepp_out(1:vec_count), &
                    t_in(1:vec_count), &
                    vec_count)
         nhp_plus(orig_idx(1:vec_count)) = nhp_out(1:vec_count)
         nhep_plus(orig_idx(1:vec_count)) = nhep_out(1:vec_count)
         nhepp_plus(orig_idx(1:vec_count)) = nhepp_out(1:vec_count)

         do i = 1, veclen
           dnhp_dne(i)   = (nhp_plus(i)   - nhp(i))   / eps(i)
           dnhep_dne(i)  = (nhep_plus(i)  - nhep(i))  / eps(i)
           dnhepp_dne(i) = (nhepp_plus(i) - nhepp(i)) / eps(i)
         end do

         do i = 1, veclen
           f(i)   = ne(i) - nhp(i) - nhep(i) - 2.0d0*nhepp(i)
           df(i)  = 1.0d0 - dnhp_dne(i) - dnhep_dne(i) - 2.0d0*dnhepp_dne(i)
           dne(i) = f(i)/df(i)
         end do

         do i = 1, veclen
           ne(i) = max((ne(i)-dne(i)), 0.0d0)
         end do

         if (maxval(abs(dne(1:veclen))) < xacc) exit

         if (ii .gt. 15) &
            stop 'iterate_ne_vec(): No convergence in Newton-Raphson!'

      enddo

      ! Get rates for the final ne
      do i = 1, veclen
        mu(i) = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne(i))
        t(i)  = gamma_minus_1*mproton/boltzmann * u(i) * mu(i)
      end do
      vec_count = 0
      do i = 1, veclen
        if (t(i) .ge. tcoolmax_r) then ! Fully ionized plasma
          nhp(i)   = 1.0d0
          nhep(i)  = 0.0d0
          nhepp(i) = yhelium
        else
          vec_count = vec_count + 1
          u_in(vec_count) = u(i)
          t_in(vec_count) = t(i)
          nh_in(vec_count) = nh(i)
          ne_in(vec_count) = ne(i)
          orig_idx(vec_count) = i
        endif
      end do
      call ion_n_vec(jh(1:vec_count), &
                 jhe(1:vec_count), &
                 u_in(1:vec_count), &
                 nh_in(1:vec_count), &
                 ne_in(1:vec_count), &
                 nhp_out(1:vec_count), &
                 nhep_out(1:vec_count), &
                 nhepp_out(1:vec_count), &
                 t_in(1:vec_count), &
                 vec_count)
      nhp(orig_idx(1:vec_count)) = nhp_out(1:vec_count)
      nhep(orig_idx(1:vec_count)) = nhep_out(1:vec_count)
      nhepp(orig_idx(1:vec_count)) = nhepp_out(1:vec_count)

      ! Neutral fractions:
      do i = 1, veclen
        nh0(i)   = 1.0d0 - nhp(i)
        nhe0(i)  = yhelium - (nhep(i) + nhepp(i))
      end do
      end subroutine iterate_ne_vec

     ! ****************************************************************************

      subroutine ion_n_vec(JH, JHe, U, nh, ne, nhp, nhep, nhepp, t, vec_count)

      use amrex_fort_module, only : rt => amrex_real
      use meth_params_module, only: gamma_minus_1
      use atomic_rates_module, ONLY: yhelium, mproton, boltzmann, &
                                     tcoolmin, tcoolmax, ncooltab, deltat, &
                                     alphahp, alphahep, alphahepp, alphad, &
                                     gammaeh0, gammaehe0, gammaehep, &
                                     ggh0, gghe0, gghep

      integer, intent(in) :: vec_count
      integer, dimension(vec_count), intent(in) :: JH, JHe
      real(rt), intent(in   ) :: U(vec_count), nh(vec_count), ne(vec_count)
      real(rt), intent(  out) :: nhp(vec_count), nhep(vec_count), nhepp(vec_count), t(vec_count)
      real(rt) :: ahp(vec_count), ahep(vec_count), ahepp(vec_count), ad(vec_count), geh0(vec_count), gehe0(vec_count), gehep(vec_count)
      real(rt) :: ggh0ne(vec_count), gghe0ne(vec_count), gghepne(vec_count)
      real(rt) :: mu(vec_count), tmp(vec_count), logT(vec_count), flo(vec_count), fhi(vec_count)
      real(rt), parameter :: smallest_val=tiny(1.0d0)
      integer :: j(vec_count), i

      mu(:) = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne(:))
      t(:)  = gamma_minus_1*mproton/boltzmann * u(:) * mu(:)

      logt(1:vec_count) = dlog10(t(1:vec_count))

      ! Temperature floor
      do i = 1, vec_count
        if (logt(i) .le. tcoolmin) logt(i) = tcoolmin + 0.5d0*deltat
      end do

      ! Interpolate rates
      do i = 1, vec_count
        tmp(i) = (logt(i)-tcoolmin)/deltat
        j(i) = int(tmp(i))
        fhi(i) = tmp(i) - j(i)
        flo(i) = 1.0d0 - fhi(i)
        j(i) = j(i) + 1 ! F90 arrays start with 1
      end do

      do i = 1, vec_count
        ahp(i)   = flo(i)*alphahp(j(i)) + fhi(i)*alphahp(j(i)+1)
        ahep(i)  = flo(i)*alphahep(j(i)) + fhi(i)*alphahep(j(i)+1)
        ahepp(i) = flo(i)*alphahepp(j(i)) + fhi(i)*alphahepp(j(i)+1)
        ad(i)    = flo(i)*alphad(j(i)) + fhi(i)*alphad(j(i)+1)
        geh0(i)  = flo(i)*gammaeh0(j(i)) + fhi(i)*gammaeh0(j(i)+1)
        gehe0(i) = flo(i)*gammaehe0(j(i)) + fhi(i)*gammaehe0(j(i)+1)
        gehep(i) = flo(i)*gammaehep(j(i)) + fhi(i)*gammaehep(j(i)+1)
      end do

      do i = 1, vec_count
        if (ne(i) .gt. 0.0d0) then
           ggh0ne(i)   = jh(i)  * ggh0  / (ne(i)*nh(i))
           gghe0ne(i)  = jh(i)  * gghe0 / (ne(i)*nh(i))
           gghepne(i)  = jhe(i) * gghep / (ne(i)*nh(i))
        else
           ggh0ne(i)   = 0.0d0
           gghe0ne(i)  = 0.0d0
           gghepne(i)  = 0.0d0
        endif
      end do

      ! H+
      do i = 1, vec_count
        nhp(i) = 1.0d0 - ahp(i)/(ahp(i) + geh0(i) + ggh0ne(i))
      end do

      ! He+
      do i = 1, vec_count
        if ((gehe0(i) + gghe0ne(i)) .gt. smallest_val) then
  
           nhep(i)  = yhelium/(1.0d0 + (ahep(i)  + ad(i)     )/(gehe0(i) + gghe0ne(i)) &
                                  + (gehep(i) + gghepne(i))/ahepp(i))
        else
           nhep(i)  = 0.0d0
        endif
      end do

      ! He++
      do i = 1, vec_count
        if (nhep(i) .gt. 0.0d0) then
           nhepp(i) = nhep(i)*(gehep(i) + gghepne(i))/ahepp(i)
        else
           nhepp(i) = 0.0d0
        endif
      end do

      end subroutine ion_n_vec

     ! ****************************************************************************

      subroutine iterate_ne(JH, JHe, z, U, t, nh, ne, nh0, nhp, nhe0, nhep, nhepp)

      use amrex_error_module, only: amrex_abort, amrex_error
      use atomic_rates_module, only: this_z, yhelium

      integer :: i

      integer, intent(in) :: JH, JHe
      real(rt), intent (in   ) :: z, U, nh
      real(rt), intent (inout) :: ne
      real(rt), intent (  out) :: t, nh0, nhp, nhe0, nhep, nhepp

      real(rt) :: f, df, eps
      real(rt) :: nhp_plus, nhep_plus, nhepp_plus
      real(rt) :: dnhp_dne, dnhep_dne, dnhepp_dne, dne
      character(len=128) :: errmsg

      ! Check if we have interpolated to this z
      if (abs(z-this_z) .gt. xacc*z) then
          write(errmsg, *) "iterate_ne(): Wrong redshift! z = ", z, " but this_z = ", this_z
          call amrex_abort(errmsg)
      end if

      i = 0
      ne = 1.0d0 ! 0 is a bad guess
      do  ! Newton-Raphson solver
         i = i + 1

         ! Ion number densities
         call ion_n(jh, jhe, u, nh, ne, nhp, nhep, nhepp, t)

         ! Forward difference derivatives
         if (ne .gt. 0.0d0) then
            eps = xacc*ne
         else
            eps = 1.0d-24
         endif
         call ion_n(jh, jhe, u, nh, (ne+eps), nhp_plus, nhep_plus, nhepp_plus, t)

         dnhp_dne   = (nhp_plus   - nhp)   / eps
         dnhep_dne  = (nhep_plus  - nhep)  / eps
         dnhepp_dne = (nhepp_plus - nhepp) / eps

         f   = ne - nhp - nhep - 2.0d0*nhepp
         df  = 1.0d0 - dnhp_dne - dnhep_dne - 2.0d0*dnhepp_dne
         dne = f/df

         ne = max((ne-dne), 0.0d0)

         if (abs(dne) < xacc) exit

         !$OMP CRITICAL
         if (i .gt. 12) then
            print*, "ITERATION: ", i, " NUMBERS: ", z, t, ne, nhp, nhep, nhepp, df
            call amrex_error('iterate_ne(): No convergence in Newton-Raphson!')
         endif
         !$OMP END CRITICAL

      enddo

      ! Get rates for the final ne
      call ion_n(jh, jhe, u, nh, ne, nhp, nhep, nhepp, t)

      ! Neutral fractions:
      nh0   = 1.0d0 - nhp
      nhe0  = yhelium - (nhep + nhepp)
      end subroutine iterate_ne

     ! ****************************************************************************

      subroutine ion_n(JH, JHe, U, nh, ne, nhp, nhep, nhepp, t)

      use meth_params_module,  only: gamma_minus_1
      use atomic_rates_module, only: yhelium, mproton, boltzmann, &
                                     tcoolmin, tcoolmax, ncooltab, deltat, &
                                     alphahp, alphahep, alphahepp, alphad, &
                                     gammaeh0, gammaehe0, gammaehep, &
                                     ggh0, gghe0, gghep

      integer, intent(in) :: JH, JHe
      real(rt), intent(in   ) :: U, nh, ne
      real(rt), intent(  out) :: nhp, nhep, nhepp, t
      real(rt) :: ahp, ahep, ahepp, ad, geh0, gehe0, gehep
      real(rt) :: ggh0ne, gghe0ne, gghepne
      real(rt) :: mu, tmp, logT, flo, fhi
      real(rt), parameter :: smallest_val=tiny(1.0d0)
      integer :: j


      mu = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne)
      t  = gamma_minus_1*mproton/boltzmann * u * mu

      logt = dlog10(t)
      if (logt .ge. tcoolmax) then ! Fully ionized plasma
         nhp   = 1.0d0
         nhep  = 0.0d0
         nhepp = yhelium
         return
      endif

      ! Temperature floor
      if (logt .le. tcoolmin) logt = tcoolmin + 0.5d0*deltat

      ! Interpolate rates
      tmp = (logt-tcoolmin)/deltat
      j = int(tmp)
      fhi = tmp - j
      flo = 1.0d0 - fhi
      j = j + 1 ! F90 arrays start with 1

      ahp   = flo*alphahp(j) + fhi*alphahp(j+1)
      ahep  = flo*alphahep(j) + fhi*alphahep(j+1)
      ahepp = flo*alphahepp(j) + fhi*alphahepp(j+1)
      ad    = flo*alphad(j) + fhi*alphad(j+1)
      geh0  = flo*gammaeh0(j) + fhi*gammaeh0(j+1)
      gehe0 = flo*gammaehe0(j) + fhi*gammaehe0(j+1)
      gehep = flo*gammaehep(j) + fhi*gammaehep(j+1)

      if (ne .gt. 0.0d0) then
         ggh0ne   = jh  * ggh0  / (ne*nh)
         gghe0ne  = jh  * gghe0 / (ne*nh)
         gghepne  = jhe * gghep / (ne*nh)
      else
         ggh0ne   = 0.0d0
         gghe0ne  = 0.0d0
         gghepne  = 0.0d0
      endif

      ! H+
      nhp = 1.0d0 - ahp/(ahp + geh0 + ggh0ne)

      ! He+
      if ((gehe0 + gghe0ne) .gt. smallest_val) then

         nhep  = yhelium/(1.0d0 + (ahep  + ad     )/(gehe0 + gghe0ne) &
                                + (gehep + gghepne)/ahepp)
      else
         nhep  = 0.0d0
      endif

      ! He++
      if (nhep .gt. 0.0d0) then
         nhepp = nhep*(gehep + gghepne)/ahepp
      else
         nhepp = 0.0d0
      endif

      end subroutine ion_n


end module eos_module
````

