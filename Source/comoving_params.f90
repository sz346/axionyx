module comoving_module

    use amrex_fort_module, only : rt => amrex_real

    integer,  save :: comoving_type
    real(rt), save :: comoving_OmM, comoving_OmB, comoving_OmN, comoving_h, comoving_OmL
    !for axions/scalar field dark matter:
    real(rt), save :: comoving_OmAx

end module comoving_module
