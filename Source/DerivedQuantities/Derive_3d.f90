
!-----------------------------------------------------------------------

      subroutine derstate(state,state_l1,state_l2,state_l3,state_h1,state_h2,state_h3,nv, &
                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                             domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! The incoming   "dat" vector contains (rho,T,(rho X)_1)
      ! The outgoing "state" vector contains (rho,T,X_1)
      !
      use amrex_fort_module, only : rt => amrex_real
      use amrex_error_module, only : amrex_error
      implicit none 

      integer          lo(3), hi(3)
      integer          state_l1,state_l2,state_l3,state_h1,state_h2,state_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) state(state_l1:state_h1,state_l2:state_h2,state_l3:state_h3,nv)
      real(rt) dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no
 
      integer i,j,k

      if (nv .ne. 3) then
          print *,'... confusion in derstate ... nv should be 3 but is ',nv
          call amrex_error('Error:: Derive_3d.f90 :: derstate')
      end if
      !
      ! Density
      !
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               state(i,j,k,1) = dat(i,j,k,1)
            end do
         end do
      end do
      !
      ! Temperature
      !
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               state(i,j,k,2) = dat(i,j,k,2)
            end do
         end do
      end do
      !
      ! (rho X)_1 --> X_1
      !
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               state(i,j,k,3) = dat(i,j,k,3) / dat(i,j,k,1)
            end do
         end do
      end do
 
      end subroutine derstate

!-----------------------------------------------------------------------

      subroutine dervel(vel,vel_l1,vel_l2,vel_l3,vel_h1,vel_h2,vel_h3,nv, &
                           dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                           domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! Derive velocity from momentum.
      !
      use amrex_fort_module, only : rt => amrex_real
      use amrex_error_module, only : amrex_error
      implicit none

      integer          lo(3), hi(3)
      integer          vel_l1,vel_l2,vel_l3,vel_h1,vel_h2,vel_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) vel(vel_l1:vel_h1,vel_l2:vel_h2,vel_l3:vel_h3,nv)
      real(rt) dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no
 
      integer i,j,k
      ! 
      ! Here dat contains (Density, Single Component of Momentum)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               vel(i,j,k,1) = dat(i,j,k,2) / dat(i,j,k,1)
            end do
         end do
      end do
 
      end subroutine dervel

!-----------------------------------------------------------------------

      subroutine dermagvel(magvel,vel_l1,vel_l2,vel_l3,vel_h1,vel_h2,vel_h3,nv, &
                              dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                              domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! Derive magnitude of velocity.
      !
        use amrex_fort_module, only : rt => amrex_real
        use amrex_error_module, only : amrex_error
      implicit none

      integer          lo(3), hi(3)
      integer          vel_l1,vel_l2,vel_l3,vel_h1,vel_h2,vel_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) magvel(vel_l1:vel_h1,vel_l2:vel_h2,vel_l3:vel_h3,nv)
      real(rt)    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      integer i,j,k
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               magvel(i,j,k,1) = sqrt( (dat(i,j,k,2) / dat(i,j,k,1))**2 + &
                                       (dat(i,j,k,3) / dat(i,j,k,1))**2 + &
                                       (dat(i,j,k,4) / dat(i,j,k,1))**2 )
            end do
         end do
      end do

      end subroutine dermagvel

!-----------------------------------------------------------------------

      subroutine dermaggrav(maggrav,grav_l1,grav_l2,grav_l3,grav_h1,grav_h2,grav_h3,ng, &
                               dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                               domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! Derive magnitude of the gravity vector.
      !
      use amrex_fort_module, only : rt => amrex_real
      use amrex_error_module, only : amrex_error
      implicit none 

      integer          lo(3), hi(3)
      integer          grav_l1,grav_l2,grav_l3,grav_h1,grav_h2,grav_h3,ng
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) maggrav(grav_l1:grav_h1,grav_l2:grav_h2,grav_l3:grav_h3,ng)
      real(rt)     dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      integer i,j,k
      ! 
      ! Here dat contains (grav_x, grav_y, grav_z)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               maggrav(i,j,k,1) = sqrt( dat(i,j,k,1)**2  + &
                                        dat(i,j,k,2)**2  + &
                                        dat(i,j,k,3)**2 )
            end do
         end do
      end do

      end subroutine dermaggrav

!-----------------------------------------------------------------------

      subroutine dermagmom(magmom,mom_l1,mom_l2,mom_l3,mom_h1,mom_h2,mom_h3,nv, &
                              dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                              domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine will derive magnitude of momentum.
      !
      use amrex_fort_module, only : rt => amrex_real
      use amrex_error_module, only : amrex_error
      implicit none

      integer          lo(3), hi(3)
      integer          mom_l1,mom_l2,mom_l3,mom_h1,mom_h2,mom_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) magmom(mom_l1:mom_h1,mom_l2:mom_h2,mom_l3:mom_h3,nv)
      real(rt)    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      integer i,j,k
      ! 
      ! Here dat contains (Xmom, Ymom, Zmom)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               magmom(i,j,k,1) = sqrt( dat(i,j,k,1)**2 + dat(i,j,k,2)**2 + dat(i,j,k,3)**2 )
            end do
         end do
      end do

      end subroutine dermagmom

