
# File DarkMatterParticleContainer.H

[**File List**](files.md) **>** [**Source**](dir_74389ed8173ad57b461b9d623a1f3867.md) **>** [**DarkMatterParticleContainer.H**](DarkMatterParticleContainer_8H.md)

[Go to the documentation of this file.](DarkMatterParticleContainer_8H.md) 


````cpp

#ifndef _DarkMatterParticleContainer_H_
#define _DarkMatterParticleContainer_H_

#include "NyxParticleContainer.H"

class DarkMatterParticleContainer
    : public NyxParticleContainer<1+BL_SPACEDIM>
{
public:
    DarkMatterParticleContainer (amrex::Amr* amr)
        : NyxParticleContainer<1+BL_SPACEDIM>(amr)
    {
      real_comp_names.clear();
      real_comp_names.push_back("mass");
      real_comp_names.push_back("xvel");
      real_comp_names.push_back("yvel");
      real_comp_names.push_back("zvel");
    }

    using MyParIter = amrex::ParIter<1+BL_SPACEDIM>;
    using MyConstParIter = amrex::ParConstIter<1+BL_SPACEDIM>;

    virtual ~DarkMatterParticleContainer () {}

    void InitCosmo  (amrex::MultiFab& mf, const amrex::Real vel_fac[], const amrex::Vector<int> n_part, const amrex::Real particleMass);
    void InitCosmo  (amrex::MultiFab& mf, const amrex::Real vel_fac[], const amrex::Vector<int> n_part,
                     const amrex::Real particleMass, const amrex::Real shift[]);
    void InitCosmo1ppc (amrex::MultiFab& mf, const amrex::Real vel_fac[], const amrex::Real particleMass);
    void InitCosmo1ppcMultiLevel(amrex::MultiFab& mf, const amrex::Real disp_fac[], const amrex::Real vel_fac[], 
                                 const amrex::Real particleMass, int disp_idx, int vel_idx, 
                                 amrex::BoxArray &baWhereNot, int lev, int nlevs);

    void AssignDensityAndVels (amrex::Vector<std::unique_ptr<amrex::MultiFab> >& mf, int lev_min = 0) const;

    virtual void moveKickDrift (amrex::MultiFab& acceleration, int level, amrex::Real timestep,
                                amrex::Real a_old = 1.0, amrex::Real a_half = 1.0, int where_width = 0);
    virtual void moveKick      (amrex::MultiFab& acceleration, int level, amrex::Real timestep,
                                amrex::Real a_new = 1.0, amrex::Real a_half = 1.0);

    void InitFromBinaryMortonFile(const std::string& particle_directory, int nextra, int skip_factor);
    
#ifdef FDM
    void InitGaussianBeams (long num_particle_dm, int lev, int nlevs, const amrex::Real amp, const amrex::Real alpha, const amrex::Real a);

    amrex::Real generateGaussianNoise(const amrex::Real &mean, const amrex::Real &stdDev);
#endif
};

#endif /* _DarkMatterParticleContainer_H_ */
````

