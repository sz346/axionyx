
# File integrate\_state\_vode\_3d.f90

[**File List**](files.md) **>** [**HeatCool**](dir_8c890215953ac09098af8cb94c8b9fc0.md) **>** [**integrate\_state\_vode\_3d.f90**](integrate__state__vode__3d_8f90.md)

[Go to the documentation of this file.](integrate__state__vode__3d_8f90.md) 


````cpp
subroutine integrate_state_vode(lo, hi, &
                                state   , s_l1, s_l2, s_l3, s_h1, s_h2, s_h3, &
                                diag_eos, d_l1, d_l2, d_l3, d_h1, d_h2, d_h3, &
                                a, half_dt, min_iter, max_iter)
!
!   Calculates the sources to be added later on.
!
!   Parameters
!   ----------
!   lo : double array (3)
!       The low corner of the current box.
!   hi : double array (3)
!       The high corner of the current box.
!   state_* : double arrays
!       The state vars
!   diag_eos_* : double arrays
!       Temp and Ne
!   src_* : doubles arrays
!       The source terms to be added to state (iterative approx.)
!   double array (3)
!       The low corner of the entire domain
!   a : double
!       The current a
!   half_dt : double
!       time step size, in Mpc km^-1 s ~ 10^12 yr.
!
!   Returns
!   -------
!   state : double array (dims) @todo
!       The state vars
!
    use amrex_error_module, only : amrex_abort
    use amrex_fort_module , only : rt => amrex_real
    use meth_params_module, only : nvar, urho, ueden, ueint, &
                                   ndiag, temp_comp, ne_comp, zhi_comp, gamma_minus_1
    use amrex_constants_module, only: m_pi
    use eos_params_module
    use network
    use eos_module, only: nyx_eos_t_given_re, nyx_eos_given_rt
    use fundamental_constants_module
    use comoving_module, only: comoving_h, comoving_omb
    use comoving_nd_module, only: fort_integrate_comoving_a
    use atomic_rates_module, only: yhelium
    use vode_aux_module    , only: jh_vode, jhe_vode, z_vode, i_vode, j_vode, k_vode
    use reion_aux_module   , only: zhi_flash, zheii_flash, flash_h, flash_he, &
                                   t_zhi, t_zheii, inhomogeneous_on

    implicit none

    integer         , intent(in) :: lo(3), hi(3)
    integer         , intent(in) :: s_l1, s_l2, s_l3, s_h1, s_h2, s_h3
    integer         , intent(in) :: d_l1, d_l2, d_l3, d_h1, d_h2, d_h3
    real(rt), intent(inout) ::    state(s_l1:s_h1, s_l2:s_h2,s_l3:s_h3, NVAR)
    real(rt), intent(inout) :: diag_eos(d_l1:d_h1, d_l2:d_h2,d_l3:d_h3, NDIAG)
    real(rt), intent(in)    :: a, half_dt
    integer         , intent(inout) :: max_iter, min_iter

    integer :: i, j, k
    real(rt) :: z, z_end, a_end, rho, H_reion_z, He_reion_z
    real(rt) :: T_orig, ne_orig, e_orig
    real(rt) :: T_out , ne_out , e_out, mu, mean_rhob, T_H, T_He
    real(rt) :: species(5)

    z = 1.d0/a - 1.d0
    call fort_integrate_comoving_a(a, a_end, half_dt)
    z_end = 1.0d0/a_end - 1.0d0

    mean_rhob = comoving_omb * 3.d0*(comoving_h*100.d0)**2 / (8.d0*m_pi*gconst)

    ! Flash reionization?
    if ((flash_h .eqv. .true.) .and. (z .gt. zhi_flash)) then
       jh_vode = 0
    else
       jh_vode = 1
    endif
    if ((flash_he .eqv. .true.) .and. (z .gt. zheii_flash)) then
       jhe_vode = 0
    else
       jhe_vode = 1
    endif

    if (flash_h ) h_reion_z  = zhi_flash
    if (flash_he) he_reion_z = zheii_flash

    ! Note that (lo,hi) define the region of the box containing the grow cells
    ! Do *not* assume this is just the valid region
    ! apply heating-cooling to UEDEN and UEINT

    do k = lo(3),hi(3)
        do j = lo(2),hi(2)
            do i = lo(1),hi(1)

                ! Original values
                rho     = state(i,j,k,urho)
                e_orig  = state(i,j,k,ueint) / rho
                t_orig  = diag_eos(i,j,k,temp_comp)
                ne_orig = diag_eos(i,j,k,  ne_comp)

                if (inhomogeneous_on) then
                   h_reion_z = diag_eos(i,j,k,zhi_comp)
                   if (z .gt. h_reion_z) then
                      jh_vode = 0
                   else
                      jh_vode = 1
                   endif
                endif

                if (e_orig .lt. 0.d0) then
                    !$OMP CRITICAL
                    print *,'negative e entering strang integration ', z, i,j,k, rho/mean_rhob, e_orig
                    call amrex_abort('bad e in strang')
                    !$OMP END CRITICAL
                end if

                i_vode = i
                j_vode = j
                k_vode = k

                call vode_wrapper(half_dt,rho,t_orig,ne_orig,e_orig, &
                                              t_out ,ne_out ,e_out)

                if (e_out .lt. 0.d0) then
                    !$OMP CRITICAL
                    print *,'negative e exiting strang integration ', z, i,j,k, rho/mean_rhob, e_out
                    call flush(6)
                    !$OMP END CRITICAL
                    t_out  = 10.0
                    ne_out = 0.0
                    mu     = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne_out)
                    e_out  = t_out / (gamma_minus_1 * mp_over_kb * mu)
                    !call amrex_abort('bad e out of strang')
                end if

                ! Update T and ne (do not use stuff computed in f_rhs, per vode manual)
                call nyx_eos_t_given_re(jh_vode, jhe_vode, t_out, ne_out, rho, e_out, a, species)

                ! Instanteneous heating from reionization:
                t_h = 0.0d0
                if (inhomogeneous_on .or. flash_h) then
                   if ((h_reion_z  .lt. z) .and. (h_reion_z  .ge. z_end)) t_h  = (1.0d0 - species(2))*max((t_zhi-t_out), 0.0d0)
                endif

                t_he = 0.0d0
                if (flash_he) then
                   if ((he_reion_z .lt. z) .and. (he_reion_z .ge. z_end)) t_he = (1.0d0 - species(5))*max((t_zheii-t_out), 0.0d0)
                endif

                if ((t_h .gt. 0.0d0) .or. (t_he .gt. 0.0d0)) then
                   t_out = t_out + t_h + t_he                            ! For simplicity, we assume
                   ne_out = 1.0d0 + yhelium                              !    completely ionized medium at
                   if (t_he .gt. 0.0d0) ne_out = ne_out + yhelium        !    this point.  It's a very minor
                   mu = (1.0d0+4.0d0*yhelium) / (1.0d0+yhelium+ne_out)   !    detail compared to the overall approximation.
                   e_out  = t_out / (gamma_minus_1 * mp_over_kb * mu)
                   call nyx_eos_t_given_re(jh_vode, jhe_vode, t_out, ne_out, rho, e_out, a, species)
                endif

                ! Update (rho e) and (rho E)
                state(i,j,k,ueint) = state(i,j,k,ueint) + rho * (e_out-e_orig)
                state(i,j,k,ueden) = state(i,j,k,ueden) + rho * (e_out-e_orig)

                ! Update T and ne
                diag_eos(i,j,k,temp_comp) = t_out
                diag_eos(i,j,k,  ne_comp) = ne_out

            end do ! i
        end do ! j
    end do ! k