!-----------------------------------------------------------------------

      subroutine derpres(p,p_l1,p_l2,p_l3,p_h1,p_h2,p_h3,ncomp_p, &
           u,u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u,lo,hi,domlo, &
           domhi,dx,xlo,time,dt,bc,level,grid_no)
      !
      ! Compute pressure from (rho e)
      !
      use meth_params_module, only : UEINT, gamma_minus_1
      use  eos_params_module

      use amrex_fort_module, only : rt => amrex_real
      use amrex_error_module, only : amrex_error
      implicit none

      integer p_l1,p_l2,p_l3,p_h1,p_h2,p_h3,ncomp_p
      integer u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u
      integer lo(3), hi(3), domlo(3), domhi(3)
      real(rt) p(p_l1:p_h1,p_l2:p_h2,p_l3:p_h3,ncomp_p)
      real(rt) u(u_l1:u_h1,u_l2:u_h2,u_l3:u_h3,ncomp_u)
      real(rt) dx(3), xlo(3), time, dt
      integer bc(3,2,ncomp_u), level, grid_no

      integer          :: i,j,k
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom, (rho E), (rho e))
      ! 
      do k = lo(3),hi(3)
         do j = lo(2),hi(2)
            do i = lo(1),hi(1)

               !
               ! Protect against negative internal energy.
               !
               if (u(i,j,k,UEINT) .le. 0.d0) then
                  print *,'   '
                  print *,'>>> Error: deriving pressure at ',i,j,k
                  print *,'>>> but rho*eint is negative: ', u(i,j,k,UEINT)
                  print *,'    '
                  call amrex_error("Error:: Derive_3d.f90 :: derpres")
               else
                  p(i,j,k,1) = gamma_minus_1 * u(i,j,k,UEINT)
               end if

            enddo
         enddo
      enddo

      end subroutine derpres

!-----------------------------------------------------------------------

      subroutine dereint1(e,e_l1,e_l2,e_l3,e_h1,e_h2,e_h3,ncomp_e, &
           u,u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u,lo,hi,domlo, &
           domhi,dx,xlo,time,dt,bc,level,grid_no)
      !
      ! Compute internal energy from (rho E).
      !
      use meth_params_module, only : URHO, UMX, UMY, UMZ, UEDEN 

      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer e_l1,e_l2,e_l3,e_h1,e_h2,e_h3,ncomp_e
      integer u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u
      integer lo(3), hi(3), domlo(3), domhi(3)
      real(rt) e(e_l1:e_h1,e_l2:e_h2,e_l3:e_h3,ncomp_e)
      real(rt) u(u_l1:u_h1,u_l2:u_h2,u_l3:u_h3,ncomp_u)
      real(rt) dx(3), xlo(3), time, dt
      integer bc(3,2,ncomp_u), level, grid_no

      real(rt) :: rhoInv,ux,uy,uz
      integer          :: i,j,k
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom, (rho E), (rho e))
      ! 
      do k = lo(3),hi(3)
         do j = lo(2),hi(2)
            do i = lo(1),hi(1)
               rhoInv = 1.d0/u(i,j,k,URHO)
               ux = u(i,j,k,UMX)*rhoInv
               uy = u(i,j,k,UMY)*rhoInv
               uz = u(i,j,k,UMZ)*rhoInv
               e(i,j,k,1) = u(i,j,k,UEDEN)*rhoInv-0.5d0*(ux**2+uy**2+uz**2)
            enddo
         enddo
      enddo

      end subroutine dereint1

!-----------------------------------------------------------------------

      subroutine dereint2(e,e_l1,e_l2,e_l3,e_h1,e_h2,e_h3,ncomp_e, &
           u,u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u,lo,hi,domlo, &
           domhi,dx,xlo,time,dt,bc,level,grid_no)

      use meth_params_module, only : URHO, UEINT

      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer e_l1,e_l2,e_l3,e_h1,e_h2,e_h3,ncomp_e
      integer u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u
      integer lo(3), hi(3), domlo(3), domhi(3)
      real(rt) e(e_l1:e_h1,e_l2:e_h2,e_l3:e_h3,ncomp_e)
      real(rt) u(u_l1:u_h1,u_l2:u_h2,u_l3:u_h3,ncomp_u)
      real(rt) dx(3), xlo(3), time, dt
      integer bc(3,2,ncomp_u), level, grid_no

      integer :: i,j,k
      !
      ! Compute internal energy from (rho e).
      !
      do k = lo(3),hi(3)
         do j = lo(2),hi(2)
            do i = lo(1),hi(1)
               e(i,j,k,1) = u(i,j,k,UEINT) / u(i,j,k,URHO)
            enddo
         enddo
      enddo

      end subroutine dereint2

!-----------------------------------------------------------------------

      subroutine dersoundspeed(c,c_l1,c_l2,c_l3,c_h1,c_h2,c_h3,ncomp_c, &
           u,u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u,lo,hi,domlo, &
           domhi,dx,xlo,time,dt,bc,level,grid_no)

      use amrex_fort_module, only : rt => amrex_real
      use eos_module
      use meth_params_module, only : URHO, UEINT
      use  eos_params_module
      implicit none

      integer c_l1,c_l2,c_l3,c_h1,c_h2,c_h3,ncomp_c
      integer u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u
      integer lo(3), hi(3), domlo(3), domhi(3)
      real(rt) c(c_l1:c_h1,c_l2:c_h2,c_l3:c_h3,ncomp_c)
      real(rt) u(u_l1:u_h1,u_l2:u_h2,u_l3:u_h3,ncomp_u)
      real(rt) dx(3), xlo(3), time, dt
      integer bc(3,2,ncomp_u), level, grid_no

      real(rt) :: e
      integer          :: i,j,k
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom, (rho E), (rho e))
      ! 

      !
      ! Compute soundspeed from the EOS.
      !
      do k = lo(3),hi(3)
         do j = lo(2),hi(2)
            do i = lo(1),hi(1)

               e      = u(i,j,k,UEINT) / u(i,j,k,URHO)

               if (e .gt. 0.d0) then
                  call nyx_eos_soundspeed(c(i,j,k,1), u(i,j,k,URHO), e)
               else
                  c(i,j,k,1) = 0.d0
               end if

            enddo
         enddo
      enddo

      end subroutine dersoundspeed

