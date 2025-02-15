
# File fcvode\_extras.f90

[**File List**](files.md) **>** [**HeatCool**](dir_8c890215953ac09098af8cb94c8b9fc0.md) **>** [**fcvode\_extras.f90**](fcvode__extras_8f90.md)

[Go to the documentation of this file.](fcvode__extras_8f90.md) 


````cpp
module fcvode_extras

  implicit none

  contains

    subroutine fcvode_wrapper(dt, rho_in, T_in, ne_in, e_in, neq, cvmem, &
                              sunvec_y, yvec, T_out, ne_out, e_out)

        use amrex_fort_module, only : rt => amrex_real
        use vode_aux_module, only: rho_vode, t_vode, ne_vode, z_vode
        use atomic_rates_module, only: this_z
        use cvode_interface
        use fnvector_serial
        use eos_module, only: vode_rtol, vode_atol_scaled
        use, intrinsic :: iso_c_binding

        implicit none

        real(rt), intent(in   ) :: dt
        real(rt), intent(in   ) :: rho_in, T_in, ne_in, e_in
        type(c_ptr), value :: cvmem
        type(c_ptr), value :: sunvec_y
        real(rt), intent(  out) ::         T_out,ne_out,e_out

        real(c_double) :: atol, rtol
        real(c_double) :: time, tout
        integer(c_long), intent(in) :: neq
        real(c_double), pointer, intent(in) :: yvec(:)

        integer(c_int) :: ierr

        real(c_double) :: t_soln

        t_vode   = t_in
        ne_vode  = ne_in
        rho_vode = rho_in

        ! Initialize the integration time
        time = 0.d0

        ! We will integrate "e" in time. 
        yvec(1) = e_in

        ! Set the tolerances.  
        atol = vode_atol_scaled * e_in
        rtol = vode_rtol

        ierr = fcvodereinit(cvmem, time, sunvec_y)
        ierr = fcvodesstolerances(cvmem, rtol, atol)

        ierr = fcvode(cvmem, dt, sunvec_y, time, cv_normal)

        e_out  = yvec(1)
        t_out  = t_vode
        ne_out = ne_vode

    end subroutine fcvode_wrapper

    subroutine fcvode_wrapper_vec(dt, rho_in, T_in, ne_in, e_in, neq, cvmem, &
                              sunvec_y, yvec, T_out, ne_out, e_out)

        use amrex_fort_module, only : rt => amrex_real
        use vode_aux_module, only: rho_vode_vec, t_vode_vec, ne_vode_vec
        use cvode_interface
        use fnvector_serial
        use misc_params, only: simd_width
        use eos_module, only: vode_rtol, vode_atol_scaled
        use, intrinsic :: iso_c_binding

        implicit none

        real(rt), intent(in   ) :: dt
        real(rt), dimension(simd_width), intent(in   ) :: rho_in, T_in, ne_in, e_in
        type(c_ptr), value :: cvmem
        type(c_ptr), value :: sunvec_y
        real(rt), dimension(simd_width), intent(  out) ::         T_out,ne_out,e_out

        real(c_double) :: rtol
        real(c_double), pointer, dimension(:) :: atol
        real(c_double) :: time, tout
        integer(c_long), intent(in) :: neq
        real(c_double), pointer, intent(in) :: yvec(:)
        type(c_ptr) :: sunvec_atol

        integer(c_int) :: ierr

        real(c_double) :: t_soln

        allocate(atol(simd_width))

        sunvec_atol = n_vmake_serial(neq, atol)

        t_vode_vec(1:simd_width)   = t_in(1:simd_width)
        ne_vode_vec(1:simd_width)  = ne_in(1:simd_width)
        rho_vode_vec(1:simd_width) = rho_in(1:simd_width)

        ! Initialize the integration time
        time = 0.d0

        ! We will integrate "e" in time. 
        yvec(1:simd_width) = e_in(1:simd_width)

        ! Set the tolerances.  
        atol(1:simd_width) = vode_atol_scaled * e_in(1:simd_width)
        rtol = vode_rtol

        ierr = fcvodereinit(cvmem, time, sunvec_y)
        ierr = fcvodesvtolerances(cvmem, rtol, sunvec_atol)

        ierr = fcvode(cvmem, dt, sunvec_y, time, cv_normal)

        e_out(1:simd_width)  = yvec(1:simd_width)
        t_out(1:simd_width)  = t_vode_vec(1:simd_width)
        ne_out(1:simd_width) = ne_vode_vec(1:simd_width)

        call n_vdestroy_serial(sunvec_atol)
        deallocate(atol)

    end subroutine fcvode_wrapper_vec

    integer(c_int) function rhsfn(tn, sunvec_y, sunvec_f, user_data) &
           result(ierr) bind(c,name='RhsFn')

      use, intrinsic :: iso_c_binding
      use fnvector_serial
      use cvode_interface
      implicit none

      real(c_double), value :: tn
      type(c_ptr), value    :: sunvec_y
      type(c_ptr), value    :: sunvec_f
      type(c_ptr), value    :: user_data

      ! pointers to data in SUNDAILS vectors
      real(c_double), pointer :: yvec(:)
      real(c_double), pointer :: fvec(:)

      real(c_double) :: energy

      integer(c_long), parameter :: neq = 1

      ! get data arrays from SUNDIALS vectors
      call n_vgetdata_serial(sunvec_y, neq, yvec)
      call n_vgetdata_serial(sunvec_f, neq, fvec)

      call f_rhs(1, tn, yvec(1), energy, 0.0, 0)

      fvec(1) = energy

      ierr = 0
    end function rhsfn


    integer(c_int) function rhsfn_vec(tn, sunvec_y, sunvec_f, user_data) &
           result(ierr) bind(c,name='RhsFn_vec')

      use, intrinsic :: iso_c_binding
      use fnvector_serial
      use cvode_interface
      use misc_params, only: simd_width
      implicit none

      real(c_double), value :: tn
      type(c_ptr), value    :: sunvec_y, sunvec_f, user_data

      ! pointers to data in SUNDAILS vectors
      real(c_double), dimension(:), pointer :: yvec, fvec

      integer(c_long) :: neq
      real(c_double) :: energy(simd_width)

      neq = int(simd_width, c_long)

      ! get data arrays from SUNDIALS vectors
      call n_vgetdata_serial(sunvec_y, neq, yvec)
      call n_vgetdata_serial(sunvec_f, neq, fvec)

      call f_rhs_vec(tn, yvec, energy)

      fvec = energy

      ierr = 0
    end function rhsfn_vec

end module fcvode_extras
````