end subroutine integrate_state_vode


subroutine vode_wrapper(dt, rho_in, T_in, ne_in, e_in, T_out, ne_out, e_out)

    use amrex_error_module, only : amrex_error
    use amrex_fort_module, only : rt => amrex_real
    use vode_aux_module, only: rho_vode, t_vode, ne_vode, &
                               i_vode, j_vode, k_vode

    implicit none

    real(rt), intent(in   ) :: dt
    real(rt), intent(in   ) :: rho_in, T_in, ne_in, e_in
    real(rt), intent(  out) ::         T_out,ne_out,e_out

    ! Set the number of independent variables -- this should be just "e"
    integer, parameter :: NEQ = 1
  
    ! Allocate storage for the input state
    real(rt) :: y(NEQ)

    ! Our problem is stiff, tell ODEPACK that. 21 means stiff, jacobian 
    ! function is supplied, 22 means stiff, figure out my jacobian through 
    ! differencing
    integer, parameter :: MF_ANALYTIC_JAC = 21, mf_numerical_jac = 22

    ! Tolerance parameters:
    !
    !  itol specifies whether to use an single absolute tolerance for
    !  all variables (1), or to pass an array of absolute tolerances, one
    !  for each variable with a scalar relative tol (2), a scalar absolute
    !  and array of relative tolerances (3), or arrays for both (4)
    !  
    !  The error is determined as e(i) = rtol*abs(y(i)) + atol, and must
    !  be > 0.  
    !
    ! We will use arrays for both the absolute and relative tolerances, 
    ! since we want to be easier on the temperature than the species

    integer, parameter :: ITOL = 1
    real(rt) :: atol(NEQ), rtol(NEQ)
    
    ! We want to do a normal computation, and get the output values of y(t)
    ! after stepping though dt
    integer, PARAMETER :: ITASK = 1
  
    ! istate determines the state of the calculation.  A value of 1 meeans
    ! this is the first call to the problem -- this is what we will want.
    ! Note, istate is changed over the course of the calculation, so it
    ! cannot be a parameter
    integer :: istate

    ! we will override the maximum number of steps, so turn on the 
    ! optional arguments flag
    integer, parameter :: IOPT = 1
    
    ! declare a real work array of size 22 + 9*NEQ + 2*NEQ**2 and an
    ! integer work array of since 30 + NEQ

    integer, parameter :: LRW = 22 + 9*neq + 2*neq**2
    real(rt)   :: rwork(LRW)
    real(rt)   :: time
    ! real(rt)   :: dt4
    
    integer, parameter :: LIW = 30 + neq
    integer, dimension(LIW) :: iwork
    
    real(rt) :: rpar
    integer          :: ipar

    EXTERNAL jac, f_rhs
    
    logical, save :: firstCall = .true.

    t_vode   = t_in
    ne_vode  = ne_in
    rho_vode = rho_in

    ! We want VODE to re-initialize each time we call it
    istate = 1
    
    rwork(:) = 0.d0
    iwork(:) = 0
    
    ! Set the maximum number of steps allowed (the VODE default is 500)
    iwork(6) = 2000
    
    ! Initialize the integration time
    time = 0.d0
    
    ! We will integrate "e" in time. 
    y(1) = e_in

    ! Set the tolerances.  
    atol(1) = 1.d-4 * e_in
    rtol(1) = 1.d-4

    ! call the integration routine
    call dvode(f_rhs, neq, y, time, dt, itol, rtol, atol, itask, &
               istate, iopt, rwork, lrw, iwork, liw, jac, mf_numerical_jac, &
               rpar, ipar)

    e_out  = y(1)
    t_out  = t_vode
    ne_out = ne_vode

    if (istate < 0) then
       print *, 'istate = ', istate, 'at (i,j,k) ',i_vode,j_vode,k_vode
       call amrex_error("ERROR in vode_wrapper: integration failed")
    endif

!      print *,'Calling vode with 1/4 the time step'
!      dt4 = 0.25d0  * dt
!      y(1) = e_in

!      do n = 1,4
!         call dvode(f_rhs, NEQ, y, time, dt4, ITOL, rtol, atol, ITASK, &
!                    istate, IOPT, rwork, LRW, iwork, LIW, jac, MF_NUMERICAL_JAC, &
!                    rpar, ipar)
!         if (istate < 0) then
!            print *, 'doing subiteration ',n
!            print *, 'istate = ', istate, 'at (i,j,k) ',i,j,k
!            call amrex_error("ERROR in vode_wrapper: sub-integration failed")
!         end if

!      end do
!   endif

end subroutine vode_wrapper
````