!-----------------------------------------------------------------------

      subroutine dermachnumber(mach,mach_l1,mach_l2,mach_l3,mach_h1,mach_h2,mach_h3,ncomp_mach, &
           u,u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u,lo,hi,domlo, &
           domhi,dx,xlo,time,dt,bc,level,grid_no)

      use amrex_fort_module, only : rt => amrex_real
      use eos_module
      use meth_params_module, only : URHO, UMX, UMY, UMZ, UEINT
      use  eos_params_module
      implicit none

      integer          :: mach_l1,mach_l2,mach_l3,mach_h1,mach_h2,mach_h3,ncomp_mach
      integer          :: u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u
      integer          :: lo(3), hi(3), domlo(3), domhi(3)
      real(rt) :: mach(mach_l1:mach_h1,mach_l2:mach_h2,mach_l3:mach_h3,ncomp_mach)
      real(rt) :: u(u_l1:u_h1,u_l2:u_h2,u_l3:u_h3,ncomp_u)
      real(rt) :: dx(3), xlo(3), time, dt
      integer          :: bc(3,2,ncomp_u), level, grid_no

      real(rt) :: rhoInv,ux,uy,uz,e,c
      integer          :: i,j,k
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom, (rho E), (rho e))
      ! 

      ! 
      ! Compute Mach number of the flow.
      !
      do k = lo(3),hi(3)
         do j = lo(2),hi(2)
            do i = lo(1),hi(1)

               rhoInv = 1.d0 / u(i,j,k,URHO)
               ux     = u(i,j,k,UMX)*rhoInv
               uy     = u(i,j,k,UMY)*rhoInv
               uz     = u(i,j,k,UMZ)*rhoInv
               e      = u(i,j,k,UEINT)*rhoInv

               if (e .gt. 0.d0) then
                  call nyx_eos_soundspeed(c, u(i,j,k,URHO), e)
                  mach(i,j,k,1) = sqrt(ux**2 + uy**2 + uz**2) / c
               else
                  mach(i,j,k,1) = 0.d0
               end if

            enddo
         enddo
      enddo

      end subroutine dermachnumber

!-----------------------------------------------------------------------

      subroutine derentropy(s,s_l1,s_l2,s_l3,s_h1,s_h2,s_h3,ncomp_s, &
                               u,u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u,lo,hi, &
                               domlo,domhi,dx,xlo,time,dt,bc,level,grid_no)
      !
      ! Compute entropy from the EOS.
      !
      use amrex_fort_module, only : rt => amrex_real
      use eos_module
      use meth_params_module, only : URHO, UEINT
      use  eos_params_module
      implicit none

      integer s_l1,s_l2,s_l3,s_h1,s_h2,s_h3,ncomp_s
      integer u_l1,u_l2,u_l3,u_h1,u_h2,u_h3,ncomp_u
      integer lo(3), hi(3), domlo(3), domhi(3)
      real(rt) s(s_l1:s_h1,s_l2:s_h2,s_l3:s_h3,ncomp_s)
      real(rt) u(u_l1:u_h1,u_l2:u_h2,u_l3:u_h3,ncomp_u)
      real(rt) dx(3), xlo(3), time, dt
      integer bc(3,2,ncomp_u), level, grid_no

      real(rt) :: e, rhoInv
      integer i,j,k

      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom, (rho E), (rho e), Temp, Ne)
      ! 
      do k = lo(3),hi(3)
         do j = lo(2),hi(2)
            do i = lo(1),hi(1)
               rhoInv = 1.d0/u(i,j,k,URHO)
               e  = u(i,j,k,UEINT)*rhoInv

!              if (e .gt. 0.d0) then
!                 call nyx_eos_S_given_Re(s(i,j,k,1), u(i,j,k,URHO), e, &
!                                         u(i,j,k,7), u(i,j,k,8), &
!                                         comoving_a = 1.d0)
!              else
!                 s(i,j,k,1) = 0.d0
!              end if
            enddo
         enddo
      enddo

      end subroutine derentropy

!-----------------------------------------------------------------------

      subroutine derspec(spec,spec_l1,spec_l2,spec_l3,spec_h1,spec_h2,spec_h3,nv, &
                            dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                            domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine will derive X_i from (rho X)_i
      !
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer          spec_l1,spec_l2,spec_l3,spec_h1,spec_h2,spec_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) spec(spec_l1:spec_h1,spec_l2:spec_h2,spec_l3:spec_h3,nv)
      real(rt) dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no
 
      integer i,j,k
      ! 
      ! Here dat contains (Density, (rho X)_i)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               spec(i,j,k,1) = dat(i,j,k,2) / dat(i,j,k,1)
            end do
         end do
      end do
 
      end subroutine derspec

!-----------------------------------------------------------------------

      subroutine derlogden(logden,ld_l1,ld_l2,ld_l3,ld_h1,ld_h2,ld_h3,nd, &
                              dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer           ld_l1, ld_l2, ld_l3, ld_h1, ld_h2, ld_h3,nd
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3), level, grid_no
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) logden( ld_l1: ld_h1, ld_l2: ld_h2, ld_l3: ld_h3,nd)
      real(rt)    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
 
      integer    i,j,k
      ! 
      ! Here dat contains (Density)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               logden(i,j,k,1) = dlog10(dat(i,j,k,1))
            end do
         end do
      end do
 
      end subroutine derlogden

!-----------------------------------------------------------------------

      subroutine dermagvort(vort,v_l1,v_l2,v_l3,v_h1,v_h2,v_h3,nv, & 
                               dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                               domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine will calculate vorticity
      !     
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer            v_l1,  v_l2,  v_l3,  v_h1,  v_h2,  v_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3), level, grid_no
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) vort(  v_l1:  v_h1,  v_l2:  v_h2,  v_l3:  v_h3,nv)
      real(rt)  dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)

      integer          :: i,j,k
      real(rt) :: uy,uz,vx,vz,wx,wy,v1,v2,v3
      real(rt) :: ldat(lo(1)-1:hi(1)+1,lo(2)-1:hi(2)+1,lo(3)-1:hi(3)+1,2:4)

      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom)
      ! 

      !
      ! Convert momentum to velocity.
      !
      do k = lo(3)-1, hi(3)+1
         do j = lo(2)-1, hi(2)+1
            do i = lo(1)-1, hi(1)+1
               ldat(i,j,k,2) = dat(i,j,k,2) / dat(i,j,k,1)
               ldat(i,j,k,3) = dat(i,j,k,3) / dat(i,j,k,1)
               ldat(i,j,k,4) = dat(i,j,k,4) / dat(i,j,k,1)
            end do
         end do
      end do
      !
      ! Calculate vorticity.
      !
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               uy = (dat(i,j+1,k,2) - dat(i,j-1,k,2)) / delta(2)
               uz = (dat(i,j,k+1,2) - dat(i,j,k-1,2)) / delta(3)
               vx = (dat(i+1,j,k,3) - dat(i-1,j,k,3)) / delta(1)
               vz = (dat(i,j,k+1,3) - dat(i,j,k-1,3)) / delta(3)
               wx = (dat(i+1,j,k,4) - dat(i-1,j,k,4)) / delta(1)
               wy = (dat(i,j+1,k,4) - dat(i,j-1,k,4)) / delta(2)
               v1 = 0.5d0 * abs(wy - vz)
               v2 = 0.5d0 * abs(uz - wx)
               v3 = 0.5d0 * abs(vx - uy)
               vort(i,j,k,1) = sqrt(v1*v1 + v2*v2 + v3*v3)
            end do
         end do
      end do

      end subroutine dermagvort

