
# File integrate\_state\_box\_3d\_stubs.cpp

[**File List**](files.md) **>** [**HeatCool**](dir_8c890215953ac09098af8cb94c8b9fc0.md) **>** [**integrate\_state\_box\_3d\_stubs.cpp**](integrate__state__box__3d__stubs_8cpp.md)

[Go to the documentation of this file.](integrate__state__box__3d__stubs_8cpp.md) 


````cpp
#include <fstream>
#include <iomanip>

#include <AMReX_ParmParse.H>
#include <AMReX_Geometry.H>
#include <AMReX_MultiFab.H>
#include <AMReX_Print.H>
#include <AMReX_PlotFileUtil.H>

#include <AMReX_BLFort.H>
#include <Nyx.H>
#include <Nyx_F.H>

using namespace amrex;

/* Private function to check function return values */
static int check_retval(void *flagvalue, const char *funcname, int opt);

int Nyx::integrate_state_box
  (amrex::MultiFab &S_old,
   amrex::MultiFab &D_old,
   const Real& a, const Real& delta_time)
{

  amrex::Abort("Using stubs file for heat_cool_type=10");
  return 0;
}

int Nyx::integrate_state_grownbox
  (amrex::MultiFab &S_old,
   amrex::MultiFab &D_old,
   const Real& a, const Real& delta_time)
{

  amrex::Abort("Using stubs file for heat_cool_type=10");
  return 0;
}


int Nyx::integrate_state_vec
  (amrex::MultiFab &S_old,
   amrex::MultiFab &D_old,
   const Real& a, const Real& delta_time)
{

  amrex::Abort("Using stubs file for heat_cool_type=11");
  return 0;
}

int Nyx::integrate_state_grownvec
  (amrex::MultiFab &S_old,
   amrex::MultiFab &D_old,
   const Real& a, const Real& delta_time)
{

  amrex::Abort("Using stubs file for heat_cool_type=11");
  return 0;
}
````

