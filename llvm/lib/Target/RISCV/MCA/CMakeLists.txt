add_llvm_component_library(LLVMRISCVTargetMCA
  RISCVCustomBehaviour.cpp

  LINK_COMPONENTS
  MC
  MCA
  MCParser
  RISCVDesc
  RISCVInfo
  Support

  ADD_TO_COMPONENT
  RISCV
  )