!-----------------------------------------------------------------------

      subroutine derdivu(divu,div_l1,div_l2,div_l3,div_h1,div_h2,div_h3,nd, &
                            dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
                            lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine will divergence of velocity.
      !
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer          div_l1,div_l2,div_l3,div_h1,div_h2,div_h3,nd
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) divu(div_l1:div_h1,div_l2:div_h2,div_l3:div_h3,nd)
      real(rt)  dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      integer          :: i,j,k
      real(rt) :: ulo,uhi,vlo,vhi,wlo,whi
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               uhi = dat(i+1,j,k,2) / dat(i+1,j,k,1)
               ulo = dat(i-1,j,k,2) / dat(i-1,j,k,1)
               vhi = dat(i,j+1,k,3) / dat(i,j+1,k,1)
               vlo = dat(i,j-1,k,3) / dat(i,j-1,k,1)
               whi = dat(i,j,k+1,4) / dat(i,j,k+1,1)
               wlo = dat(i,j,k-1,4) / dat(i,j,k-1,1)
               divu(i,j,k,1) = 0.5d0 * ( (uhi-ulo) / delta(1) + &
                                         (vhi-vlo) / delta(2) + &
                                         (whi-wlo) / delta(3) )
            end do
         end do
      end do

      end subroutine derdivu

!-----------------------------------------------------------------------

      subroutine derkineng(kineng,ken_l1,ken_l2,ken_l3,ken_h1,ken_h2,ken_h3,nk, &
                              dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine will derive kinetic energy = 1/2 rho (u^2 + v^2)
      !
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer          ken_l1,ken_l2,ken_l3,ken_h1,ken_h2,ken_h3,nk
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) kineng(ken_l1:ken_h1,ken_l2:ken_h2,ken_l3:ken_h3,nk)
      real(rt)    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      integer i,j,k
      ! 
      ! Here dat contains (Density, Xmom, Ymom, Zmom)
      ! 
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               kineng(i,j,k,1) = 0.5d0 / dat(i,j,k,1) * ( dat(i,j,k,2)**2 + &
                                                          dat(i,j,k,3)**2 + &
                                                          dat(i,j,k,4)**2 )
            end do
         end do
      end do

      end subroutine derkineng

!-----------------------------------------------------------------------

      subroutine dernull(kineng,ken_l1,ken_l2,ken_l3,ken_h1,ken_h2,ken_h3,nk, &
                            dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
                             lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine is used by particle_count.  Yes it does nothing.
      !
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer          ken_l1,ken_l2,ken_l3,ken_h1,ken_h2,ken_h3,nk
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) kineng(ken_l1:ken_h1,ken_l2:ken_h2,ken_l3:ken_h3,nk)
      real(rt)    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      end subroutine dernull

!-----------------------------------------------------------------------

      subroutine dermomt(vel,vel_l1,vel_l2,vel_l3,vel_h1,vel_h2,vel_h3,nv, &
                           dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc,lo,hi,domlo, &
                           domhi,delta,xlo,time,dt,bc,level,grid_no)
      !
      ! This routine computes Mom + Mom*Sdens/Density
      !
      use amrex_fort_module, only : rt => amrex_real
      implicit none

      integer          lo(3), hi(3)
      integer          vel_l1,vel_l2,vel_l3,vel_h1,vel_h2,vel_h3,nv
      integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
      integer          domlo(3), domhi(3)
      integer          bc(3,2,nc)
      real(rt) delta(3), xlo(3), time, dt
      real(rt) vel(vel_l1:vel_h1,vel_l2:vel_h2,vel_l3:vel_h3,nv)
      real(rt) dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
      integer    level, grid_no

      integer i,j,k

      ! 
      ! Here dat contains (Density, Single Component of Momentum, Sdens)
      ! 

      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               vel(i,j,k,1) = dat(i,j,k,2) + dat(i,j,k,2)*dat(i,j,k,3)/dat(i,j,k,1)
            end do
         end do
      end do

      end subroutine dermomt
! !-----------------------------------------------------------------------

!       subroutine ca_axphase(phase,phase_l1,phase_l2,phase_l3,phase_h1,phase_h2,phase_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       ! use fdm_params_module, only : mindens, meandens

!       implicit none

!       integer          lo(3), hi(3)
!       integer          phase_l1,phase_l2,phase_l3,phase_h1,phase_h2,phase_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision phase(phase_l1:phase_h1,phase_l2:phase_h2,phase_l3:phase_h3,nk)
!       double precision    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       integer i, j, k !, n

! !       n = 0

! !       !$OMP PARALLEL DO PRIVATE(i,j,k)
! !       do k = lo(3), hi(3)                                                                                                                                                          
! !          do j = lo(2), hi(2)                                                                                                                                                       
! !             do i = lo(1), hi(1)
! !                if (dat(i,j,k,1) .gt. (0.75d0*meandens) ) then
! !                   n = n+8  !Since the boson star is equally located inside 8 patches
! !                endif
! !             enddo
! !          enddo
! !       enddo
! !       !$OMP END PARALLEL DO

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)
! !                if (dat(i,j,k,1) .gt. (0.75d0*meandens) ) then
!                phase(i,j,k,1)= datan2(dat(i,j,k,3),dat(i,j,k,2)) !/(n*delta(1)*delta(2)*delta(3))
! !                else
! !                   phase(i,j,k,1)=0.0
! !                endif
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO
! end subroutine ca_axphase



