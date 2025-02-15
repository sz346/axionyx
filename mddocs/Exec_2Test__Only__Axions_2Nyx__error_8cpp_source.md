
# File Nyx\_error.cpp

[**File List**](files.md) **>** [**Exec**](dir_43a12cefb7942b6f49b5b628aafd3192.md) **>** [**Test\_Only\_Axions**](dir_eb24725df855cf6c732a19e4912f662a.md) **>** [**Nyx\_error.cpp**](Exec_2Test__Only__Axions_2Nyx__error_8cpp.md)

[Go to the documentation of this file.](Exec_2Test__Only__Axions_2Nyx__error_8cpp.md) 


````cpp

#include "Nyx.H"
#include "Nyx_error_F.H"

using std::string;

using namespace amrex;
void
Nyx::error_setup()
{
    // The lines below define routines to be called to tag cells for error
    // estimation -- the arguments of each "add" call are:
    //   1. Name of variable (state variable or derived quantity) which will be
    //      passed into the Fortran subroutine.
    //   2. Number of ghost cells each array needs in each call to the Fortran
    //      subroutine.
    //   3. Type of Fortran subroutine -- this determines the argument list of
    //      the Fortran subroutine.  These types are pre-defined and are
    //      currently restricted to ErrorRec::Standard and ErrorRec::UseAverage.
    //   4. Name of Fortran subroutine.

    // The routine LAPLAC_ERROR uses the special evaluation of the second
    // derivative and can be called with any variable. Note that two ghost cells
    // are needed.

    //err_list.add("density", 2, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_LAPLAC_ERROR, tag_laplac_error));

    //err_list.add("pressure", 2, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_LAPLAC_ERROR, tag_laplac_error));

    //err_list.add("density", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_DENERROR, tag_denerror));

    //err_list.add("Temp", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_TEMPERROR, tag_temperror));

    //err_list.add("pressure", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_PRESSERROR, tag_presserror));

    //err_list.add("x_velocity", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_VELERROR,tag_velerror));

    //err_list.add("y_velocity", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_VELERROR, tag_velerror));

    //err_list.add("z_velocity", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_VELERROR, tag_velerror));

    //err_list.add("entropy", 1, ErrorRec::Standard,
    //             BL_FORT_PROC_CALL(TAG_ENTERROR, tag_enterror));

    //err_list.add("total_density",1,ErrorRec::UseAverage,
    //             BL_FORT_PROC_CALL(TAG_OVERDENSITY, tag_overdensity));

    err_list.add("AxDens",1,ErrorRec::UseAverage,
                 BL_FORT_PROC_CALL(TAG_OVERDENSITY, tag_overdensity));

    // err_list.add("AxDens",1,ErrorRec::UseAverage,
    //              BL_FORT_PROC_CALL(TAG_CENTER, tag_center));

    // err_list.add("AxRe_err_x",1,ErrorRec::Standard,
    //              BL_FORT_PROC_CALL(TAG_AXVEL, tag_axvel));

    // err_list.add("AxRe_err_y",1,ErrorRec::Standard,
    //              BL_FORT_PROC_CALL(TAG_AXVEL, tag_axvel));

    // err_list.add("AxRe_err_z",1,ErrorRec::Standard,
    //              BL_FORT_PROC_CALL(TAG_AXVEL, tag_axvel));

    // err_list.add("AxRe_err_x",1,ErrorRec::Standard,
    //              BL_FORT_PROC_CALL(TAG_AXVEL, tag_axvel));

    // err_list.add("AxRe_err_y",1,ErrorRec::Standard,
    //              BL_FORT_PROC_CALL(TAG_AXVEL, tag_axvel));

    // err_list.add("AxRe_err_z",1,ErrorRec::Standard,
    //              BL_FORT_PROC_CALL(TAG_AXVEL, tag_axvel));

}

void Nyx::manual_tags_placement (TagBoxArray& a, const Vector<IntVect>& bf_lev)
{
}
````