! !-----------------------------------------------------------------------

!       subroutine ca_axepot(epot,epot_l1,epot_l2,epot_l3,epot_h1,epot_h2,epot_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       implicit none

!       integer          lo(3), hi(3)
!       integer          epot_l1,epot_l2,epot_l3,epot_h1,epot_h2,epot_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision epot(epot_l1:epot_h1,epot_l2:epot_h2,epot_l3:epot_h3,nk)
!       double precision    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)
!                   epot(i,j,k,1)= -dat(i,j,k,1)*dat(i,j,k,2)/2
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axepot

! !-----------------------------------------------------------------------

!       subroutine ca_axekin(ekin,ekin_l1,ekin_l2,ekin_l3,ekin_h1,ekin_h2,ekin_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt,meandens,hbaroverm

!       implicit none

!       integer          lo(3), hi(3)
!       integer          ekin_l1,ekin_l2,ekin_l3,ekin_h1,ekin_h2,ekin_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision ekin(ekin_l1:ekin_h1,ekin_l2:ekin_h2,ekin_l3:ekin_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)
!                ekin(i,j,k,1)= hbaroverm**2 / 2 * &
!                               (((-dat(i+2,j,k,2)+8.0d0*dat(i+1,j,k,2)-8.0d0*dat(i-1,j,k,2)+dat(i-2,j,k,2))/(12.0d0*delta(1)))**2 &
!                               +((-dat(i+2,j,k,3)+8.0d0*dat(i+1,j,k,3)-8.0d0*dat(i-1,j,k,3)+dat(i-2,j,k,3))/(12.0d0*delta(1)))**2 &
!                               +((-dat(i,j+2,k,2)+8.0d0*dat(i,j+1,k,2)-8.0d0*dat(i,j-1,k,2)+dat(i,j-2,k,2))/(12.0d0*delta(2)))**2 &
!                               +((-dat(i,j+2,k,3)+8.0d0*dat(i,j+1,k,3)-8.0d0*dat(i,j-1,k,3)+dat(i,j-2,k,3))/(12.0d0*delta(2)))**2 &
!                               +((-dat(i,j,k+2,2)+8.0d0*dat(i,j,k+1,2)-8.0d0*dat(i,j,k-1,2)+dat(i,j,k-2,2))/(12.0d0*delta(3)))**2 &
!                               +((-dat(i,j,k+2,3)+8.0d0*dat(i,j,k+1,3)-8.0d0*dat(i,j,k-1,3)+dat(i,j,k-2,3))/(12.0d0*delta(3)))**2 )

! !                               +((dat(i,j+1,k,2)-dat(i,j-1,k,2))/(2.0d0*delta(2)))**2+((dat(i,j+1,k,3)-dat(i,j-1,k,3))/(2.0d0*delta(2)))**2 &
! !                               +((dat(i,j,k+1,2)-dat(i,j,k-1,2))/(2.0d0*delta(3)))**2+((dat(i,j,k+1,3)-dat(i,j,k-1,3))/(2.0d0*delta(3)))**2 )




! !                               (((dat(i+1,j,k,2)-dat(i-1,j,k,2))/(2.0d0*delta(1)))**2+((dat(i+1,j,k,3)-dat(i-1,j,k,3))/(2.0d0*delta(1)))**2 &
! !                               +((dat(i,j+1,k,2)-dat(i,j-1,k,2))/(2.0d0*delta(2)))**2+((dat(i,j+1,k,3)-dat(i,j-1,k,3))/(2.0d0*delta(2)))**2 &
! !                               +((dat(i,j,k+1,2)-dat(i,j,k-1,2))/(2.0d0*delta(3)))**2+((dat(i,j,k+1,3)-dat(i,j,k-1,3))/(2.0d0*delta(3)))**2 )


! !                                  (( (-dsqrt(dat(i+2,j,k,1))+8.0d0*dsqrt(dat(i+1,j,k,1))-8.0d0*dsqrt(dat(i-1,j,k,1))+dsqrt(dat(i-2,j,k,1))) / (12.0d0*delta(1)) )**2 &
! !                                  +( (-dsqrt(dat(i,j+2,k,1))+8.0d0*dsqrt(dat(i,j+1,k,1))-8.0d0*dsqrt(dat(i,j-1,k,1))+dsqrt(dat(i,j-2,k,1))) / (12.0d0*delta(2)) )**2 &
! !                                  +( (-dsqrt(dat(i,j,k+2,1))+8.0d0*dsqrt(dat(i,j,k+1,1))-8.0d0*dsqrt(dat(i,j,k-1,1))+dsqrt(dat(i,j,k-2,1))) / (12.0d0*delta(3)) )**2 )

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axekin

! !-----------------------------------------------------------------------

!       subroutine ca_axekinrho(ekinrho,ekinrho_l1,ekinrho_l2,ekinrho_l3,ekinrho_h1,ekinrho_h2,ekinrho_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt,hbaroverm,a

!       implicit none

!       integer          lo(3), hi(3)
!       integer          ekinrho_l1,ekinrho_l2,ekinrho_l3,ekinrho_h1,ekinrho_h2,ekinrho_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision ekinrho(ekinrho_l1:ekinrho_h1,ekinrho_l2:ekinrho_h2,ekinrho_l3:ekinrho_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       integer i, j, k

!       !Unfortunately, the interpolation argorithm sometimes yields a small negative density
!       !if the density is close to zero in a specific area. We can't allow that and set it to zero. 

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3)-2, hi(3)+2                                                                                                                                                          
!          do j = lo(2)-2, hi(2)+2                                                                                                                                                       
!             do i = lo(1)-2, hi(1)+2
!                if (dat(i,j,k,1) .lt. 0.0d0) then
!                   dat(i,j,k,1) = 0.0d0
!                endif
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)
!                ekinrho(i,j,k,1)= hbaroverm**2 / 2 * &
!                                  (( (-dsqrt(dat(i+2,j,k,1))+8.0d0*dsqrt(dat(i+1,j,k,1))-8.0d0*dsqrt(dat(i-1,j,k,1))+dsqrt(dat(i-2,j,k,1))) / (12.0d0*delta(1)*a) )**2 &
!                                  +( (-dsqrt(dat(i,j+2,k,1))+8.0d0*dsqrt(dat(i,j+1,k,1))-8.0d0*dsqrt(dat(i,j-1,k,1))+dsqrt(dat(i,j-2,k,1))) / (12.0d0*delta(2)*a) )**2 &
!                                  +( (-dsqrt(dat(i,j,k+2,1))+8.0d0*dsqrt(dat(i,j,k+1,1))-8.0d0*dsqrt(dat(i,j,k-1,1))+dsqrt(dat(i,j,k-2,1))) / (12.0d0*delta(3)*a) )**2 )
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axekinrho

! !-----------------------------------------------------------------------

!       subroutine ca_axekinv(ekinv,ekinv_l1,ekinv_l2,ekinv_l3,ekinv_h1,ekinv_h2,ekinv_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt, hbaroverm,a!, mindens
!       use fundamental_constants_module

!       implicit none

!       integer          lo(3), hi(3)
!       integer          ekinv_l1,ekinv_l2,ekinv_l3,ekinv_h1,ekinv_h2,ekinv_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt, diff(3)
!       double precision ekinv(ekinv_l1:ekinv_h1,ekinv_l2:ekinv_h2,ekinv_l3:ekinv_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       double precision phase(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3)
!       integer    level, grid_no

!       integer i, j, k

!       if (nc .eq. 3) then !We solve AxDens,AxIm,AxRe 

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3)-1, hi(3)+1                                                                                                                                                          
!          do j = lo(2)-1, hi(2)+1                                                                                                                                                       
!             do i = lo(1)-1, hi(1)+1
!                if (dat(i,j,k,1) .ne. 0.0d0) then
!                   phase(i,j,k) = datan2(dat(i,j,k,3),dat(i,j,k,2))
!                else
!                   phase(i,j,k)=0.0
!                endif
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                !Have to consider the cases where the phase jumps from close to -pi to pi and vice versa
!                diff(1) = min( dabs(phase(i+1,j,k)-phase(i-1,j,k)) , dabs(phase(i+1,j,k)-phase(i-1,j,k)-2.0*PI) , dabs(phase(i+1,j,k)-phase(i-1,j,k)+2.0*PI) ) 
!                diff(2) = min( dabs(phase(i,j+1,k)-phase(i,j-1,k)) , dabs(phase(i,j+1,k)-phase(i,j-1,k)-2.0*PI) , dabs(phase(i,j+1,k)-phase(i,j-1,k)+2.0*PI) ) 
!                diff(3) = min( dabs(phase(i,j,k+1)-phase(i,j,k-1)) , dabs(phase(i,j,k+1)-phase(i,j,k-1)-2.0*PI) , dabs(phase(i,j,k+1)-phase(i,j,k-1)+2.0*PI) ) 

!                ekinv(i,j,k,1)= hbaroverm**2 / 2 * dat(i,j,k,1) * &
!                                (( diff(1) / (2*delta(1)*a) )**2 &
!                                +( diff(2) / (2*delta(2)*a) )**2 &
!                                +( diff(3) / (2*delta(3)*a) )**2)

!                ! !Have to consider the cases where the phase jumps from close to -pi to pi and vice versa
!                ! diff(1) = min( dabs(phase(i+1,j,k)-phase(i,j,k)) , dabs(phase(i+1,j,k)-phase(i,j,k)-2.0*PI) , dabs(phase(i+1,j,k)-phase(i,j,k)+2.0*PI) ) 
!                ! diff(2) = min( dabs(phase(i,j+1,k)-phase(i,j,k)) , dabs(phase(i,j+1,k)-phase(i,j,k)-2.0*PI) , dabs(phase(i,j+1,k)-phase(i,j,k)+2.0*PI) ) 
!                ! diff(3) = min( dabs(phase(i,j,k+1)-phase(i,j,k)) , dabs(phase(i,j,k+1)-phase(i,j,k)-2.0*PI) , dabs(phase(i,j,k+1)-phase(i,j,k)+2.0*PI) ) 

!                ! ekinv(i,j,k,1)= hbaroverm**2 / 2 * ( dat(i,j,k,1)+dat(i+1,j,k,1)+dat(i,j+1,k,1)+dat(i,j,k+1,1)+dat(i+1,j+1,k,1)+dat(i,j+1,k+1,1)+dat(i+1,j,k+1,1)+dat(i+1,j+1,k+1,1) )/8 * &
!                !                 (( diff(1) / delta(1) )**2 &
!                !                 +( diff(2) / delta(2) )**2 &
!                !                 +( diff(3) / delta(3) )**2)
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       else !We solve UAXDENS, UAXMOMX, UAXMOMY, UAXMOMZ
         
!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                if (dat(i,j,k,1) .eq. 0.d0 ) then
!                   ekinv(i,j,k,1) = 0.d0
!                else
!                   ekinv(i,j,k,1)= ( dat(i,j,k,2)**2 + dat(i,j,k,3)**2 + dat(i,j,k,4)**2 )/dat(i,j,k,1)/2.d0
!                endif

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO
                  
!       endif

!       end subroutine ca_axekinv


! !-----------------------------------------------------------------------

!       subroutine ca_axvel(ekinv,ekinv_l1,ekinv_l2,ekinv_l3,ekinv_h1,ekinv_h2,ekinv_h3,nk, &
!                           dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                           lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt, hbaroverm!, mindens
!       use fundamental_constants_module

!       implicit none

!       integer          lo(3), hi(3)
!       integer          ekinv_l1,ekinv_l2,ekinv_l3,ekinv_h1,ekinv_h2,ekinv_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt, diff(3)
!       double precision ekinv(ekinv_l1:ekinv_h1,ekinv_l2:ekinv_h2,ekinv_l3:ekinv_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       double precision phase(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3)
!       integer    level, grid_no

!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3)-1, hi(3)+1                                                                                                                                                          
!          do j = lo(2)-1, hi(2)+1                                                                                                                                                       
!             do i = lo(1)-1, hi(1)+1
!                if (dat(i,j,k,1) .ne. 0.0d0) then
!                   phase(i,j,k) = datan2(dat(i,j,k,3),dat(i,j,k,2))
!                else
!                   phase(i,j,k)=0.0
!                endif
!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                !Have to consider the cases where the phase jumps from close to -pi to pi and vice versa
!                diff(1) = min( dabs(phase(i+1,j,k)-phase(i-1,j,k)) , dabs(phase(i+1,j,k)-phase(i-1,j,k)-2.0*PI) , dabs(phase(i+1,j,k)-phase(i-1,j,k)+2.0*PI) ) 
!                diff(2) = min( dabs(phase(i,j+1,k)-phase(i,j-1,k)) , dabs(phase(i,j+1,k)-phase(i,j-1,k)-2.0*PI) , dabs(phase(i,j+1,k)-phase(i,j-1,k)+2.0*PI) ) 
!                diff(3) = min( dabs(phase(i,j,k+1)-phase(i,j,k-1)) , dabs(phase(i,j,k+1)-phase(i,j,k-1)-2.0*PI) , dabs(phase(i,j,k+1)-phase(i,j,k-1)+2.0*PI) ) 

!                ekinv(i,j,k,1)= hbaroverm * sqrt(&
!                                 ( diff(1) / (2*delta(1)) )**2 &
!                                +( diff(2) / (2*delta(2)) )**2 &
!                                +( diff(3) / (2*delta(3)) )**2)

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axvel


!  !-----------------------------------------------------------------------
 
!       subroutine ca_axangmom_x(angmom_x,angmom_x_l1,angmom_x_l2,angmom_x_l3,angmom_x_h1,angmom_x_h2,angmom_x_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt,meandens,hbaroverm
!       use fundamental_constants_module

!       implicit none

!       integer          lo(3), hi(3)
!       integer          angmom_x_l1,angmom_x_l2,angmom_x_l3,angmom_x_h1,angmom_x_h2,angmom_x_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision angmom_x(angmom_x_l1:angmom_x_h1,angmom_x_l2:angmom_x_h2,angmom_x_l3:angmom_x_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       ! double precision phase(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3)
!       integer    level, grid_no

!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                angmom_x(i,j,k,1) = hbaroverm*meandens*( -dat(i,j,k,2)*(dat(i,j,k+1,3)-dat(i,j,k-1,3))/(2.0d0*delta(3))*(j*delta(2)+xlo(2)) &
!                                                         +dat(i,j,k,3)*(dat(i,j,k+1,2)-dat(i,j,k-1,2))/(2.0d0*delta(3))*(j*delta(2)+xlo(2)) &   
!                                                         +dat(i,j,k,2)*(dat(i,j+1,k,3)-dat(i,j-1,k,3))/(2.0d0*delta(2))*(k*delta(3)+xlo(3)) &  
!                                                         -dat(i,j,k,3)*(dat(i,j+1,k,2)-dat(i,j-1,k,2))/(2.0d0*delta(2))*(k*delta(3)+xlo(3)) )

!             enddo 
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axangmom_x

! !-----------------------------------------------------------------------

!       subroutine ca_axangmom_y(angmom_y,angmom_y_l1,angmom_y_l2,angmom_y_l3,angmom_y_h1,angmom_y_h2,angmom_y_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt,meandens,hbaroverm
!       use fundamental_constants_module

!       implicit none

!       integer          lo(3), hi(3)
!       integer          angmom_y_l1,angmom_y_l2,angmom_y_l3,angmom_y_h1,angmom_y_h2,angmom_y_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision angmom_y(angmom_y_l1:angmom_y_h1,angmom_y_l2:angmom_y_h2,angmom_y_l3:angmom_y_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       ! double precision phase(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3)
!       integer    level, grid_no

!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                angmom_y(i,j,k,1) = hbaroverm*meandens*( -dat(i,j,k,2)*(dat(i+1,j,k,3)-dat(i-1,j,k,3))/(2.0d0*delta(1))*(k*delta(3)+xlo(3)) &
!                                                         +dat(i,j,k,3)*(dat(i+1,j,k,2)-dat(i-1,j,k,2))/(2.0d0*delta(1))*(k*delta(3)+xlo(3)) &   
!                                                         +dat(i,j,k,2)*(dat(i,j,k+1,3)-dat(i,j,k-1,3))/(2.0d0*delta(3))*(i*delta(1)+xlo(1)) &  
!                                                         -dat(i,j,k,3)*(dat(i,j,k+1,2)-dat(i,j,k-1,2))/(2.0d0*delta(3))*(i*delta(1)+xlo(1)) )

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axangmom_y

! !-----------------------------------------------------------------------

!       subroutine ca_axangmom_z(angmom_z,angmom_z_l1,angmom_z_l2,angmom_z_l3,angmom_z_h1,angmom_z_h2,angmom_z_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)

!       use fdm_params_module, only : m_tt,meandens,hbaroverm
!       use fundamental_constants_module

!       implicit none

!       integer          lo(3), hi(3)
!       integer          angmom_z_l1,angmom_z_l2,angmom_z_l3,angmom_z_h1,angmom_z_h2,angmom_z_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision angmom_z(angmom_z_l1:angmom_z_h1,angmom_z_l2:angmom_z_h2,angmom_z_l3:angmom_z_h3,nk)
!       double precision dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       ! double precision phase(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3)
!       integer    level, grid_no

!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                angmom_z(i,j,k,1) = hbaroverm*meandens*( -dat(i,j,k,2)*(dat(i,j+1,k,3)-dat(i,j-1,k,3))/(2.0d0*delta(2))*(i*delta(1)+xlo(1)) &
!                                                         +dat(i,j,k,3)*(dat(i,j+1,k,2)-dat(i,j-1,k,2))/(2.0d0*delta(2))*(i*delta(1)+xlo(1)) &   
!                                                         +dat(i,j,k,2)*(dat(i+1,j,k,3)-dat(i-1,j,k,3))/(2.0d0*delta(1))*(j*delta(2)+xlo(2)) &  
!                                                         -dat(i,j,k,3)*(dat(i+1,j,k,2)-dat(i-1,j,k,2))/(2.0d0*delta(1))*(j*delta(2)+xlo(2)) )

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_axangmom_z

! !-----------------------------------------------------------------------


!       subroutine ca_dererrx(err,err_l1,err_l2,err_l3,err_h1,err_h2,err_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
!       !
!       ! This routine calculates the error estimator for the fdm velocity (AxRe,AxIm) 
!       ! according to R. Loehner (1987) eq.4
!       !

!       use fdm_params_module, only : epsilon_L, mindens

!       implicit none

!       integer          lo(3), hi(3)
!       integer          err_l1,err_l2,err_l3,err_h1,err_h2,err_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision err(err_l1:err_h1,err_l2:err_h2,err_l3:err_h3,nk)
!       double precision    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       double precision secondder, firstder, meanvalue
!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                      
!          do j = lo(2), hi(2)                                                                                                                                              
!             do i = lo(1), hi(1)

!                secondder = dabs(dat(i+1,j,k,1)-2.*dat(i,j,k,1)+dat(i-1,j,k,1))
!                firstder  = dabs(dat(i+1,j,k,1)-dat(i,j,k,1)) +dabs(dat(i,j,k,1)-dat(i-1,j,k,1))
!                meanvalue = dabs(dat(i+1,j,k,1)+2.*dat(i,j,k,1)+dat(i-1,j,k,1))                                                 
!                if ( ( firstder .gt. 1.0d-100 ) .and. ( dabs(dat(i,j,k,2)) .gt. mindens ) ) then
!                   err(i,j,k,1) = secondder/(firstder+epsilon_L*meanvalue)
!                else
!                   err(i,j,k,1) = 0.0d0
!                endif

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_dererrx

! !-----------------------------------------------------------------------

!       subroutine ca_dererry(err,err_l1,err_l2,err_l3,err_h1,err_h2,err_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
!       !
!       ! This routine calculates the error estimator for the fdm velocity (AxRe,AxIm) 
!       ! according to R. Loehner (1987) eq.4
!       !

!       use fdm_params_module, only : epsilon_L, mindens

!       implicit none

!       integer          lo(3), hi(3)
!       integer          err_l1,err_l2,err_l3,err_h1,err_h2,err_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision err(err_l1:err_h1,err_l2:err_h2,err_l3:err_h3,nk)
!       double precision    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       double precision secondder, firstder, meanvalue
!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                secondder = dabs(dat(i,j+1,k,1)-2.*dat(i,j,k,1)+dat(i,j-1,k,1))
!                firstder  = dabs(dat(i,j+1,k,1)-dat(i,j,k,1)) +dabs(dat(i,j,k,1)-dat(i,j-1,k,1))
!                meanvalue = dabs(dat(i,j+1,k,1)+2.*dat(i,j,k,1)+dat(i,j-1,k,1))
!                if ( ( firstder .gt. 1.0d-100 ) .and. ( dabs(dat(i,j,k,2)) .gt. mindens ) ) then
!                   err(i,j,k,1) = secondder/(firstder+epsilon_L*meanvalue)
!                else
!                   err(i,j,k,1) = 0.0d0
!                endif

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_dererry

! !-----------------------------------------------------------------------

!       subroutine ca_dererrz(err,err_l1,err_l2,err_l3,err_h1,err_h2,err_h3,nk, &
!                             dat,dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc, &
!                              lo,hi,domlo,domhi,delta,xlo,time,dt,bc,level,grid_no)
!       !
!       ! This routine calculates the error estimator for the fdm velocity (AxRe,AxIm) 
!       ! according to R. Loehner (1987) eq.4
!       !

!       use fdm_params_module, only : epsilon_L, mindens

!       implicit none

!       integer          lo(3), hi(3)
!       integer          err_l1,err_l2,err_l3,err_h1,err_h2,err_h3,nk
!       integer          dat_l1,dat_l2,dat_l3,dat_h1,dat_h2,dat_h3,nc
!       integer          domlo(3), domhi(3)
!       integer          bc(3,2,nc)
!       double precision delta(3), xlo(3), time, dt
!       double precision err(err_l1:err_h1,err_l2:err_h2,err_l3:err_h3,nk)
!       double precision    dat(dat_l1:dat_h1,dat_l2:dat_h2,dat_l3:dat_h3,nc)
!       integer    level, grid_no

!       double precision secondder, firstder, meanvalue
!       integer i, j, k

!       !$OMP PARALLEL DO PRIVATE(i,j,k)
!       do k = lo(3), hi(3)                                                                                                                                                          
!          do j = lo(2), hi(2)                                                                                                                                                       
!             do i = lo(1), hi(1)

!                secondder = dabs(dat(i,j,k+1,1)-2.*dat(i,j,k,1)+dat(i,j,k-1,1))
!                firstder  = dabs(dat(i,j,k+1,1)-dat(i,j,k,1)) +dabs(dat(i,j,k,1)-dat(i,j,k-1,1))
!                meanvalue = dabs(dat(i,j,k+1,1)+2.*dat(i,j,k,1)+dat(i,j,k-1,1))                                                 
!                if ( ( firstder .gt. 1.0d-100 ) .and. ( dabs(dat(i,j,k,2)) .gt. mindens ) ) then
!                   err(i,j,k,1) = secondder/(firstder+epsilon_L*meanvalue)
!                else
!                   err(i,j,k,1) = 0.0d0
!                endif

!             enddo
!          enddo
!       enddo
!       !$OMP END PARALLEL DO

!       end subroutine ca_dererrz
